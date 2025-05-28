//
//  SignUpViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import Foundation

// 0. Customer Error type
struct SignUpError : Identifiable, LocalizedError {
    let id = UUID()
    let errorMessage: String?
}

final class SignUpViewModel : ObservableObject {
    // 1. Form inputs
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var name : String = ""
    @Published var gender : String = ""
    @Published var location : String = ""
    @Published var bio : String = ""
    @Published var dateOfBirth : Date = Date()
    // 2. Error for alerts
    @Published var error: SignUpError?

    
    // 3.1 Computed variable returns true or false if form inputs are valid
    var canSubmit : Bool {
        !name.isEmpty && // Check if name is not empty
        EmailValidator.isValid(email) && // Check valid email format  from helper function from helpers/emailvalidator
        password == confirmPassword && // Check is password entered is the same from computed
        gender != "" && // Check gender is not empty
        location != "" && // Check Location is not empty
        bio != "" // Check is bio is not empty
    }
    
    // 4. TODO: IMPLEMENT SIGNUP
    func signUp() {
        
        if password != confirmPassword {
            error = .init(errorMessage: "Passwords do not match")
            return
        }
    }
}
