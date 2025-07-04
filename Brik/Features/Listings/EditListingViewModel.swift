//
//  ListingViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 15/6/2025.
//

import Foundation
import PhotosUI

@MainActor
final class EditListingViewModel: ObservableObject {
    
    // TEXT FIELD BINDINGS
    @Published var description: String = ""
    @Published var location: String = ""
    @Published var rentPriceWeekly: Double = 0.0
    @Published var availabilityDate: Date = Date()
    @Published var petsAllowed: Bool = false
    
    // PHOTO PICKER BINDINGS
    @Published var existingImgURLs: [String] = []
    @Published var replacedImages: [Int: UIImage] = [:]

    // ERROR MSGS
    @Published var isSaving = false
    @Published var errorMessage : String? = nil

    // PRIVATE PROPERTIES
    private var existinglisting: Listing?
    
    // COMPUTED PROPERTIES
    var isCreatingNewListing: Bool {
        existinglisting == nil
    }
    
    var screenTitle: String {
        isCreatingNewListing ? "Create Listing" : "Edit Listing"
    }
    
    var saveButtonTitle: String {
        isCreatingNewListing ? "Create" : "Save"
    }
    
    // INITIALISATION
    init() {
        self.existinglisting = nil
        setUpNewListing()
    }
    
    init(listing: Listing) {
        self.existinglisting = listing
        populateFields(from: listing)
    }
    
    private func setUpNewListing() {
        description = ""
        location = ""
        rentPriceWeekly = 0.0
        availabilityDate = Date()
        petsAllowed = false
        existingImgURLs = []
        replacedImages = [:]
    }
    
    private func populateFields(from listing: Listing) {
        description = listing.description
        location = listing.location
        rentPriceWeekly = Double(listing.rentPriceWeekly) ?? 0.00
        petsAllowed = listing.petsAllowed
        existingImgURLs = listing.imageUrls
        replacedImages = [:]
        
        // convert string to date
        if let date = ISO8601DateFormatter().date(from: listing.availabilityDate) {
            availabilityDate = date
        }
    }
    
    // VALIDATION
     private func validateForm() -> Bool {
        errorMessage = nil
         
         if description == "" {
             errorMessage = "Description is required."
             return false
         }
         
         if location == "" {
             errorMessage = "Location is required."
             return false
         }
         
         if rentPriceWeekly < 0 {
            errorMessage = "Rent price must be non-negative."
            return false
         }
         
         return true
    }
    
    func saveListing() async {
        guard validateForm() else {
            return
        }
                
        isSaving = true
        defer {isSaving = false}
        
        guard let token = KeychainHelper.standard.retrieveToken() else {
            errorMessage = "Could not authenticate. Please try logging in again."
            return
        }
        
        errorMessage = nil
        
        let listing = ListingsRequest(
            description: description,
            location: location,
            rentPriceWeekly: rentPriceWeekly,
            availabilityDate: ISO8601DateFormatter().string(from: availabilityDate),
            petsAllowed: petsAllowed)
        
        do {
            // CREATE A NEW LISTING
            if isCreatingNewListing {
                let newImages = Array(replacedImages.values)
                
                _ = try await ListingsService.shared.createListing(token: token, listing: listing, images: newImages)
                print("new listing created")
            }
            else {
                // UPDATE EXISTING LISTING
                _ = try await ListingsService.shared.updateListing(token: token, listing: listing, updatedImages: replacedImages)
                
                print ("listing updated")
            }
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
}

