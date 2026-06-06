//
//  GameScene.swift
//  Revidar
//
//  Created by Cem Akkaya on 06/06/26.
//

import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray     // bos zemin - simdilik bu kadar
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Gameloop'un kalbi. Her frame burasu calisir (60/120 FPS).
        // Bir sonraki adimda buraya delta time (dt) gelecek.
    }
}
