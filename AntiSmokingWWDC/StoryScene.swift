//
//  File.swift
//  AntiSmokingWWDC
//
//  Created by Batch - 1 on 05/02/25.
//

import SwiftUI

struct StoryScene: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Your Smoke-Free Journey")
                .font(.custom("Helvetica Neue", size: 28))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Text("Discover the impact of smoking, explore interactive experiences, and take your first step towards a healthier lifestyle.")
                .font(.custom("Helvetica Neue", size: 18))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .foregroundColor(.gray)
        }
    }
}

struct StoryScene_Previews: PreviewProvider {
    static var previews: some View {
        StoryScene()
    }
}
