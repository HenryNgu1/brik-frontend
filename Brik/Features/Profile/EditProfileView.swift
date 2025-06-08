//
//  EditProfileViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 8/6/2025.
//

import Foundation
import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                
                ZStack(alignment: .centerFirstTextBaseline) {
                    // AsyncImage loads remote image; placeholder if nil or loading
                    if let urlString = viewModel.profileImageURL,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // spinner while loading
                                    .frame(width: 120, height: 120)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            case .failure:
                                // Fallback on error
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.secondary)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        // Default placeholder
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.secondary)
                    }
                    
                    // “Change Photo” overlay (no picker implementation yet)
                    
                    Text("Change Photo")
                        .font(.caption2)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(6)
                        .onTapGesture {
                            // Future: present image picker
                        }
                }
                .frame(width: 120, height: 120)
                
                // Location Field
                Text("Change Location")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                TextField("Location", text: $viewModel.location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)      // Capitalize place names
                    .disableAutocorrection(true)     // Avoid autocorrect mistakes
                Text("Change About section")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                // MARK: — Bio Editor
                ZStack(alignment: .topLeading) {
                    
                    if viewModel.bio.isEmpty {
                        // Placeholder text
                        Text("Tell something about yourself…")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                    }
                    TextEditor(text: $viewModel.bio)
                        .frame(minHeight: 120)
                        .padding(2)
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                
                
                // Save Button (disabled for now)
                Button(action: {
                    viewModel.save()
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.blue)           // Gray until enabled
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(true)                           // Enable once save logic is ready
            }
            .padding()
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Inject a mock user into SessionManager
        let session = SessionManager.shared
        session.currentUser = User(
            id: 1,
            email: "alice@example.com",
            name: "Alice",
            age: 25,
            gender: "Female",
            bio: "Love hiking and board games!",
            location: "Melbourne",
            rating: "jbj",
            profileImage: nil,
            createdAt: "Date()"
        )
        return NavigationView {
            EditProfileView()
                .environmentObject(session)
        }
        .previewDisplayName("Edit Profile")
    }
}
#endif
