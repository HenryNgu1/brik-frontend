//
//  SignUp.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    
    // 0. SET UP
    @EnvironmentObject private var session : SessionManager
    @StateObject var viewModel = SignUpViewModel()
    @StateObject private var autocomplete = SuburbAutoCompleteService()
    @State private var showImagePicker = false
    
    
    // VIEW CONTENT
    var body: some View {
        
        // 1. Parent layered stack, set bg color + fill entire screen
        ZStack{
            Color("SplashBackground")
                .ignoresSafeArea()

            // 1.1. Allow contents to be scrollable
            ScrollView(.vertical, showsIndicators: true) {
                
                // 1.2. Center and stack contents vertically
                VStack(spacing: 16){
                
                    
                    // 2. LOGO
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .padding(.top, 16)
                    
                    // 3. LOG IN TEXT
                    Text("Create an account to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // FORM INPUTS
                    Group {
                        
                        // 4.1 IMAGE PICKER
                        Group {
                            if let image = viewModel.profileImage {
                                // Show the user’s selected image
                                Image(uiImage: image)
                                    .resizable  ()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            } else {
                                // Show placeholder circle
                                Circle()
                                .fill(Color(.secondarySystemBackground))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Text("Upload profile")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                )
                            }
                        }
                        .onTapGesture {
                        // 4.1 Present the photo picker
                        showImagePicker = true
                        }
                        .padding(.top, 26)
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(selectedImage: $viewModel.profileImage)
                        }
                        
                        // 5. Name input field
                        TextField("Name", text: $viewModel.name)
                            .textContentType(.name)
                            .padding( )
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.nameErrorMessage == nil
                                            ? Color.gray.opacity(0.5)
                                            : Color.red,
                                            lineWidth: 1)
                            )

                        // 5.1 Name validation message
                        if let error: String = viewModel.nameErrorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 6. Email text field
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress) // Text swift this is an email address
                            .textContentType(.emailAddress) // Allows for access to stored emails
                            .autocapitalization(.none) // Stops first letter being capitalized
                            .padding() //padding
                            .background(Color(.secondarySystemBackground)) // color
                            .cornerRadius(8) //rounded corners
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.emailErrorMessage == nil
                                            ? Color.gray.opacity(0.5)
                                            : Color.red,
                                            lineWidth: 1)
                            )
                        
                        // 6.1 Email validation message
                        if let error: String = viewModel.emailErrorMessage{
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 7. Password TextField
                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.newPassword) // Enables password autofill
                            .padding( ) // Padding
                            .background(Color(.secondarySystemBackground)) // Background color
                            .cornerRadius(8) // Rounded corners
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.passwordErrorMessage == nil
                                            ? Color.gray.opacity(0.5)
                                            : Color.red,
                                            lineWidth: 1)
                            )
                        
                        
                        // 7.1 PW validation message
                        if let error: String = viewModel.passwordErrorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 8. Confirm Password input
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .autocapitalization(.none)
                            .padding( )
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.confirmPasswordErrorMessage == nil
                                            ? Color.gray.opacity(0.5)
                                            : Color.red,
                                            lineWidth: 1)
                            )
                        
                        // 8.1 Confirm PW validation message
                        if let error: String = viewModel.confirmPasswordErrorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 9. Date picker
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
                        
                        // 9.1 DOB validation message
                        if let error: String = viewModel.dateOfBirthErrorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 10. Gender option
                        Picker("Gender", selection: $viewModel.gender) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                            Text("Other").tag("Other")
                        }
                        .pickerStyle(.segmented) // Style
                        .background(Color(.secondarySystemBackground)) // Color
                        .cornerRadius(8) // Rounded corners
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.genderErrorMessage == nil
                                        ? Color.gray.opacity(0.5)
                                        : Color.red,
                                        lineWidth: 1)
                        )
                        
                        // 10.1 Gender validation message
                        if let error: String = viewModel.genderErrorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 11. Location input field
                        TextField("Suburb", text: $viewModel.location)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .onChange(of: viewModel.location) {
                                autocomplete.update(query: viewModel.location)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.locationErrorMessage == nil
                                            ? Color.gray.opacity(0.5)
                                            : Color.red,
                                            lineWidth: 1)
                            )
                        
                        // 11.1 Location validation message
                        if let error: String = viewModel.locationErrorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 11.2. Auto suggestions in a scrollable list
                        if !autocomplete.suggestions.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(autocomplete.suggestions, id: \.self) { suburb in
                                        Text(suburb)
                                            .padding(8)
                                            .onTapGesture {
                                                
                                                // 11.3. Set the location and clear suggestions
                                                viewModel.location = suburb
                                                autocomplete.suggestions = []
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemBackground))
                                    }
                                }
                                .cornerRadius(8)
                                .padding(4)
                            }
                            .frame(maxHeight: 150)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            
                        }
                                        
                        VStack {
                            // 12. Bio input area
                            Text("Tell us about yourself…")
                                .foregroundColor(.secondary) // color
                                .padding(.horizontal, 8) // left/right padding
                                .padding(.top, 12) // top padding
                            
                            // 12.1 Input box
                            TextEditor(text: $viewModel.bio)
                                .frame(minHeight: 90) // ensure tappable area
                                .padding(4) // padding
                                .cornerRadius(8) // rounded corners
                                
                        }
                        .background(Color(.secondarySystemBackground)) // color for bio area
                        .cornerRadius(8) // rounded corners
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.bioErrorMessage == nil
                                        ? Color.gray.opacity(0.5)
                                        : Color.red,
                                        lineWidth: 1)
                                       
                        )
                        
                        // 12.2 Bio validation message
                        if let error: String = viewModel.bioErrorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        
                        // 13. Submit button
                        Button(action: {
                            viewModel.validateFields()
                            Task {
                                // 13.1 Attempt to make network call
                                await viewModel.signUp()
                            }
                        }) {
                            
                            if (viewModel.isLoading)
                            {
                                // 13.2 Show loading circle if submitting, else show create text
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            else {
                                Text("Create Account")
                                    .font(.headline) // Text font
                                    .foregroundColor(.white) //Text color
                                    .padding() // Auto padding
                                    .background(Color.blue) // Button color
                                    .cornerRadius(8) // Rounded button corners
                            }
                            
                        }
                        .padding(.top, 24) // Top button padding
                        // 13.3 Disable the button to prevent multiple signup
                        .disabled(viewModel.isLoading)
                            
                    }
                    Spacer()
                    
                    HStack {
                        // 14. Redirect to login in
                        Text("Already have an account?")
                            .font(.footnote) // font
                            .foregroundColor(.secondary) //font color
                        
                        // 14.1. Link to go back to log in page
                        NavigationLink(destination: LoginView()) {
                            Text("Log in")
                                .font(.footnote) // font
                                .fontWeight(.semibold) //font weight
                                .foregroundColor(Color(.blue)) // font color
                        }
                    }
                    .padding(.vertical, 32) // bottom padding for log in link
                }
                .padding(.horizontal, 24) // padding for form vertical stack
            }
        }
    }
}

#Preview {
    SignUpView()
}
