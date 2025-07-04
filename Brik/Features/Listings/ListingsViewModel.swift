//
//  ListingViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 17/6/2025.
//

import Foundation

final class ListingsViewModel : ObservableObject {
    // LISTING BINDING
    @Published var currentListing: Listing?
    
    // UI STATE
    @Published var isLoading = false
    @Published var errorMessage : String? = nil
    @Published var showDeleteConfirmation = false
    
    // On initialisation fetch the listing and assign it to currentlisting
    init() {
        Task {
            await fetchListing()
        }
    }
    
    @MainActor
    func fetchListing() async {
        // Show loader
        isLoading = true
        defer {isLoading = false} // stop loader when method exits
        
        // 1. Retrieve auth token
        guard let token = KeychainHelper.standard.retrieveToken() else {
            errorMessage = "Failed to retrieve token"
            return
        }
        // Reset error message
        errorMessage = nil
        
        // 2. Attempt to get listing
        do {
            // Fetch listing
            let fetchedListing = try await ListingsService.shared.fetchUserListing(token: token)
            // Bound listing to UI
            currentListing = fetchedListing.listing
        }
        catch {
            currentListing = nil
            errorMessage = error.localizedDescription
        }

    }
    
    func deleteListing() async {
        // Show loader stop when function exits
        isLoading = true
        defer {isLoading = false}
        
        // 1. Attempt to retrieve token
        guard let token = KeychainHelper.standard.retrieveToken() else {
            errorMessage = "Failed to retrieve token"
            return
        }
        
        // Reset error message
        errorMessage = nil
        
        // 3. Attempt to delete listing
        do {
            try await ListingsService.shared.deleteListing(token: token)
            currentListing = nil
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
}
