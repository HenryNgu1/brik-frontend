//
//  LoginViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import Foundation

struct LoginError : Identifiable, Error {
    var id: String = UUID().uuidString
    var errorMessage: String
}

final class LoginViewModel : ObservableObject {

    // 1. Share email, password and login data that other views can observe
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var loginError: LoginError?
    
    // 2. variable that indicates if user can login
    var canSubmit: Bool {

        // 2.1 check email is valid using helper function from "EmailValidator"
        EmailValidator.isValid(email) && email.count > 6
        }

    // 3. TODO:
    func login() {
        if email.isEmpty || password.isEmpty {
            loginError = LoginError(errorMessage: "Email and password are required.")
            return
        }
    }
}


