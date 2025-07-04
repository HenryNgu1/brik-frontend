//
//  ListingService.swift
//  Brik
//
//  Created by Henry Nguyen on 16/6/2025.
//
import PhotosUI
import Foundation
// Enum of possible errors
enum ListingsError : Error, LocalizedError {
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
            return "Invalid URL"
        case .missingAuthToken:
            return "Missing auth token"
        case .invalidResponse(statusCode: let code):
            return "Invalid response status code: \(code)"
        case .serverError(message: let message):
            return message
        case .decodingError(let error):
            return "Failed to decoding server response: \(error)"
        case .unknown(let error):
            return error.localizedDescription
        case .notFound:
            return "No listing found"
        }
    }
}

final class ListingsService {
    // SINGLETON APPRAOCH
    static let shared = ListingsService()
    
    // Assign root of API endpoint
    private let baseURL = URL(string: "http://localhost:3000")
    
    private init(){}
    
    
    // 1. GET REQUEST: FETCH USER LISTING
    func fetchUserListing(token: String) async throws -> GetListingResponse {
        
        // 1. Construct endpoint path
        guard let url = URL(string: "/user/listings", relativeTo: baseURL) else {
            throw ListingsError.invalidURL
        }
        
        // 2. Create request object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 3. Set auth header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 4. Make network call
        let (data, response) : (Data, URLResponse)
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        }
        catch {
            throw ListingsError.unknown(error)
        }
                            
        // 5. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ListingsError.invalidResponse(statusCode: -1)
        }
        
        // Ensure status code 200-299 before continue
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ListingsError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // 6. Decode from JSON and return data
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(GetListingResponse.self, from: data)
            return decodedResponse
            
        }
        catch {
            throw ListingsError.decodingError(error)
        }
    }
    
    // 2. POST REQUEST: CREATE USER LISTING
    func createListing(token: String, listing: ListingsRequest, images: [UIImage]) async throws {
        
        // 1. Construct endpoint path
        guard let url = URL(string: "/user/listings", relativeTo: baseURL) else {
            throw ListingsError.invalidURL
        }
        
        // 2. Build request object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 3. Set auth header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 4. Build multipart body
        var multipart = MultipartBody()
        
        // 4.1 Add text fields to multipart
        multipart.addField(name: "description", value: listing.description)
        multipart.addField(name: "location", value: listing.location)
        multipart.addField(name: "rentPriceWeekly", value: String(listing.rentPriceWeekly))
        multipart.addField(name: "availabilityDate", value: listing.availabilityDate)
        multipart.addField(name: "petsAllowed", value: String(listing.petsAllowed))
        
        // 4.2 Add image files to multipart
        for (idex, image) in images.prefix(5).enumerated() {
            let fieldName = "listingImage\(idex + 1)"
            let filename = "\(fieldName).jpg"
            let mimeType = "image/jpeg"
            if let data = image.jpegData(compressionQuality: 0.7) {
                multipart.addFile(
                    name: fieldName,
                    fileName: filename,
                    mimeType: mimeType,
                    fileData: data
                )
            }
        }
        
        // 4.3 Finalize the mulitpart body
        request.httpBody = multipart.close()
        request.setValue(multipart.contentType, forHTTPHeaderField: "Content-Type")
        
        // 5. Make network call
        let (_, response) : (Data, URLResponse)
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        }
        catch {
            throw ListingsError.unknown(error)
        }
        
        // 6. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ListingsError.invalidResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ListingsError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
    
    
    // 3. PUT REQUEST: UPDATE USER LISTING
    func updateListing(token: String, listing: ListingsRequest, updatedImages: [Int: UIImage]) async throws {
        
        // 1. Construct endpoint path
        guard let url = URL(string: "/user/listings", relativeTo: baseURL) else {
            throw ListingsError.invalidURL
        }
        
        // 2. Build request object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // 3. Set auth header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 4. Build multipart body
        var multipart = MultipartBody()
        
        // 4.1 Add text fields to multipart
        multipart.addField(name: "description", value: listing.description)
        multipart.addField(name: "location", value: listing.location)
        multipart.addField(name: "rentPriceWeekly", value: String(listing.rentPriceWeekly))
        multipart.addField(name: "availabilityDate", value: listing.availabilityDate)
        multipart.addField(name: "petsAllowed", value: String(listing.petsAllowed))
        
        // 4.2 Add image files to multipart
        for (slot, image) in updatedImages{
            let fieldName = "listingImage\(slot + 1)"
            let filename = "\(fieldName).jpg"
            let mimeType = "image/jpeg"
            if let data = image.jpegData(compressionQuality: 0.7) {
                multipart.addFile(
                    name: fieldName,
                    fileName: filename,
                    mimeType: mimeType,
                    fileData: data
                )
            }
        }
        
        // 4.3 Finalize the mulitpart body
        request.httpBody = multipart.close()
        request.setValue(multipart.contentType, forHTTPHeaderField: "Content-Type")

        // 5. Make network call
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // 6. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response")
            throw ListingsError.invalidResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("Error Status code: \(httpResponse.statusCode)")
            throw ListingsError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
    
    // 3. DELETE REQ: DELETE USER LISTING
    func deleteListing(token: String) async throws {
        
        // 1. Construct endpoint path
        guard let url = URL(string: "/user/listings", relativeTo: baseURL) else {
            throw ListingsError.invalidURL
        }
        
        // 2. Build request object
        var request  = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 3. Execute call
        var (_, response) : (Data, URLResponse)
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        }
        catch {
            throw ListingsError.unknown(error)
        }
        
        // 4. Check status of call
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ListingsError.invalidResponse(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ListingsError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
}




