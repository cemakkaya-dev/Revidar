//
//  GameScene.swift
//  Revidar
//
//  Created by Cem Akkaya on 06/06/26.
//

import SpriteKit

private let player = SKSpriteNode(color: .systemBlue,
                                  size: CGSize(width: 32, height: 32))

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(player)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Gameloop'un kalbi. Her frame burasu calisir (60/120 FPS).
        // Bir sonraki adimda buraya delta time (dt) gelecek.
    }
}
