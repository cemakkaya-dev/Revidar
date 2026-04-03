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
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    GameContainerView()
}
