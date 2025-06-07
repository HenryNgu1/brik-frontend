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


// MOCK DATA for preview
struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        let session = SessionManager()
        session.currentUser = User(
            id: 42,
            email: "user@example.com",
            name: "user user",
            age: 25,
            gender: "Female",
            bio: "I love finding new roommates who share my passion for hiking and board games!",
            location: "Melbourne, Australia",
            rating: "0",
            profileImage: nil,
            createdAt: "tuesday"
        )

        return NavigationView {
            MainTabContainerView()
                .environmentObject(session)
        }
    }
}


