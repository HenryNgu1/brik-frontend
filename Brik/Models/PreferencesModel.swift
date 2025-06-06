//
//  PreferenceModel.swift
//  Brik
//
//  Created by Henry Nguyen on 4/6/2025.
//

import Foundation

// Marked as codable to be able to encode and decode for network calls
struct Preferences : Codable {
    var preferedLocation: String
    var minBudget : Int
    var maxBudget : Int
    var petsAllowed : Bool
    var smokingAllowed : Bool
    var minAge : Int
    var maxAge : Int
    var cleanlinessLevel: String
    var lifestyle: String
    
}
