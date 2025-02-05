//
//  File.swift
//  AntiSmokingWWDC
//
//  Created by Batch - 1 on 05/02/25.
//

import SwiftUI
import SpriteKit
struct HomeView: View {
    var body: some View {
        SpriteView(scene: StoryScene(size: CGSize(width: 400, height: 600)))
            .ignoresSafeArea()
    }
}
