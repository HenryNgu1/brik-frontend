//
//  LoginViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import Foundation

// 0. Custom error type
struct LoginError : Identifiable, Error {
    let id = UUID()
    var errorMessage: String?
}

final class LoginViewModel : ObservableObject {
    // 1. FORM INPUTS
    @Published var email: String = ""
    @Published var password: String = ""
    
    // 2. UI STATE
    @Published var isLoading: Bool = false
    @Published var currentUser: User? = nil
    
    // 3. ERROR MESSAGES
    @Published var errorMessage: String? = nil
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    
    // Reference the session manager via EnvironmentObject or pass it in:
    private let session = SessionManager.shared
    
    // 4. CANSUBMIT : computed variable bool
    var canSubmit: Bool {
        emailError == nil &&
        passwordError == nil
        }
    
    // 5. Construct error messages
    func validateFields() {
        
        // EMAIL ERROR MESSAGES
        if !EmailValidator.isValid(email) {
            emailError = "Please enter a valid email."
        }
        else if email.isEmpty {
            emailError = "Email is required."
        }
        else {
            emailError = nil
        }
        
        // PW ERROR MESSAGES
        if password.isEmpty{
            passwordError = "Password is required."
        }
        else {
            passwordError = nil
        }
    }
    @MainActor
    func login() async {
        // 1. Guard validation
        guard canSubmit else {
            errorMessage = "Username or password is incorrect."
            return
        }
        
        // 1.1. Show loader
        isLoading = true
        
        errorMessage = nil
        
        do {
            // 2. Await the network call and store the response
            let response = try await AuthService.shared.login(email: email, password: password)
            
            //3. Store JWT in keychain and set current user
            session.signIn(user: response.user, token: response.token)
        }
        catch let authError as AuthError {
            // 5.1 Show custom error from AuthError
            errorMessage = authError.errorDescription
        } catch let keychainError as KeychainError {
            // 5.2 If Keychain saving fails
            errorMessage = keychainError.errorDescription
        } catch {
            // 5.3  Any other unknown error
            errorMessage = "Login failed: \(error.localizedDescription)"
        }

        // 6. Always turn off loader
        isLoading = false
    }
}


