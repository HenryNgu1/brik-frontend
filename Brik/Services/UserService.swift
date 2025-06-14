//
//  UserService.swift
//  Brik
//
//  Created by Henry Nguyen on 12/6/2025.
//

import Foundation
import UIKit

enum UserProfileError: Error, LocalizedError {
    case invalidUrl
    case missingAuthToken
    case invalidResponse(statusCode: Int)
    case serverError(message : String)
    case decodingError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "Failed to construct URL"
        case .missingAuthToken:
            return "No authentication token found"
        case .invalidResponse(statusCode: let code):
            return "Server returned status code \(code)."
        case .serverError(let message):
            return message
        case .decodingError:
            return "Error decoding JSON"
        case .unknown(let err):
            return err.localizedDescription
        }
    }
}

final class UserService
{
    // 1. Singleton instance
    static let shared = UserService()
    
    // 2. endpoint URL
    var baseUrl = URL(string : "http://localhost:3000/user/update")
    
    // 3. Initialise instance
    private init(){}
    
    // UPDATE / PUT REQUEST
    func updateUserProfile(updatedUser: UpdatedUserRequest, profileImage: UIImage? = nil, token: String) async throws -> UpdatedUserResponse {
        
        // 1. Construct URL
        guard let url = baseUrl else {
            throw UserProfileError.invalidUrl
        }
        
        // 2. Build request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // 3. Prepare multipart body
        var form = MultipartBody()
        
        form.addField(name: "name", value: updatedUser.name)
        form.addField(name: "age", value: String(updatedUser.age))
        form.addField(name: "gender", value: updatedUser.gender)
        form.addField(name: "bio", value: updatedUser.bio)
        form.addField(name: "location", value: updatedUser.location)
        
        if let image = profileImage,
            let jpegData = image.jpegData(compressionQuality: 0.7) {
            form.addFile(name: "profileImage", fileName: "profileImage.jpg", mimeType: "image/jpeg", fileData: jpegData)
        }
        
        let bodyData = form.close()
        // Set as the request body
        request.httpBody = bodyData
        
        // 4. Set headers
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(form.contentType, forHTTPHeaderField: "Content-Type")
        
        
        // 5. Network call
        let (data, response) : (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        }
        catch {
            throw UserProfileError.unknown(error)
        }
        
        // 6. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserProfileError.invalidResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw UserProfileError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // 7. Decode the response
        do {
            let decoder = JSONDecoder()
            
            let decodedResponse = try decoder.decode(UpdatedUserResponse.self, from: data)
            return decodedResponse
        }
        catch {
            throw UserProfileError.decodingError
        }
    }
}
