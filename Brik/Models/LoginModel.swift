//
//  LoginModel.swift
//  Brik
//
//  Created by Henry Nguyen on 6/6/2025.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

// Model the json response we receive from the backend
struct LoginResponse: Codable {
    let token: String
    let user: User
}
