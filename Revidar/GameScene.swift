//
//  GameScene.swift
//  Revidar
//
//  Created by Cem Akkaya on 01/04/26.
//

import SpriteKit

class GameScene: SKScene {
    
    var lastUpdateTime: TimeInterval = 0
    var player = SKSpriteNode(color: .blue, size: CGSize(width: 32, height: 32))
    var moveLocation = CGPoint.zero
    var playerSpeed: CGFloat = 150
    var isMoving: Bool = false
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .aspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        
        player.position = CGPoint(x: 400, y: 300)
        player.name = "player"
        addChild(player)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = true
        guard let touch = touches.first else { return }
        moveLocation = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = true
        guard let touch = touches.first else { return }
        moveLocation = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard isMoving else { return }
        
        let dx = moveLocation.x - player.position.x
        let dy = moveLocation.y - player.position.y
        let lenght = sqrt(dx*dx + dy*dy)
        
        guard lenght > 1 else { return }
        
        let normalX = dx / lenght
        let normalY = dy / lenght
        
        player.position.x += normalX * playerSpeed * dt
        player.position.y += normalY * playerSpeed * dt
        
        
    }
}
