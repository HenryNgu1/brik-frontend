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
    func login(email: String, password: String) async throws -> LoginResponse {
        
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
            request.httpBody = try JSONEncoder().encode(LoginRequest(email: email, password: password))
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
            let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            return decodedResponse
        }
        catch {
            throw AuthError.decodingError
        }
        
    }
    
    // SIGNUP
    func signup(
        email: String,
        password: String,
        name: String,
        age: Int,
        gender: String,
        bio: String,
        location: String,
        profileImage: UIImage? = nil) async throws -> SignUpResponse
    {
        
        // 1. Build the endpoint URL
        guard let url = URL(string: "/auth/register", relativeTo: baseURL) else {
            throw AuthError.invalidURL
        }
        
        // 2. Create a request object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Set the request method to post
        
        // 3. Prepare boundary for multi part request
        let boundary = UUID().uuidString // Generates random string to seperate image from text fields in body
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        // Header Example: Content-Type: multipart/form-data; boundary=E3A1D4F2-7B15-4C0D-8907-FB3C9A16B2E1
        // Tells server look for boundary string to use as divider
        
        
        // 4. Build multipart body
        let bodyData = try createMultipartBody(
            email: email,
            password: password,
            name: name,
            age: age,
            gender: gender,
            bio: bio,
            location: location,
            profileImage: profileImage,
            boundary: boundary
        )
        
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
            let decodedReponse = try JSONDecoder().decode(SignUpResponse.self, from: data)
            return decodedReponse
        }
        catch {
            // 6.2 If this fails throw appropriate error
            throw AuthError.decodingError
        }
    }
    
    // CREATE MULTI PART BODY
    func createMultipartBody(
        email: String,
        password: String,
        name: String,
        age: Int,
        gender: String,
        bio: String,
        location: String,
        profileImage: UIImage?,
        boundary: String
    ) throws -> Data {
        
        // 1. We will store the body in this data object and build it
        var body = Data();
        
        // Helper function
        func appendText(name : String, value : String) {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
            
            // Example:
            //
            // --XYZ123\r\n                                         <- boundary
            // Content-Disposition: form-data; name="name"\r\n      <- name
            // \r\n
            // value\r\n                                            <- value
        }
        
        // 2. Append text fields to body
        appendText(name: "email", value: email)
        appendText(name: "password", value: password)
        appendText(name: "name", value: name)
        appendText(name: "age", value: String(age))
        appendText(name: "gender", value: gender)
        appendText(name: "bio", value: bio)
        appendText(name: "location", value: location)
        
        // 2.1 Append image if provided / not nil
        if let image = profileImage,
           let imageData = image.jpegData(compressionQuality: 0.7){ // Converts the UI image into JPEG data, 70% quality
            
            let filename = "profileImage.jpg" // Name the server will see for uploaded image
            let mimetype = "image/jpeg" // Tells server what type of file is being uploaded
            
            body.appendString("--\(boundary)\r\n") // Boundary marker to seperate text from image
            body.appendString("Content-Disposition: form-data; name=\"profileImage\"; filename=\"\(filename)\"\r\n") // header
            body.appendString("Content-Type: \(mimetype)\r\n\r\n") // Content type
            body.append(imageData) // Append JPEG bytes
            body.appendString("\r\n") // Append new new line
        }
        
        // 3. We end the multi part body
        body.appendString("--\(boundary)--\r\n")
        return body
    }
}

// EXTENSION: Adding a custom function to swifts Data class
private extension Data {
    
    mutating func appendString(_ string: String) {
        
        // 1. Attempts to convert string to utf8 bytes
        if let data = string.data(using: .utf8) {
            // 2. Append those bytes to the body
            append(data)
        }
    }
}
