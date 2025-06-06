//
//  PreferencesService.swift
//  Brik
//
//  Created by Henry Nguyen on 4/6/2025.
//

import Foundation

// Enum of possible errors
enum PreferencesError : Error, LocalizedError {
    case invalidURL
    case missingAuthToken
    case invalidResponse(statusCode: Int)
    case serverError(message : String)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Failed to construct preferences URL."
        case .missingAuthToken:
            return "No authentication token found."
        case .invalidResponse(let code):
            return "Server returned status code \(code)."
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to decode server response."
        case .unknown(let err):
            return err.localizedDescription
        }
    }
}

final class PreferencesService {
    // Singleton approach
    static let shared = PreferencesService()
    var baseURL = URL(string: "http://localhost:3000/User/Preferences")
    private init() {}
    
    // Save preferences function
    func savePreferences(_ preferences: Preferences) async throws -> Preferences {
        
        // 1. Construct URL
        guard let url = baseURL else {
            throw PreferencesError.invalidURL
        }
        
        // 2. Retrieve JWT token
        guard let token = KeychainHelper.standard.retrieveToken() else {
            throw PreferencesError.missingAuthToken
        }
        
        // 3. Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 4. Set header, application/json, token; let server know req is in json for parsing and insert token
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 5. Encode preferences as JSON, turn preferences model into json format
        do {
            request.httpBody = try JSONEncoder().encode(preferences)
        }
        catch {
            throw PreferencesError.decodingError(error)
        }
        // 6. Perform network call
        let (data, response) : (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        }
        catch {
            throw PreferencesError.unknown(error)
        }
        // 7. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PreferencesError.invalidResponse(statusCode: -1)
        }
        
        // 8. If status is successful return response
        guard (200...299).contains(httpResponse.statusCode) else {
            throw PreferencesError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // 9. Attempt to decode server response and return
        do {
            let decodedResponse = try JSONDecoder().decode(Preferences.self, from: data)
            return decodedResponse
        }
        catch {
            throw PreferencesError.decodingError(error)
        }
    }
    
}
