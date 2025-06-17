//
//  PreferenceModel.swift
//  Brik
//
//  Created by Henry Nguyen on 4/6/2025.
//

import Foundation

// Marked as codable to be able to encode and decode for network calls
struct Preferences : Codable {
    let preferredLocation: String
    let minBudget : Int
    let maxBudget : Int
    let petsAllowed : Bool
    let smokingAllowed : Bool
    let minAge : Int
    let maxAge : Int
    let cleanlinessLevel: String
    let lifestyle: String
}
