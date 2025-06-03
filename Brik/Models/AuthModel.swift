//
//  AuthModel.swift
//  Brik
//
//  Created by Henry Nguyen on 31/5/2025.
//

import Foundation

// 1. LOG IN
//
// Model of request we send to backend to create a user
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// Model the json response we receive from the backend
struct LoginResponse: Codable {
    let token: String
    let user: User
}
// 3. USER
//
// Model of user
struct User: Codable {
    let id: Int
    let email: String
    let name: String
    let age: Int
    let gender: String
    let bio: String
    let location: String
    let profileImage: String?
    let rating: Int
    let createdAt: Date
}

// 2. SIGN UP
//
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



