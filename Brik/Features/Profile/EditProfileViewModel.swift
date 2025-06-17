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
    
    // 7. Bool flag ensure no form errors exist before network call
    var canSubmit: Bool {
        dateOfBirthErrorMessage == nil
    }
    
    // 8. UPDATE PROFILE IN DB AND LOCAL CURRENT USER
    @MainActor
    func save() async {
        isLoading = true
        defer {isLoading = false}
        
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
        
        // 3. Reset error msg
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
            // 5.1 Call user service updateuser method to perform network call
            let response = try await UserService.shared.updateUserProfile(updatedUser: updatedUser, profileImage: pickedImage, token: token)
            
            // 5.2 Create updated user object and set it as current user
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
        // 6. Catch errors
        catch let userServiceError as UserProfileError {
            errorMessage = userServiceError.errorDescription
        } catch let keychainError as KeychainError {
            errorMessage = keychainError.errorDescription
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
    }
}
