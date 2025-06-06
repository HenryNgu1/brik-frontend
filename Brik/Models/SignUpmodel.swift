//
//  SignUpmodel.swift
//  Brik
//
//  Created by Henry Nguyen on 6/6/2025.
//

import Foundation

// Model of sign in request
struct SignUpRequest: Codable {
    let email: String
    let password: String
    let name: String
    let age: Int
    let gender: String
    let bio: String
    let location: String
}

// Model of the response returned by the backend
struct SignUpResponse : Codable {
    let token: String
    let user: User
}
