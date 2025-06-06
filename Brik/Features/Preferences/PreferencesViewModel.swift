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
    @Published var maxBudget : String = "80000"
    @Published var petsAllowed : Bool = false
    @Published var smokingAllowed : Bool = false
    @Published var minAge : Int = 18
    @Published var maxAge : Int = 100
    @Published var cleanlinessLevel : String = "Medium"
    @Published var lifeStyle : String = "Relaxed"
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
    
    
    // VALIDATE FIELDS
    func validateFields() {
        if preferedLocation.isEmpty {
            preferedLocationError = "Preffered Location is required"
        } else {
            preferedLocationError = nil
        }
        
        if minAge > maxAge {
            minAgeError = "Min Age must be lower than max age"
        } else {
            minAgeError = nil
        }
        if maxAge < minAge {
            maxAgeError = "Max Age must be higher than min age"
        } else {
            maxAgeError = nil
        }
        
        guard let minB = Int(minBudget), let maxB = Int(maxBudget) else {
            minbudgetError = "Min Budget must be a number"
            maxbudgetError = "Max Budget must be a number"
            return
        }
        minbudgetError = nil
        maxbudgetError = nil
        
        if minB > maxB {
            minbudgetError = "Min Budget must be lower than max budget"
        } else {
            minbudgetError = nil
        }
        
        if maxB < minB {
            maxbudgetError = "Max Budget must be higher than min budget"
        }
        else {
            maxbudgetError = nil
        }
    }
    
    @MainActor
    func savePreferences() async {
        // 1. Return if input is invalid
        guard canSubmit else {
            errorMessage = "Please correct the errors in the form"
            return
        }
        
        guard let minB = Int(minBudget) else {
            return
        }
        
        guard let maxB = Int(maxBudget) else {
            return
        }
        
        isLoading = true
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
        
        errorMessage = nil
        isLoading = true
        
        do {
            let _ = try await PreferencesService.shared.savePreferences(preferences)
            isLoading = false
        }
        catch let prefError as PreferencesError {
            errorMessage = prefError.errorDescription
        }
        catch {
            errorMessage = "An error occurred: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    
    
    
    
    
    
}
