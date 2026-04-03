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
    var playerSpeed: CGFloat = 150
    var moveDirection = CGPoint.zero
    var isMoving: Bool = false
    var joystickBase = SKShapeNode()
    var joystickThumb = SKShapeNode()
    
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
        
        joystickBase = SKShapeNode(circleOfRadius: 60)
        joystickThumb = SKShapeNode(circleOfRadius: 25)
        
        joystickBase.position = CGPoint(x: 120, y: 220)
        joystickThumb.position = CGPoint(x: 120, y: 220)
        
        joystickBase.fillColor = .red
        joystickBase.strokeColor = .blue
        
        
        addChild(joystickBase)
        addChild(joystickThumb)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if joystickBase.contains(location) {
            isMoving = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isMoving else { return }
        let location = touch.location(in: self)
        
        var dx = location.x - joystickBase.position.x
        var dy = location.y - joystickBase.position.y
        
        let distance = sqrt(dx*dx + dy*dy)
        let maxRadius: CGFloat = 60.0
        
        if distance > maxRadius {
            dx = (dx / distance) * maxRadius
            dy = (dy / distance) * maxRadius
        }
        
        joystickThumb.position = CGPoint(
            x: joystickBase.position.x + dx,
            y: joystickBase.position.y + dy
        )
        
        let deadZone: CGFloat = 10.0
        
        if distance < deadZone {
            moveDirection = .zero
        } else {
            let currentThumbDistance = sqrt(dx*dx + dy*dy)
            moveDirection = CGPoint(x: dx / currentThumbDistance, y: dy / currentThumbDistance)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = false
        joystickThumb.position = CGPoint(x: 120, y: 220)
        moveDirection = .zero
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard isMoving else { return }
        
        player.position.x += moveDirection.x * playerSpeed * dt
        player.position.y += moveDirection.y * playerSpeed * dt
        
        
    }
}
