//
//  ListingViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 15/6/2025.
//

/// Manages the form state for viewing/creating/editing/deleting a single Listing.
import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class EditListingViewModel: ObservableObject {
    // TEXT FIELD BINDINGS
    @Published var description: String = ""
    @Published var location: String = ""
    @Published var rentPriceWeekly: String = "" // String for TextField
    @Published var availabilityDate: Date = Date()
    @Published var petsAllowed: Bool = false
    @Published var images: [UIImage] = [] // Loaded UIImages
    
    // PHOTO PICKER BINDINGS
    @Published var showPicker: Bool = false
    @Published var selectedItems: [PhotosPickerItem] = [] // For picker

    // ERROR MSGS
    @Published var isSaving = false
    @Published var errorMessage : String? = nil

    private var existinglisting: Listing?
    
    // 1. Initialize for existing listing
    init(listing: Listing? = nil) {
        
        existinglisting = listing
        
        // Seed fields with existing listing
        description = listing?.description ?? "" // If listing is non nil use left side else use right side value
        location = listing?.location ?? ""
        rentPriceWeekly = listing?.rentPriceWeekly ?? ""
        if let dateStr = listing?.availabilityDate,
           let date = ISO8601DateFormatter().date(from: dateStr) {
            availabilityDate = date
        }
        petsAllowed = listing?.petsAllowed ?? false
    }
    
    // Convert PhotoPicker into UIImage array
    func loadImages() {
        for item in selectedItems {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
        }
    }
    
    func saveListing() async {
        isSaving = true
        defer {isSaving = false}
        
        guard let token = KeychainHelper.standard.retrieveToken() else {
            errorMessage = "Could not retrieve token"
            return
        }
        
        errorMessage = nil
        
        let listing = ListingsRequest(
            description: description,
            location: location,
            rentPriceWeekly: Double(rentPriceWeekly) ?? 0,
            availabilityDate: ISO8601DateFormatter().string(from: availabilityDate),
            petsAllowed: petsAllowed)
        
        do {
            if existinglisting == nil {
                // CREATE NEW LISTING
                _ = try await ListingsService.shared.createListing(token: token, listing: listing , images: images)
            }
            else {
                // UPDATE EXISTING LISTING
                _ = try await ListingsService.shared.updateListing(token: token, listing: listing, images: images)
            }
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
}

