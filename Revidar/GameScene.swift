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
    var joystickTouch: UITouch?
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
        for touch in touches {
            let location = touch.location(in: self)
            if joystickTouch == nil && joystickBase.contains(location) {
                joystickTouch = touch
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = joystickTouch, touches.contains(touch) else { return }
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
        
        if distance < 1.0 {
            moveDirection = .zero
        } else {
            // Normalize by maxRadius for analog feel (partial press = slower speed)
            moveDirection = CGPoint(x: dx / maxRadius, y: dy / maxRadius)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = joystickTouch, touches.contains(touch) {
            joystickTouch = nil
            joystickThumb.position = CGPoint(x: 120, y: 220)
            moveDirection = .zero
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Clamp dt to max 2 frames to prevent position spikes on frame drops
        let dt = min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime
        
        guard joystickTouch != nil else { return }
        
        player.position.x += moveDirection.x * playerSpeed * dt
        player.position.y += moveDirection.y * playerSpeed * dt
        
        
    }
}
