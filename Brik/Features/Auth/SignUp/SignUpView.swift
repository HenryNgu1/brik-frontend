//
//  SignUp.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    
    // 0. viewModel
    @StateObject var viewModel = SignUpViewModel()
    
    var body: some View {
        // 1. Z stack allows layered content
        ZStack{
            // 1.1 Set background color
            Color("SplashBackground")
                .ignoresSafeArea() // Fill entire screen
            
            ScrollView(.vertical, showsIndicators: false) { // Allow contents to be scrollable
                
                // 2. Stack contents vertically and align centre
                VStack(spacing: 12){
                    
                    // 3. Image
                    Image("AppLogo")
                        .resizable() // Allow for resizing of image
                        .frame(width: 70, height: 70) // Image size
                        .padding() // auto padding
                    
                    // 2.3 Log in text
                    Text("Create an account to continue")
                        .font(.subheadline) // Set font size
                        .foregroundColor(.secondary) // Set font color
                        .padding(.bottom, 10)
                    
                    // 6. Stack contents vertically and space each element
                    Group {
                        
                        // 6.1 Name
                        TextField("Name", text: $viewModel.name)
                            .textContentType(.name)
                            .padding( )
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        
                        
                        // 6.1 Email text field
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress) // text swift this is an email address
                            .textContentType(.emailAddress) // allows for access to stored emails
                            .autocapitalization(.none) // stops first letter being capitalized
                            .padding() //padding
                            .background(Color(.secondarySystemBackground)) // color
                            .cornerRadius(8) //rounded corners
                        
                        // 6.2 Password TextField
                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.newPassword) // Enables password autofill
                            .padding( ) // Padding
                            .background(Color(.secondarySystemBackground)) // Background color
                            .cornerRadius(8) // Rounded corners
                        
                        // 6.3 Confirm Password input
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .autocapitalization(.none)
                            .padding( )
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        
                        // 6.4 Date picker
                        DatePicker("Date of Birth", selection: $viewModel.dateOfBirth, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact) // compact style fits form
                            .padding() // Padding
                            .background(Color(.secondarySystemBackground)) // Color
                            .cornerRadius(8) // Rounded corners
                        
                        // 6.5 Gender option
                        Picker("Gender", selection: $viewModel.gender) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                            Text("Other").tag("Other")
                        }
                        .pickerStyle(.segmented) // Style
                        .background(Color(.secondarySystemBackground)) // Color
                        .cornerRadius(8) // Rounded corners
                        
                        // 7. Location input
                        TextField("Location (e.g. City)", text: $viewModel.location)
                            .textContentType(.fullStreetAddress) // best-fit autofill hint
                            .padding() // auto padding
                            .background(Color(.secondarySystemBackground)) // color
                            .cornerRadius(8) //rounded corners
                        
                        // 8. Bio input area
                        VStack {
                            // 8.1 Static user prompt
                            Text("Tell us about yourself…")
                                .foregroundColor(.secondary) // color
                                .padding(.horizontal, 8) // left/right padding
                                .padding(.top, 12) // top padding
                            
                            // 8.2 user input
                            TextEditor(text: $viewModel.bio)
                                .frame(minHeight: 90) // ensure tappable area
                                .padding(4) // padding
                                .cornerRadius(8) // rounded corners
                        }
                        .background(Color(.secondarySystemBackground)) // color for bio area
                        .cornerRadius(8) // rounded corners
                        
                        // 4. Submit button
                        Button(action: {
                            // 4.1 Call login function to attempt to login from LoginViewModel
                            viewModel.signUp()
                        }) {
                            Text("Sign Up")
                                .font(.headline) // Text font
                                .foregroundColor(.white) //Text color
                                .padding() // Auto padding
                                .background(Color.blue) // Button color
                                .cornerRadius(8) // Rounded button corners
                        }.padding(.top, 16) // Top button padding
                    }
                    .padding(.horizontal, 24) // Padding for input vertical stack
                    
                    // 9. Stack contents horizontally
                    HStack {
                        // 9.1. Static text if users already have account
                        Text("Already have an account?")
                            .font(.footnote) // font
                            .foregroundColor(.secondary) //font color
                        
                        // 9.2. Link to go back to log in page
                        NavigationLink(destination: LoginView()) {
                            Text("Log in")
                                .font(.footnote) // font
                                .fontWeight(.semibold) //font weight
                                .foregroundColor(Color(.blue)) // font color
                        }
                    }
                    .padding(24) // padding for main vertical stack
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
