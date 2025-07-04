//
//  SessionManager.swift
//  Brik
//
//  Created by Henry Nguyen on 6/6/2025.
//

import Foundation

final class SessionManager : ObservableObject {
    
    static let shared = SessionManager()
    @Published var isLoggedIn: Bool = false
    @Published var currentUser : User? = nil
    
    init() {
        if let _ = KeychainHelper.standard.retrieveToken() {
            self.isLoggedIn = true
        }
        else {
            self.isLoggedIn = false
        }
    }    
    
    func signIn(user: User, token: String) {
        try? KeychainHelper.standard.SaveToken(token)
        self.currentUser = user
        self.isLoggedIn = true
    }
    
    func signOut() {
        try? KeychainHelper.standard.deleteToken()
        self.currentUser = nil
        self.isLoggedIn = false
    }
    
}
