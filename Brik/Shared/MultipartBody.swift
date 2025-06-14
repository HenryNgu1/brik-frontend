//
//  MultipartBodyHelper.swift
//  Brik
//
//  Created by Henry Nguyen on 14/6/2025.
//

import Foundation
// CREATE MULTI PART BODY
struct MultipartBody {
    
    // Boundary string
    let boundary: String
    
    // Raw body data to be returned
    private var body = Data()
    
    // Create a random boundary on initialisation
    init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }
    
    // Content type header to be used in URLRequest
    var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }
    
    // 1. ADD TEXT FIELD TO BODY
    mutating func addField(name: String, value: String) {
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.appendString("\(value)\r\n")
    }
    
    // 2. ADD FILE TO BODY (e.g. image, video, document).
    mutating func addFile(
      name: String,
      fileName: String,
      mimeType: String,
      fileData: Data
    ) {
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.appendString("\r\n")
    }
    
    // Finalize the body by appending the closing boundary.
    func close() -> Data {
        var data = body
        data.appendString("--\(boundary)--\r\n")
        return data
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let d = string.data(using: .utf8) {
            append(d)
        }
    }
}
