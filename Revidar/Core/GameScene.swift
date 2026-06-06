//
//  GameScene.swift
//  Revidar
//
//  Created by Cem Akkaya on 06/06/26.
//

import SpriteKit

private let player = SKSpriteNode(color: .systemBlue, size: CGSize(width: 32, height: 32))
private var pressedKeys = Set<UInt16>()
private var lastUpdateTime: TimeInterval = 0
private let moveSpeed: CGFloat = 300

private enum Key {
    static let w: UInt16 = 13
    static let a: UInt16 = 0
    static let s: UInt16 = 1
    static let d: UInt16 = 2
}

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(player)
    }
    
    override func keyDown(with event: NSEvent) {
        pressedKeys.insert(event.keyCode)
    }
    
    override func keyUp(with event: NSEvent) {
        pressedKeys.remove(event.keyCode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // dt: iki frame arasi gecen sure (saniye)
        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // basili tuslardan ham yon
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        
        if pressedKeys.contains(Key.w) { dy += 1 }
        if pressedKeys.contains(Key.s) { dy -= 1 }
        if pressedKeys.contains(Key.d) { dx += 1 }
        if pressedKeys.contains(Key.a) { dx -= 1 }
        
        // hiz x dt ile pozisyonu guncelle
        player.position.x += dx * moveSpeed * CGFloat(dt)
        player.position.y += dy * moveSpeed * CGFloat(dt)
    }
}
