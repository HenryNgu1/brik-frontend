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
    @State private var showImagePicker = false
    
    
    var body: some View {
        ZStack {
            Color("SplashBackground")
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                
                // 1. IMAGE COMPONENT
                ZStack(alignment: .centerFirstTextBaseline) {
                    // 1.1 If user has picked image, show this image
                    if let uiImage = viewModel.pickedImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 120, height: 120)
                            .scaledToFill()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            
                        // 1.2 If user already has an image saved show this image
                    } else if let urlString = viewModel.profileImage,
                                let url = URL(string: urlString) {
                        // 1.2.1 Try fetch image
                        AsyncImage(url: url) { phase in
                              switch phase {
                                  // if image is still loading show loading
                              case .empty:
                                ProgressView()
                                  // if image loads successfully show swftui image
                              case .success(let image):
                                image
                                  .resizable()
                                  .scaledToFill()
                                  // if image fails(bad network, bad url etc) load show caution image
                              case .failure:
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                  .resizable()
                                  .foregroundColor(.secondary)
                                  // if any other case show empty view
                              @unknown default:
                                EmptyView()
                              }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        // 1.3 If user has no saved or no picked image show default
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.secondary)
                    }
                    
                    // 1.4 Change Photo overlay
                    Text("Change Photo")
                        .font(.caption2)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(6)
                }
                .frame(width: 120, height: 120)
                // 1.5 On click show image picker
                .onTapGesture {
                    showImagePicker = true
                }
                .sheet(isPresented: $showImagePicker){
                    ImagePicker(selectedImage: $viewModel.pickedImage)
                }
                .padding()
                
                VStack(alignment: .leading){
                    
                    // 2. NAME FIELD
                    // 2.1 Edit text
                    Text("Edit Name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    // 2.1 Input field
                    TextField("Name", text: $viewModel.name)
                        .textContentType(.name)
                        .padding( )
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray .opacity(0.5), lineWidth: 1)
                        )
                    
                    // 3. LOCATION FIELD
                    // 3.1 Edit text
                    Text("Edit Surburb")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    // 3.2 Input field
                    TextField("Suburb", text: $viewModel.location)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray .opacity(0.5), lineWidth: 1)
                        )
                    
                    // 4. DATE FIELD
                    // 4.1 Edit text
                    Text("Edit Date of Birth")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    // 4.1 Input field
                    DatePicker("Date of Birth", selection: $viewModel.dateOfBirth, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact) // compact style fits form
                        .padding() // Padding
                        .background(Color(.secondarySystemBackground)) // Color
                        .cornerRadius(8) // Rounded corners
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.dateOfBirthErrorMessage == nil
                                        ? Color.gray.opacity(0.5)
                                        : Color.red,
                                        lineWidth: 1)
                        )
                        // 4.2 DOB error message
                    if let error: String = viewModel.dateOfBirthErrorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.bottom, 10)
                    }
                        
                    
                    // 5. GENDER FIELD
                    // 5.1 Edit text
                    Text("Edit Gender")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    // 5.1 Input field
                    Picker("Gender", selection: $viewModel.gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(.segmented) // Style
                    .background(Color(.secondarySystemBackground)) // Color
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray .opacity(0.5), lineWidth: 1)
                    )
                    
                    // 6. BIO FIELD
                    VStack(alignment: .leading) {
                        // 6.1 Edit bio text
                        Text("Edit about yourself...")
                            .foregroundColor(.secondary) // color
                            .padding(.horizontal, 8) // left/right padding
                            .padding(.top, 12) // top padding
                        
                        // 6.2 Input box
                        TextEditor(text: $viewModel.bio)
                            .frame(minHeight: 90) // ensure tappable area
                            .padding(4) // padding
                            .cornerRadius(8) // rounded corners
                            
                    }
                    .background(Color(.secondarySystemBackground)) // color for bio area
                    .cornerRadius(8) // rounded corners
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray .opacity(0.5), lineWidth: 1)
                    )
                    .padding(.top, 24)
                }
                .padding()
                
                // Server and service error messages
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            
                // 7. SAVE BUTTON
                Button(action: {
                    viewModel.validateFields()
                    Task {
                        await viewModel.save()
                    }
                }) {
                    if (viewModel.isLoading)
                    {
                        // Show loader in button while executing network call
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    else {
                        // Show "Save Preferences" in button if not executing call
                        Text("Save Preferences")
                            .font(.headline) // Text font
                            .foregroundColor(.white) // Text color
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 32)
                
            }
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
