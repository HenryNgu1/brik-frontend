//
//  EditProfileView.swift
//  Brik
//
//  Created by Henry Nguyen on 8/6/2025.
//

import Foundation
final class EditProfileViewModel : ObservableObject {
    @Published var location: String = ""
    @Published var bio: String = ""
    @Published var profileImageURL: String? = nil
    
    // Set initial values from current user
    init () {
        if let user = SessionManager.shared.currentUser {
            self.location = user.location
            self.bio = user.bio
            self.profileImageURL = user.profileImage
        }
    }
    
    func save() {
        
    }
    
    
}
