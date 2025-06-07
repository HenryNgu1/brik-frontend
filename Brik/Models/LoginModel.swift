//
//  LoginModel.swift
//  Brik
//
//  Created by Henry Nguyen on 6/6/2025.
//

import Foundation
// Req model to send to backend
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// Model response we receive from the backend
struct LoginResponse: Codable {
    let token: String
    let user: User
}
