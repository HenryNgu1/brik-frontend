//
//  LoginView.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import SwiftUI

struct LoginView : View {
    @EnvironmentObject private var session: SessionManager
    // 0. Track viewModel
    @StateObject private var viewModel = LoginViewModel()
    
    var body : some View {
        NavigationStack {
            // 1. Layers background and content
            ZStack {
                
                // 1.1 Set background color from Assets
                Color("SplashBackground").ignoresSafeArea() // Fill entire screen
                
                // 2. Stacks contents inside vertically and spaces each element by 32
                VStack (spacing: 32) {
                    
                    // 2.1. Logo image
                    Image("AppLogo")
                        .resizable() // Allow for resizing
                        .scaledToFit() // Preserve aspect ratio
                        .frame(width: 120, height: 120) // Set size for image
                        .padding() // Add padding top padding to image
                    
                    // 2.2 Welcome text
                    Text("Welcome")
                        .font(.largeTitle) // Set font
                        .foregroundColor(.primary) // Set font color
                    
                    // 2.3 Log in text
                    Text("Log in to your account to continue")
                        .font(.subheadline) // Set font size
                        .foregroundColor(.secondary) // Set font color
                    
                    // 3. Input fields with 16 spacing
                    VStack(spacing : 16) {
                        
                        // 3.1 Email input section
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress) // Display email keyboard
                            .autocapitalization(.none) // Avoid auto caps
                            .textContentType(.emailAddress) // Autofill for email enabled
                            .padding() // Add default padding
                            .background(Color(.secondarySystemBackground)) // Set input color
                            .cornerRadius(8) // Round corners
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.emailError == nil
                                            ? Color.gray.opacity(0.5)
                                            : Color.red,
                                            lineWidth: 1)
                            )
                        
                        // 3.2 Error message
                        if let error = viewModel.emailError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 3.3. Password section
                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.password)
                            .padding( )
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.passwordError == nil
                                            ? Color.gray.opacity(0.5)
                                            : Color.red,
                                            lineWidth: 1)
                            )
                        
                        // 3.4 PW error message
                        if let error = viewModel.passwordError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 4. Submit button
                        Button(action: {
                            viewModel.validateFields()
                            Task {
                                // 4.1 Call login function to attempt to login from LoginViewModel
                                await viewModel.login()
                            }
                        }) {
                            if viewModel.isLoading {
                                // 4.2 Show progress while login attempt
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
                            }
                            else {
                                // 4.3 Show log in text if no login attempt
                                Text("Log in")
                                    .font(.headline) // Text font
                                    .foregroundColor(.white) //Text color
                                    .padding() // Auto padding
                                    .background(Color.blue) // Button color
                                    .cornerRadius(8) // Rounded button corners
                            }
                        }
                        .padding(.top, 16) // Top button padding
                        .disabled(viewModel.isLoading) 
                            
                    }
                    
                    // 4. Add spacing to push following content the the bottom
                    Spacer()
                    
                    // 4.1 Horizontal layout
                    HStack(spacing: 4) {
                        
                        // 4.2 Static text
                        Text("Don't have an account?")
                            .font(.footnote) //font
                            .foregroundColor(.secondary) // font color
                        
                        // 4.3 Sign up text
                        NavigationLink(destination: SignUpView()) {
                            
                            Text("Sign up") // Text
                                .font(.footnote) // Font
                                .fontWeight(.semibold) // Font weight
                                .foregroundColor(Color(.blue)) // Font color
                        }
                    }
                    .padding(.bottom, 24) // padding for the horizontal stack
                }
                .padding(.horizontal, 24) // padding left/right for the input fields vertical stack
      
            }
        }
        
    }
}
        

#Preview {
    LoginView()
}
