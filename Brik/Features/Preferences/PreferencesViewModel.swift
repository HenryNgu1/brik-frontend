//
//  PreferencesViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 4/6/2025.
//

import Foundation

final class PreferencesViewModel : ObservableObject {
    // INPUTS
    @Published var preferedLocation: String = ""
    @Published var minBudget : String = "0"
    @Published var maxBudget : String = "0"
    @Published var petsAllowed : Bool = false
    @Published var smokingAllowed : Bool = false
    @Published var minAge : Int = 18
    @Published var maxAge : Int = 100
    @Published var cleanlinessLevel : String = "Low"
    @Published var lifeStyle : String = "Quite"
    // UI STATES
    @Published var isLoading : Bool = false
    // ERRORS
    @Published var errorMessage : String? = nil
    @Published var preferedLocationError : String? = nil
    @Published var minbudgetError : String? = nil
    @Published var maxbudgetError : String? = nil
    @Published var petsAllowedError : String? = nil
    @Published var smokingAllowedError : String? = nil
    @Published var minAgeError : String? = nil
    @Published var maxAgeError : String? = nil
    @Published var cleanlinessLevelError : String? = nil
    @Published var lifeStyleError : String? = nil
    
    // FLAG FOR SUBMISSION
    var canSubmit : Bool {
        preferedLocationError == nil &&
        minbudgetError == nil &&
        maxbudgetError == nil &&
        petsAllowedError == nil &&
        smokingAllowedError == nil &&
        minAgeError == nil &&
        maxAgeError == nil &&
        cleanlinessLevelError == nil &&
        lifeStyleError == nil
    }
    
    
    // VALIDATE FIELDS and Assign Error MSG
    func validateFields() {
        if preferedLocation.isEmpty {
            preferedLocationError = "Preffered Location is required"
        } else {
            preferedLocationError = nil
        }
        
        if minAge > maxAge {
            minAgeError = "Must be lower than max age"
        } else {
            minAgeError = nil
        }
        if maxAge < minAge {
            maxAgeError = "Must be higher than min age"
        } else {
            maxAgeError = nil
        }
        
        guard let minB = Int(minBudget), let maxB = Int(maxBudget) else {
            minbudgetError = "Must be a number"
            maxbudgetError = "Must be a number"
            return
        }
        minbudgetError = nil
        maxbudgetError = nil
        
        if minB > maxB {
            minbudgetError = "Must be lower than max budget"
        } else {
            minbudgetError = nil
        }
        
        if maxB < minB {
            maxbudgetError = "Must be higher than min budget"
        }
        else {
            maxbudgetError = nil
        }
    }
    
    // SUBMIT PREFERENCES
    @MainActor
    func createPreferences() async {
        // 1. Return if input is invalid
        guard canSubmit else {
            errorMessage = "Please correct the errors in the form"
            return
        }
        // 2. Convert the budgets (we know validateFields already flagged parse errors)
        guard let minB = Int(minBudget),
              let maxB = Int(maxBudget) else {
            // In practice this shouldn’t happen if validateFields ran,
            // but just in case:
            errorMessage = "Please enter valid numeric budgets"
            return
        }
        
        guard let token = KeychainHelper.standard.retrieveToken() else {
            errorMessage = "Please log in to create preferences"
            return
        }
        
        // 3. Show loader and reset error message
        isLoading = true
        errorMessage = nil
        
        // 4. Build req body
        let preferences = Preferences(
            preferedLocation: preferedLocation,
            minBudget: minB,
            maxBudget: maxB,
            petsAllowed: petsAllowed,
            smokingAllowed: smokingAllowed,
            minAge: minAge,
            maxAge: maxAge,
            cleanlinessLevel: cleanlinessLevel,
            lifestyle: lifeStyle
        )

        // 5. Make request
        do {
            _ = try await PreferencesService.shared.createPreferences(preferences,token: token)
            isLoading = false
        }
        // 6. Catch errors
        catch let prefError as PreferencesError {
            errorMessage = prefError.errorDescription
            isLoading = false
        }
        catch {
            errorMessage = "An error occurred: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    @MainActor
    func loadPreferences() async {
        guard let token = KeychainHelper.standard.retrieveToken() else {
            errorMessage = "Please log in to view preferences"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Try get preferences if they exist
        do {
            // 1. Fetch user preferences
            let preferences = try await PreferencesService.shared.fetchPreferences(token: token)
            
            // 2. Bound fetched preferences to UI
            preferedLocation = preferences.preferedLocation
            minBudget = String(preferences.minBudget)
            maxBudget = String(preferences.maxBudget)
            petsAllowed = preferences.petsAllowed
            smokingAllowed = preferences.smokingAllowed
            minAge = preferences.minAge
            maxAge = preferences.maxAge
            cleanlinessLevel = preferences.cleanlinessLevel
            lifeStyle = preferences.lifestyle
            
        }
        catch let prefError as PreferencesError {
            errorMessage = prefError.errorDescription
        }
        catch {
            errorMessage = "An error occurred: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
