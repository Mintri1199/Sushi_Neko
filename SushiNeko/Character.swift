import SpriteKit

class Character: SKSpriteNode {
    let punch = SKAction(named: "Punch")!
    // Character side
    var side: Side = .left{
        didSet{
            if side == .left{
                xScale = 1
                position.x = 70
            }else{
                // An easy way to flip an asset hoirzontally is to invert the X-axis scale
                xScale = -1
                position.x = 252
            }
            // run the punch action
            run(punch)
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
