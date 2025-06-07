//
//  ProfileView.swift
//  Brik
//
//  Created by Henry Nguyen on 4/6/2025.
//

import SwiftUI

struct ProfileView: View {
    // Pull in the shared SessionManager to access currentUser
    @EnvironmentObject private var session: SessionManager

    // Date formatter for “member since”
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium            // e.g. “Feb 13, 2023”
        df.timeStyle = .none
        return df
    }()

    var body: some View {
        // Show placeholder if no user is signed in
        ZStack {
            Color("SplashBackground")
                .ignoresSafeArea(edges: .all)
            // 1. Check if is logged in and use that user to display info
            if let user = session.currentUser {
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // 1. Profile Image
                        if let imageUrlString = user.profileImage,
                           let url = URL(string: imageUrlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()   // loading spinner while fetching
                                        .frame(width: 120, height: 120)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                        .accessibilityLabel("\(user.name)’s profile picture")
                                case .failure:
                                    // Fallback placeholder
                                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                                        .resizable()
                                        .foregroundColor(.secondary)
                                        .frame(width: 120, height: 120)
                                        .accessibilityLabel("Failed to load profile image")
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            // No URL → show generic placeholder
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.secondary)
                                .frame(width: 120, height: 120)
                                .accessibilityLabel("Default profile picture")
                        }

                        // 2. User Name & Email
                        Text(user.name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .accessibilityAddTraits(.isHeader)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Email: \(user.email)")

                        // 3. Info
                        VStack(alignment: .leading, spacing: 8) {
                            
                            // 4. EDIT + PREF navigation buttons
                            HStack {
                                NavigationLink {
                                    //EditProfileView()
                                        //.environmentObject(session)
                                } label: {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit Profile")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                }
                                
                                NavigationLink {
                                    PreferencesView()
                                        .environmentObject(session)
                                } label: {
                                    HStack {
                                        Image(systemName: "slider.horizontal.3")
                                        Text("Preferences")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                }
                                
                            }
                            
                            Text("Age")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 12)
                            Text("\(user.age)")
                                .font(.body)
                                .accessibilityLabel("Age, \(user.age)")
                        
                            Text("Gender")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 12)
                            Text(user.gender)
                                .font(.body)
                                .accessibilityLabel("Gender, \(user.gender)")
                        
                            Text("Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 12)
                            Text(user.location)
                                .font(.body)
                                .accessibilityLabel("Location, \(user.location)")
                        
                            Text("About")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 12)
                            Text(user.bio)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel("Bio: \(user.bio)")
                        
//                            HStack {
//                                Text("Rating")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                                Spacer()
//                                HStack(spacing: 2) {
//                                    ForEach(0..<5) { star in
//                                        Image(systemName: star < user.rating ? "star.fill" : "star")
//                                            .foregroundColor(star < user.rating ? .yellow : .gray)
//                                            .accessibilityHidden(true)
//                                    }
//                                }
//                                .accessibilityLabel("Rating: \(user.rating) out of 5 stars")
//                            }
//                            .padding(.top, 12)
                            
                            Text("Member Since")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 12)
                            Text(user.createdAt)
                                
                            
                                
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        
                        Button {
                            session.signOut()
                        } label: {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.vertical, 12)
                        }
                        
                    }
                    .padding()
                }
                
                // No user logged in
            } else {
                // If no user is in session, prompt to log in
                VStack(spacing: 16) {
                    Text("No user logged in")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Button("Go to Login") {
                        session.signOut()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .accessibilityElement(children: .combine)
            }
        }
    }
}



//  Preview with Mock Data
struct ProfileView_Previews: PreviewProvider {
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
            ProfileView()
                .environmentObject(session)
        }
    }
}
