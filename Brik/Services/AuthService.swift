//
//  AuthService.swift
//  Brik
//
//  Created by Henry Nguyen on 31/5/2025.
//

import Foundation
import UIKit

// Represent errors that can occur in clear way
enum AuthError: Error, LocalizedError {
    // 0. Throwable error types
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError
    case unknown(Error)    
    
    // 0.1 Computed property, returns an error message depending on type of error
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse(let code):
            return "Server returned status code \(code)."
        case .decodingError:
            return "Failed to parse server response."
        case .unknown(let err):
            return err.localizedDescription
        }
    }
}

final class AuthService {
    
    // 1. Singleton instance, only one can exist and shared globally
    static let shared = AuthService()
    
    // 2. URL of backend, we can change this to domain once deployed
    private let baseURL = URL(string: "http://localhost:3000")!
    
    // 3. Private innit, no other files can create an instance enforce singlton
    private init() {}
    
    // LOGIN
    func login(loginRequest: LoginRequest) async throws -> LoginResponse {
        
        // 1. Build the endpoint, concat the baseurl, guard to ensure if it fails exits and throw error
        guard let url = URL(string: "/auth/login", relativeTo: baseURL) else {
            throw AuthError.invalidURL
        }
        
        // 2. Create the request object
        var request = URLRequest(url: url)
        // 2.1 Set http method to post
        request.httpMethod = "POST"
        // 2.3 Add application/json to the header to let server know to parse it as json
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3. Create and set the body for the request. Convert the LoginRequest model into json format
        do {
            request.httpBody = try JSONEncoder().encode(loginRequest)
        }
        catch {
            throw AuthError.unknown(error)
        }
        
        // 4. Execute call
        // 4.1 Result of network call stored here. Data: response body, URLresponse: header
        let (data, response) : (Data, URLResponse)
        do {
            // 4.2 URLSession.shared method performs the network call. Data takes in an argument of type URLRequest
            (data, response) = try await URLSession.shared.data(for: request)
            
            //DEBUG: If you want to see the body of the response
            //            if let text = String(data: data, encoding: .utf8) {
            //                print(" Raw login response:\n", text)
            //            }
        }
        catch {
            throw AuthError.unknown(error)
        }
        
        // 5. Check the status of the call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // 6. Convert the response recieved from the backend from the call from JSON to LoginResponse
        do {
            let decoder = JSONDecoder()
            //decoder.dateDecodingStrategy = .iso8601 // ensure our decoder can decode the date from string to date
            let decodedResponse = try decoder.decode(LoginResponse.self, from: data)
            
            return decodedResponse
        }
        catch {
            throw AuthError.decodingError
        }
        
    }
    
    // SIGNUP
    func signup(signUpRequest: SignUpRequest, profileImage: UIImage? = nil) async throws -> SignUpResponse
    {
        
        // 1. Build the endpoint URL
        guard let url = URL(string: "/auth/register", relativeTo: baseURL) else {
            throw AuthError.invalidURL
        }
        
        // 2. Create a request object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Set the request method to post
        
        // 3. Prepare multi part request
        var form = MultipartBody()
        
        form.addField(name: "email", value: signUpRequest.email)
        form.addField(name: "password", value: signUpRequest.password)
        form.addField(name: "name", value: signUpRequest.name)
        form.addField(name: "age", value: String(signUpRequest.age))
        form.addField(name: "gender", value: signUpRequest.gender)
        form.addField(name: "bio", value: signUpRequest.bio)
        form.addField(name: "location", value: signUpRequest.location)
        
        // Add a file to body if it exists
        if let image = profileImage,
           let jpegData = image.jpegData(compressionQuality: 0.7) {
            form.addFile(name: "profileImage", fileName: "profileImage.jpg", mimeType: "image/jpeg", fileData: jpegData)
        }
        
        let bodyData = form.close()
        
        // Set content type to header
        request.setValue(form.contentType, forHTTPHeaderField: "Content-Type")
        
        // 4.1 Set the request body as the multipart body we built
        request.httpBody = bodyData
        
        // 5. Perform the call
        let (data, response) : (Data, URLResponse) // Store the network call here: data is the body, response is header
        
        // 5.1 Execute the request call and wait for a response
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        }
        catch {
            // 5.2 if error occurs throw
            throw AuthError.unknown(error)
        }
        
        // 5. Check the Status Code
        // 5.1 Attempt to cast the response (URLResponse) into a HTTPURLResponse since this subclass holds the status code info
        guard let httpResponse = response as? HTTPURLResponse else {
            // 5.2 If the cast fails we exit and throw error
            throw AuthError.invalidResponse(statusCode: -1) // -1 indicates that was not valid http response
        }
        
        // 5.3 Check if the statuscode from the call is successful (200-299 codes is successful)
        guard (200...299).contains(httpResponse.statusCode) else {
            // 5.4 If server returns anything outside of that range, throw error
            throw AuthError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        
        // 6. Convert response (JSON) into SignUpReponse format
        do {
            //  6.1 Attempt convert the response into Codable type which SignUpResponse model is type codable
            let decoder = JSONDecoder()
            //decoder.dateDecodingStrategy = .iso8601
            let decodedReponse = try decoder.decode(SignUpResponse.self, from: data)
            return decodedReponse
        }
        catch {
            // 6.2 If this fails throw appropriate error
            throw AuthError.decodingError
        }
    }
}
