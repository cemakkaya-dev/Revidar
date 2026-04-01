//
//  ContentView.swift
//  Revidar
//
//  Created by Cem Akkaya on 01/04/26.
//

import SwiftUI
import SpriteKit

struct GameContainerView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 800, height: 600)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    GameContainerView()
}
