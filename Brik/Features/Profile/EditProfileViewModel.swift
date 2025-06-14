//
//  EditProfileView.swift
//  Brik
//
//  Created by Henry Nguyen on 8/6/2025.
//

import Foundation
import PhotosUI

final class EditProfileViewModel : ObservableObject {
    // 1. INPUTS
    @Published var name : String = ""
    @Published var dateOfBirth: Date = Date()
    @Published var gender: String = ""
    @Published var location: String = ""
    @Published var bio: String = ""
    @Published var profileImage: String? = nil
    @Published var pickedImage : UIImage? 
    
    // 2. UI STATE
    @Published var isLoading: Bool = false
    // 3. ERROR MSGs
    @Published var dateOfBirthErrorMessage: String?
    @Published var errorMessage: String?
    // 4. Set initial values in form from current user
    init () {
        if let user = SessionManager.shared.currentUser {
            name = user.name
            gender = user.gender
            location = user.location
            bio = user.bio
            profileImage = user.profileImage
        }
    }
    // 5. Calculate date to age in int
    var age: Int {
        // Use extended Date years function in Shared/Extensions/DateToAge to get age from birthdate
        dateOfBirth.years()
    }
    
    // 6. Ensure inputs are valid
    func validateFields() {
        if age < 18 {
            dateOfBirthErrorMessage = "You must be 18 years old to use the app."
        }
        else {
            dateOfBirthErrorMessage = nil
        }
    }
    
    var canSubmit: Bool {
        dateOfBirthErrorMessage == nil
    }
    
    // 7. Send and update profile to DB
    @MainActor
    func save() async {
        // 1. Ensure no errors exist before continuing
        guard canSubmit else  {
            errorMessage = "Please fill out all required fields"
            return
        }
        
        // 2. Ensure user is logged in before continuing
        guard let token = KeychainHelper.standard.retrieveToken() else {
            errorMessage = "Failed to authorize. Please log in again."
            return
        }
        
        // 3. Show loader and reset error msg
        isLoading = true
        errorMessage = nil
        
        // 4. Build request body
        let updatedUser = UpdatedUserRequest(
            name: name,
            age: age,
            gender: gender,
            bio: bio,
            location: location
        )
        
        // 5. Try send request and receive response
        do {
            let response = try await UserService.shared.updateUserProfile(updatedUser: updatedUser, profileImage: pickedImage, token: token)
            
            let updatedUser = User(
                id: response.user.id,
                email: response.user.email,
                name: response.user.name,
                age: response.user.age,
                gender: response.user.gender,
                bio: response.user.bio,
                location: response.user.location,
                rating: response.user.rating,
                profileImage: response.user.profileImage,
                createdAt: response.user.createdAt
            )
            SessionManager.shared.currentUser = updatedUser
        }
        catch let userServiceError as UserProfileError {
            errorMessage = userServiceError.errorDescription
        } catch let keychainError as KeychainError {
            errorMessage = keychainError.errorDescription
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
    
        // 6. stop the loader
        isLoading = false
    }
    
    
}
