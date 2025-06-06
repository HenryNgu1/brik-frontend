//
//  UserModel.swift
//  Brik
//
//  Created by Henry Nguyen on 6/6/2025.
//

import Foundation

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
