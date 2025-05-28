//
//  SplashView.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        
        // 1. ZStack layers the background and content
        ZStack {
            
            // 1.1 Fill entire screen with splash colour
            Color("SplashBackground") // Defined in Assets
                .ignoresSafeArea() // Fills entire screen
            
            // 2. Stack content vertically, automatically centered
            VStack(spacing: 16) {
                
                Image("AppLogo") // Logo image found in Assets
                    .resizable() // Allow resizing
                    .scaledToFit() // Preserve aspect ratio
                    .frame(width : 120, height : 120) // Set width and height of image
                    .accessibilityHidden(true) // Hides this from voice over feature
                
                // 3. Text display slogan, semi bold, semi contrast for minimal feel
                Text("Find your next roomate...")
                    .font(.headline) //font style
                    .foregroundColor(.gray) // text color
                    .accessibilityLabel("Find your next roomate") //for accessibility
            }
        }
    }
}

#Preview {
    SplashView()
}
