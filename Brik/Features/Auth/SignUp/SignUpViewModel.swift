//
//  SignUpViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import Foundation
import SwiftUI

// 0. CUSTOM SIGN UP ERROR TYPE
struct SignUpError : Identifiable, LocalizedError {
    let id = UUID()
    let errorMessage: String?
}

final class SignUpViewModel : ObservableObject {

    // 1. FORM INPUTS
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var name : String = ""
    @Published var gender : String = ""
    @Published var location : String = ""
    @Published var bio : String = ""
    @Published var dateOfBirth : Date = Date()
    @Published var profileImage : UIImage? = nil
    
    // 2. UI STATE
    @Published var isLoading: Bool = false
    @Published var currentUser: User? = nil
    
    // 3. ERROR MESSAGES
    @Published var errorMessage: String?
    @Published var emailErrorMessage: String?
    @Published var passwordErrorMessage: String?
    @Published var confirmPasswordErrorMessage: String?
    @Published var nameErrorMessage: String?
    @Published var genderErrorMessage: String?
    @Published var locationErrorMessage: String?
    @Published var bioErrorMessage: String?
    @Published var dateOfBirthErrorMessage: String?
    
    // 4. AGE: computed variable
    var age: Int {
        // Use extended Date years function in Shared/Extensions/DateToAge to get age from birthdate
        dateOfBirth.years()
    }

    // 5. CAN SUBMIT: validation computed variable
    var canSubmit : Bool {
        !name.isEmpty && // 1. Check if name is not empty
        EmailValidator.isValid(email) && // 2. Check valid email format  from helper function from helpers/emailvalidator
        password == confirmPassword && // 3. Check is password entered is the same from computed
        !gender.isEmpty && // 4. Check gender is not empty
        !location.isEmpty && // 5. Check Location is not empty
        !bio.isEmpty &&// 6. Check is bio is not empty
        age >= 18 // 7. check user is 18 +
    }
    
    // VALIDATION ERROR MESSAGES FUNCTION
    func validateFields() {
        // 1. NAME ERROR
        if name.isEmpty {
            nameErrorMessage = "Name is required"
        }
        else {
            nameErrorMessage = nil
        }
            
        // 2. EMAIL ERROR
        if !EmailValidator.isValid(email) {
            emailErrorMessage = "Please enter a valid email address"
        }
        else if email.isEmpty {
            emailErrorMessage = "Email is required"
        }
        else {
            emailErrorMessage = nil
        }
            
        // 3. PASSWORD ERROR
        if password.isEmpty {
            passwordErrorMessage = "Password is required"
        }
        else if password.count < 8 {
            passwordErrorMessage = "Password must be at least 8 characters long"
        }
        else {
            passwordErrorMessage = nil
        }
        if confirmPassword.isEmpty {
            confirmPasswordErrorMessage = "Confirm password is required"
        }
        else if password != confirmPassword {
            confirmPasswordErrorMessage = "Passwords do not match"
        }
        else {
            confirmPasswordErrorMessage = nil
        }
            
        // 4. GENDER ERROR
        if gender.isEmpty {
            genderErrorMessage = "Gender is required"
        }
        else {
            genderErrorMessage = nil
        }
            
        // 5. AGE ERROR
        if age < 18 {
            dateOfBirthErrorMessage = "You must be 18 years old to sign up"
        }
        else {
            dateOfBirthErrorMessage = nil
        }
            
        // 6. LOCATION ERROR
        if location.isEmpty {
            locationErrorMessage = "Location is required"
        }
        else {
            locationErrorMessage = nil
        }
        
        // 7. BIO ERROR
        if bio.isEmpty {
            bioErrorMessage = "Bio is required"
        }
        else {
            bioErrorMessage = nil
        }        
    }
        
    // SIGNUP FUNCTION
    func signUp() async {
        
        // 1. Check is all required fields have valid input
        guard canSubmit else { return }
        
        // 2. Show loader
        //isLoading = true
            
        do {
            // 3. Await the network call and get response back
            let response = try await AuthService.shared.signup(
                email: email,
                password: password,
                name: name,
                age: age,
                gender: gender,
                bio: bio,
                location: location,
                profileImage: profileImage
            )
                
            // 4. Save JWT in Keychain from response
            try KeychainHelper.standard.SaveToken(response.token)
                
            // 5. Update the current user
            currentUser = response.user
        }
        catch let authError as AuthError {
            // 6.1 If auth error occurs, display error
            print(authError.localizedDescription)
        }
        catch let keychainError as KeychainError{
            // 6.2 If keychain error occurs, display error
            print(keychainError.localizedDescription)
        }
        catch {
            // 6.3 If any other error occurs, display that error
            print("An unexpected error occurred.")
        }
            
        // 7. Stop the loader on the main thread
        //isLoading = false
    }
    
}


