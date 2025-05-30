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
    @StateObject private var autocomplete = SuburbAutoCompleteService()
    // 0.1 state variables
    @State private var genderTouched = false
    @State private var locationTouched = false
    @State private var bioTouched = false
    @State private var nameTouched = false
    @State private var didAttemptSubmit = false
    
    
    var body: some View {
        // 1. Z stack allows layered content
        ZStack{
            // 1.1 Set background color
            Color("SplashBackground")
                .ignoresSafeArea() // Fill entire screen
            
            ScrollView(.vertical, showsIndicators: true) { // Allow contents to be scrollable
                
                // 2. Stack contents vertically and align centre
                VStack(spacing: 16){
                    
                    // 3. Image
                    Image("AppLogo")
                        .resizable() // Allow for resizing of image
                        .frame(width: 90, height: 90) // Image size
                        .padding() // auto padding
                    
                    // 2.3 Log in text
                    Text("Create an account to continue")
                        .font(.subheadline) // Set font size
                        .foregroundColor(.secondary) // Set font color
                        .padding(.bottom, 16)
                    
                    Group {
                        // 3. Name input field
                        TextField("Name", text: $viewModel.name)
                            .textContentType(.name)
                            .padding( )
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        
                        // 3.1 Inline name validation message
                        if viewModel.name.isEmpty && nameTouched {
                            Text("Please enter a name")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 4. Email text field
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress) // text swift this is an email address
                            .textContentType(.emailAddress) // allows for access to stored emails
                            .autocapitalization(.none) // stops first letter being capitalized
                            .padding() //padding
                            .background(Color(.secondarySystemBackground)) // color
                            .cornerRadius(8) //rounded corners
                        
                        // 4.1 Inline email validation
                        if !viewModel.email.isEmpty && !EmailValidator.isValid(viewModel.email){
                            Text("Please enter valid email")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 5. Password TextField
                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.newPassword) // Enables password autofill
                            .padding( ) // Padding
                            .background(Color(.secondarySystemBackground)) // Background color
                            .cornerRadius(8) // Rounded corners
                        
                        // 5.1 Inline password validation
                        if !viewModel.password.isEmpty && viewModel.password.count < 8 {
                            Text("Password must be at least 8 characters long")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 6. Confirm Password input
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .autocapitalization(.none)
                            .padding( )
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        
                        // 6.1 Validation message for confirm pw
                        if didAttemptSubmit && viewModel.password != viewModel.confirmPassword {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 7. Date picker
                        DatePicker("Date of Birth", selection: $viewModel.dateOfBirth, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact) // compact style fits form
                            .padding() // Padding
                            .background(Color(.secondarySystemBackground)) // Color
                            .cornerRadius(8) // Rounded corners
                        
                        if didAttemptSubmit && viewModel.age < 18 {
                            Text("Must be 18 or older")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 8. Gender option
                        Picker("Gender", selection: $viewModel.gender) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                            Text("Other").tag("Other")
                        }
                        .pickerStyle(.segmented) // Style
                        .background(Color(.secondarySystemBackground)) // Color
                        .cornerRadius(8) // Rounded corners
                        .onChange(of: viewModel.gender) {
                            genderTouched = true
                        }
                        
                        // 8.1 Gender validation message
                        if viewModel.gender.isEmpty && genderTouched {
                            Text("Gender is required")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // 9. Suburb input field
                        TextField("Suburb", text: $viewModel.location)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .onChange(of: viewModel.location) {
                                locationTouched = true
                                autocomplete.update(query: viewModel.location)
                            }
                        
                        // 9.1 Location validation
                        if locationTouched && !viewModel.location.isEmpty {
                            if autocomplete.suggestions.isEmpty {
                                Text("Please select a suburb from the list")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // 9.2. Auto suggestions in a scrollable list
                        if !autocomplete.suggestions.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(autocomplete.suggestions, id: \.self) { suburb in
                                        Text(suburb)
                                            .padding(8)
                                            .onTapGesture {
                                                
                                                // 9.3. Set the location and clear suggestions
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
                                        
                        // 10. Bio input area
                        VStack {
                            // 10.1 Static user prompt
                            Text("Tell us about yourself…")
                                .foregroundColor(.secondary) // color
                                .padding(.horizontal, 8) // left/right padding
                                .padding(.top, 12) // top padding
                            
                            // 10.2 user input
                            TextEditor(text: $viewModel.bio)
                                .frame(minHeight: 90) // ensure tappable area
                                .padding(4) // padding
                                .cornerRadius(8) // rounded corners
                                .onChange(of: viewModel.bio){
                                    bioTouched = true
                                }
                            
                            if bioTouched && viewModel.bio.isEmpty{
                                Text("Bio is required")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        .background(Color(.secondarySystemBackground)) // color for bio area
                        .cornerRadius(8) // rounded corners
                        
                        // 11. Submit button
                        Button(action: {
                            didAttemptSubmit = true
                            // 11.1 Call signup function to attempt to sign up from SignUpViewModel
                            viewModel.signUp()
                        }) {
                            Text("Sign Up")
                                .font(.headline) // Text font
                                .foregroundColor(.white) //Text color
                                .padding() // Auto padding
                                .background(Color.blue) // Button color
                                .cornerRadius(8) // Rounded button corners
                        }.padding(.vertical, 24) // Top button padding
                    }
                    
                    // 12. Stack contents horizontally
                    HStack {
                        // 12.1. Static text if users already have account
                        Text("Already have an account?")
                            .font(.footnote) // font
                            .foregroundColor(.secondary) //font color
                        
                        // 10.2. Link to go back to log in page
                        NavigationLink(destination: LoginView()) {
                            Text("Log in")
                                .font(.footnote) // font
                                .fontWeight(.semibold) //font weight
                                .foregroundColor(Color(.blue)) // font color
                        }
                    }
                    .padding(.bottom, 24) // bottom padding for log in link
                }
                .padding(.horizontal, 24) // padding for main vertical stack
            }
        }
    }
}

#Preview {
    SignUpView()
}
