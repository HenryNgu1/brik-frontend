//
//  BrikApp.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import SwiftUI

@main
struct BrikApp: App {
    
    // 1. Track whether the splashScreen is showing
    @State private var isSplashScreenShowing = true
        
    var body: some Scene {
        WindowGroup {
            Group {
                
                // 2. Conditional statement to show which screen to show on start
                
                if isSplashScreenShowing {
                    SplashView() // 2.2 Show Splash Screen
                }
                else {
                    LoginView() // 2.3 Show login screen
                }
            }.onAppear() { // 3. After 2 seconds, hide splash screen with fade animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isSplashScreenShowing = false
                    }
                }
            }
        }
    }
}

