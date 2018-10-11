import SpriteKit

/* Tracking enum for use with character and sushi side*/
enum Side{
    case left, right, none
}
enum GameState {
    // Tracking enum for game state
    case title, ready, playing, gameOver
}
class GameScene: SKScene{
    
    
    
    var sushiBasePiece: SushiPiece!
    var healthBar: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    // cat character
    var character: Character!
    var sushiTower: [SushiPiece] = []
    var state: GameState = .title
    var playButton: MSButtonNode!
    var health: CGFloat =  1.0 {
        didSet {
            // Scale health bar between 0.0 -> 1.0 -> 100
            if health  > 1.0{
                health =  1.0
            }
            healthBar.xScale = health
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        healthBar = childNode(withName: "healthBar") as? SKSpriteNode
        sushiBasePiece = childNode(withName: "sushiBasePiece") as? SushiPiece
        character = childNode(withName: "character") as? Character
        sushiBasePiece.connectChopsticks()
        addTowerPiece(side: .none)
        addRandomPiece(total: 10)
        playButton = childNode(withName: "playButton") as? MSButtonNode
        playButton.selectedHandler = {
            // Start game
            self.state = .ready
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if state !=  .playing {return}
        // Deceasing Health
        health -= 0.01
        // Has the player ran out of health
        if health < 0{
            gameOver()
        }
        moveTowerDown()
        
        
    }
    
    func addTowerPiece(side: Side){
        // Add a new sushi peice to the sushi tower
        
        // Copy original sushi piece
        let newPiece =  sushiBasePiece.copy() as! SushiPiece
        newPiece.connectChopsticks()
        
        // Access last piece properties
        let lastPiece = sushiTower.last
        
        // Add on top of tlast piece default on first piece
        let lastPosition = lastPiece?.position ?? sushiBasePiece.position
        newPiece.position.x = lastPosition.x
        newPiece.position.y = lastPosition.y + 55
        
        // Increment Z to ensure it's ontop of the lst piece, default on the first piece
        let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
        newPiece.zPosition = lastZPosition + 1
        
        // set side
        newPiece.side = side
        
        // Add sushi to scene
        addChild(newPiece)
        
        // Add sushi piece to the sushi tower
        sushiTower.append(newPiece)
    }
    
    func addRandomPiece(total: Int){
        // add random sushi pieces to the sushi tower
        
        for _ in 1 ... total {
            // Need to access last piece properties
            let lastPiece = sushiTower.last!
            
            // Need to ensure we don't create impossible sushi structure
            if lastPiece.side != .none {
                addTowerPiece(side: .none)
            } else {
                let rand = Int.random(in: 0 ... 100)
                
                if rand < 45 {
                    // 45 % Chance of a left piece
                    addTowerPiece(side: .left)
                }else if rand < 90 {
                    addTowerPiece(side: .right)
                }else{
                    // 10% Chance of an empty piece
                    addTowerPiece(side: .none)
                }
            }
        }
    }
    
    func moveTowerDown(){
        var n: CGFloat = 0
        for piece in sushiTower{
            let y = (n * 55) + 215
            piece.position.y -= (piece.position.y - y) * 0.5
            n += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Game not ready to play
        if state == .gameOver || state == .title{
            return
        }
        if state == .ready{
            state = .playing
        }
        // Called when a touch begins
        // We only need a single touch here
        let touch = touches.first!
        // Get touch position in the scene
        let location = touch.location(in: self)
        // Was touch on left/right side of the screen?
        if location.x > size.width/2{
            character.side = .right
        }else{
            character.side = .left
        }
        // Garb sushi piece on top of the base sushi piece, it will always be 'first'
        
        if let firstPiece = sushiTower.first as SushiPiece?{
            // Check character side against sushi piec side (this is our death collision check)
            if character.side == firstPiece.side {
                gameOver()
                // No need to continue as player is dead
                return
            }else{
                // Remove from sushi array
                sushiTower.removeFirst()
                firstPiece.flip(character.side)
                // Add a new sushi piece to the top of the sushi tower
                addRandomPiece(total: 1)
                health += 0.1
                score += 1
                print(score)
            }
        }
        
    }
    
    func gameOver() {
        // Game Over
        state =  .gameOver
        let turnRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.50)
        
        // Turn all the sushi pieces red
        sushiBasePiece.run(turnRed)
        
        for sushiPiece in sushiTower{
            sushiPiece.run(turnRed)
        }
        character.run(turnRed)
        
        playButton.selectedHandler = {
            // Grab reference to the Spritekit view
            let skView = self.view as SKView?
            
            guard let scene = GameScene(fileNamed: "GameScene") as GameScene? else{
                return
            }
            
            scene.scaleMode = .aspectFill
            
            skView?.presentScene(scene)
        }
    }
}
