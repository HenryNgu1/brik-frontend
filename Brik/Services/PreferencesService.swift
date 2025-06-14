//
//  PreferencesService.swift
//  Brik
//
//  Created by Henry Nguyen on 4/6/2025.
//

import Foundation

// Enum of possible errors and error mapping
enum PreferencesError : Error, LocalizedError {
    case invalidURL
    case missingAuthToken
    case invalidResponse(statusCode: Int)
    case serverError(message : String)
    case decodingError(Error)
    case unknown(Error)
    case notFound
    
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
        case .notFound:
            return "No preferences found."
        }
        
    }
}

final class PreferencesService {
    // SINGLETON APPROACH
    static let shared = PreferencesService()
    
    var baseURL = URL(string: "http://localhost:3000/user/preferences")
    private init() {}
    
    // CREATE PREFERENCE RECORD
    func createPreferences(_ preferences: Preferences, token: String) async throws {
        
        // 1. Construct URL
        guard let url = baseURL else {
            throw PreferencesError.invalidURL
        }
    
        // 3. Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 4. Set header, application/json, token; let server know req is in json for parsing and insert token
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 5. Encode preferences model into the body
        do {
            request.httpBody = try JSONEncoder().encode(preferences)
        }
        catch {
            throw PreferencesError.unknown(error)
        }
        
        // 6. Perform network call
        let (_, response) = try await URLSession.shared.data(for: request)
            
        // 7. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PreferencesError.invalidResponse(statusCode: -1)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw PreferencesError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
    
    // FETCH USER PREFERENCES
    func fetchPreferences(token: String) async throws -> Preferences {
        // 1. Construct URL
        guard let url = baseURL else {
            throw PreferencesError.invalidURL
        }
        
        // 2. Build request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 3. Imbed auth token in header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 4. Performm network call
        let (data, response) : (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        }
        catch {
            throw PreferencesError.unknown(error)
        }
        
        // 5. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PreferencesError.invalidResponse(statusCode: -1)
        }
        
        // 6. check If status is successful
        switch httpResponse.statusCode {
            // 7.1 Successful status we break
        case 200...299:
            break
        case 404:
            // 7.2 404 means no records found
            throw PreferencesError.notFound
        default :
            throw PreferencesError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // 7. Attempt to decode response
        do {
            let decodedResponse = try JSONDecoder().decode(Preferences.self, from: data)
            return decodedResponse
        }
        catch {
            throw PreferencesError.decodingError(error)
        }
    }
    
    // UPDATE PREFERENCE
    func updatePreferences(token: String, preferences: Preferences) async throws {
        // 1. Construct the URL
        guard let url = baseURL else {
            throw PreferencesError.invalidURL
        }
        
        // 2. Build the request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // 3. Imbed auth token and set application/json as header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 4. Encode the preferences to make the body
        do {
            request.httpBody = try JSONEncoder().encode(preferences)
        }
        catch {
            throw PreferencesError.unknown(error)
        }
        
        // 5. Perform network call
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // 6. Check status of response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PreferencesError.invalidResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw PreferencesError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
}
