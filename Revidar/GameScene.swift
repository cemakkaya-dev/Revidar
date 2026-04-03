//
//  GameScene.swift
//  Revidar
//
//  Created by Cem Akkaya on 01/04/26.
//

import SpriteKit
import Combine

class GameScene: SKScene {
    
    let fpsPublisher = PassthroughSubject<String, Never>()
    var lastUpdateTime: TimeInterval = 0
    var player = SKSpriteNode(color: .blue, size: CGSize(width: 32, height: 32))
    let cameraNode = SKCameraNode()
    var cameraLerpSpeed: CGFloat = 5.0
    var playerSpeed: CGFloat = 150
    var moveDirection = CGPoint.zero
    var isJoystickActive: Bool = false
    var joystickBase = SKShapeNode()
    var joystickThumb = SKShapeNode()
    var smoothedDT: TimeInterval = 1.0 / 60.0
    
    #if os(iOS)
    var joystickTouch: UITouch?
    #endif
    
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
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = player.position
        
        joystickBase = SKShapeNode(circleOfRadius: 60)
        joystickThumb = SKShapeNode(circleOfRadius: 25)
        
        joystickBase.position = CGPoint(x: -280, y: -80)
        joystickThumb.position = CGPoint(x: -280, y: -80)
        
        joystickBase.fillColor = .red
        joystickBase.strokeColor = .blue
        
        cameraNode.addChild(joystickBase)
        cameraNode.addChild(joystickThumb)
        
        let fpsLabel = SKLabelNode(fontNamed: "Courier")
        fpsLabel.name = "fpsLabel"
        fpsLabel.fontSize = 14
        fpsLabel.fontColor = .green
        fpsLabel.horizontalAlignmentMode = .left
        fpsLabel.zPosition = 100
        fpsLabel.position = CGPoint(x: -390, y: 200)
        fpsLabel.text = "FPS: --"
        
        cameraNode.addChild(fpsLabel)
    }
    
    // MARK: - Shared Joystick Logic
    
    private func joystickBegan(at location: CGPoint) {
        if joystickBase.contains(location) {
            isJoystickActive = true
        }
    }
    
    private func joystickMoved(to location: CGPoint) {
        guard isJoystickActive else { return }
        
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
        
        let deadZone: CGFloat = maxRadius * 0.15
        
        if distance < deadZone {
            moveDirection = .zero
        } else {
            let adjustDistance = (distance - deadZone) / (maxRadius - deadZone)
            let direction = CGPoint(x: dx / distance, y: dy / distance)
            moveDirection = CGPoint(x: direction.x * adjustDistance, y: direction.y * adjustDistance)
        }
    }
    
    private func joystickEnded() {
        isJoystickActive = false
        joystickThumb.position = joystickBase.position
        moveDirection = .zero
        #if os(iOS)
        joystickTouch = nil
        #endif
    }
    
    // MARK: - iOS Touch Handling
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: cameraNode)
            if joystickTouch == nil && joystickBase.contains(location) {
                joystickTouch = touch
                joystickBegan(at: location)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = joystickTouch, touches.contains(touch) else { return }
        joystickMoved(to: touch.location(in: cameraNode))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = joystickTouch, touches.contains(touch) {
            joystickEnded()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    #endif
    
    // MARK: - macOS Mouse Handling
    
    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        joystickBegan(at: event.location(in: cameraNode))
    }
    
    override func mouseDragged(with event: NSEvent) {
        joystickMoved(to: event.location(in: cameraNode))
    }
    
    override func mouseUp(with event: NSEvent) {
        joystickEnded()
    }
    #endif
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime
        
        if isJoystickActive {
            player.position.x += moveDirection.x * playerSpeed * dt
            player.position.y += moveDirection.y * playerSpeed * dt
        }
        
        let lerpT = cameraLerpSpeed * CGFloat(dt)
        cameraNode.position.x += (player.position.x - cameraNode.position.x) * lerpT
        cameraNode.position.y += (player.position.y - cameraNode.position.y) * lerpT
        
        smoothedDT += (dt - smoothedDT) * 0.1
        
        let fps = smoothedDT > 0 ? Int(1.0 / smoothedDT) : 0
        let ms = smoothedDT * 1000
        fpsPublisher.send(String(format: "FPS: %d | %.1fms", fps, ms))
    }
}
