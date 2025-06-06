//
//  MainTabContainer.swift
//  Brik
//
//  Created by Henry Nguyen on 6/6/2025.
//

import Foundation
import SwiftUI
struct MainTabContainerView: View {
    @EnvironmentObject var session : SessionManager
    
    var body: some View {
        TabView {
            // 1. Match Tab
            NavigationView {
                MatchView()
                    .navigationBarTitleDisplayMode(.inline)
                    
            }
            .tabItem {
                // Tab icon + label
                Image(systemName: "heart")
                Text("Match")
            }

            // 2. Listings Tab
            NavigationView {
                ListingsView()
                    .navigationBarTitleDisplayMode(.inline)
                    
            }
            .tabItem {
                Image(systemName: "house")
                Text("Listings")
            }

            // 3. Messages Tab
            NavigationView {
                MessagesView()
                    .navigationBarTitleDisplayMode(.inline)
                    
            }
            .tabItem {
                Image(systemName: "bubble.left.and.bubble.right")
                Text("Messages")
            }
            
            // 4. Profile Tab
            NavigationView {
                ProfileView()
                    .navigationBarTitleDisplayMode(.inline)
                    .environmentObject(session)
                    
            }
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
                Text("Profile")
            }
        }
        // 5. Apply accent color to highlight selected tab icon
        .accentColor(.accentColor)
    }
}

#Preview {
    MainTabContainerView()
        .environmentObject(SessionManager())
}


