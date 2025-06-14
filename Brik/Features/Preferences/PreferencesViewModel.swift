//
//  PreferencesViewModel.swift
//  Brik
//
//  Created by Henry Nguyen on 4/6/2025.
//

import Foundation

final class PreferencesViewModel : ObservableObject {
    // INPUTS
    @Published var preferredLocation: String = ""
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
    @Published private(set) var hasPreferences = false
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
    
    
    // VALIDATE FIELDS AND ASSIGN ERROR MSG
    func validateFields() {
        if preferredLocation.isEmpty {
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
    func savePreferences() async {
        // 1. Ensure inputs are valid
        guard canSubmit else {
            errorMessage = "Please correct the errors in the form"
            return
        }
        // 2. Convert the budgets (we know validateFields already flagged parse errors)
        guard let minB = Int(minBudget),
              let maxB = Int(maxBudget) else {
            errorMessage = "Please enter valid numeric budgets"
            return
        }
        
        // 3. Get auth token
        guard let token = KeychainHelper.standard.retrieveToken() else {
            errorMessage = "Failed to authenticate. Please log in again."
            return
        }
        
        // 3. Show loader and reset error message
        isLoading = true
        errorMessage = nil
        
        // 4. Build req body
        let preferences = Preferences(
            preferredLocation: preferredLocation,
            minBudget: minB,
            maxBudget: maxB,
            petsAllowed: petsAllowed,
            smokingAllowed: smokingAllowed,
            minAge: minAge,
            maxAge: maxAge,
            cleanlinessLevel: cleanlinessLevel,
            lifestyle: lifeStyle
        )

        // 5. Choose POST or PUT request
        do {
            if hasPreferences {
                //5.1 POST request if user has not set preferences
                _ = try await PreferencesService.shared.updatePreferences(token: token, preferences: preferences)
                
            }
            else {
                // 5.2 PUT / update request if user already has preferences
                _ = try await PreferencesService.shared.createPreferences(preferences,token: token)
                hasPreferences = true
            }
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
        // 7. Stop loader
        isLoading = false
    }
    
    // FETCH USER PREFERENCES
    @MainActor
    func loadPreferences() async {
        // 1. Attempt to retrieve token
        guard let token = KeychainHelper.standard.retrieveToken() else {
            errorMessage = "No token found. Please log in to view preferences"
            return
        }
        // 2. Show loader and reset error message
        isLoading = true
        errorMessage = nil
        
        // 3. Try get preferences if they exist
        do {
            // 3.1. Fetch user preferences
            let preferences = try await PreferencesService.shared.fetchPreferences(token: token)
            
            // 3.2. Bound fetched preferences to UI
            preferredLocation = preferences.preferredLocation
            minBudget = String(preferences.minBudget)
            maxBudget = String(preferences.maxBudget)
            petsAllowed = preferences.petsAllowed
            smokingAllowed = preferences.smokingAllowed
            minAge = preferences.minAge
            maxAge = preferences.maxAge
            cleanlinessLevel = preferences.cleanlinessLevel
            lifeStyle = preferences.lifestyle
            
            // 33. Remember user has preferences, set true so PUT request is run in savePreferences()
            hasPreferences = true
        }
        // 4. Catch errors
        catch let prefError as PreferencesError {
            switch prefError {
                // 4.1 If 404 / notFound. Do nothing, user hasnt set chosen pref
            case .notFound:
                errorMessage = " "
            default :
                // 4.2 Map to correct error
                errorMessage = prefError.errorDescription
            }
        }
        catch {
            errorMessage = "An error occurred: \(error.localizedDescription)"
        }
        // 5. Stop the loader
        isLoading = false
    }
}
