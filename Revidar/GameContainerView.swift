//
//  ContentView.swift
//  Revidar
//
//  Created by Cem Akkaya on 01/04/26.
//

import SwiftUI
import SpriteKit

struct GameContainerView: View {
    
    @State private var scene = GameScene(size: CGSize(width: 800, height: 600))
    @State private var fpsText = "FPS: --"
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            SpriteView(scene: scene)
                .ignoresSafeArea()
            
            Text(fpsText)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.green)
                .padding(8)
        }
        .onReceive(scene.fpsPublisher) { text in
            fpsText = text
        }
    }
}

#Preview {
    GameContainerView()
}
