//
//  LoginView.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import SwiftUI

struct LoginView : View {
    
    // 1. Manage viewModel
    @StateObject private var viewModel = LoginViewModel();

    var body : some View {
        
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
                        .padding(.horizontal, 16) // Add horizontal padding
                    
                    //3.2 Password section
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                        .padding( )
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                }
                
                // 4. Add spacing to push following content the the bottom
                Spacer()
                
                // 4.1 Horizontal layout
                HStack(spacing: 4) {
                    
                    // 4.2 Static text
                    Text("Don't have an account?")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    // 4.3 Sign up text
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign up")
                            .font(.footnote) // font
                            .fontWeight(.semibold) // font weight
                            .foregroundColor(.accentColor) // font color
                    }
                }
                .padding(.bottom, 24)
            }.padding(.horizontal, 24)
        }
    }
}
        

#Preview {
    LoginView()
}
