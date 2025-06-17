//
//  ListingModel.swift
//  Brik
//
//  Created by Henry Nguyen on 15/6/2025.
//

import Foundation

struct Listing: Decodable {
    let id: Int
    let userId: Int
    let description: String
    let location: String
    let rentPriceWeekly: String
    let availabilityDate: String
    let petsAllowed: Bool
    let imageUrls: [String]
    let createdAt: String
}

struct ListingsRequest: Decodable {
    let description: String
    let location: String
    let rentPriceWeekly: Double
    let availabilityDate: String
    let petsAllowed: Bool
}

struct GetListingResponse : Decodable {
    let listing: Listing
}

