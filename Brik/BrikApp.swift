//
//  BrikApp.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import SwiftUI

@main
struct BrikApp: App {
        
    @StateObject private var session = SessionManager.shared

    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                // After login/sign‐up, show the main tab container:
                MainTabContainerView()
                    .environmentObject(session)
            } else {
                // Otherwise, show the login (or sign‐up) screen:
                LoginView()
                    .environmentObject(session)
            }
        }
    }
}

