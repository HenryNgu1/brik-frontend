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
    func createPreferences(_ preferences: Preferences, token: String) async throws {
        
        // 1. Construct URL
        guard let url = baseURL else {
            throw PreferencesError.invalidURL
        }
        
//        // 2. Retrieve JWT token
//        guard let token = KeychainHelper.standard.retrieveToken() else {
//            throw PreferencesError.missingAuthToken
//        }
        
        // 3. Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 4. Set header, application/json, token; let server know req is in json for parsing and insert token
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 5. Perform network call
        let (_, response) = try await URLSession.shared.data(for: request)
            
        // 6. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PreferencesError.invalidResponse(statusCode: -1)
        }
        
        // 7. If status is successful return response
        guard (200...299).contains(httpResponse.statusCode) else {
            throw PreferencesError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
    
    func fetchPreferences(token: String) async throws -> Preferences {
        // 1. Contruct URL
        guard let url = baseURL else {
            throw PreferencesError.invalidURL
        }
        
//        // 2. Retrive JWT token
//        guard let token = KeychainHelper.standard.retrieveToken() else {
//            throw PreferencesError.missingAuthToken
//        }
        
        // 3. Build request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 4. Imbed auth token in header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 5. Performm network call
        let (data, response) : (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        }
        catch {
            throw PreferencesError.unknown(error)
        }
        
        // 6. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PreferencesError.invalidResponse(statusCode: -1)
        }
        
        // 7. check If status is successful
        guard (200...299).contains(httpResponse.statusCode) else {
            throw PreferencesError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // 8. Attempt to decode response
        do {
            let decodedResponse = try JSONDecoder().decode(Preferences.self, from: data)
            return decodedResponse
        }
        catch {
            throw PreferencesError.decodingError(error)
        }
    }
}
