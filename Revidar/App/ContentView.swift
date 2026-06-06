//
//  ContentView.swift
//  Revidar
//
//  Created by Cem Akkaya on 06/06/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    // Closure ile tek seferde kuruyoruz. Computed property kullansaydik
    // her redraw'da sahne yeniden yaratilirdi - klasik tuzak
    let scene: GameScene = {
        let scene = GameScene()
        scene.size = CGSize(width: 960, height: 540)
        scene.scaleMode = .aspectFill
        return scene
    }()
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
