//
//  KeychainHelper.swift
//  Brik
//
//  Created by Henry Nguyen on 1/6/2025.
//

import Foundation
import Security

// CONTEXT: Keychain is secure storage service from apple
final class KeychainHelper {
    static let standard = KeychainHelper()
    private init() {}
    
    // Try to read the bundle identifier and set it as the service name
    // Keep the service seperate from other and avoid collisions
    private let service = Bundle.main.bundleIdentifier ?? "com.example.Brik"
    
    private let account = "User-Token" // Keychain account where we store the JWT
    
    
    // SAVE TOKEN TO KEYCHAIN, if it already exists, update it
    func SaveToken(_ token: String) throws {
        
        // Convert the token from string to bytes and wrapping in data object since KC only stores raw bytes
        let data = Data(token.utf8)
        
        // 1. Check if the token already exists by attempting to fetch it
        if retrieveToken() != nil {  //1. Update path
            
            // Query Dictionary:
            // Defines Keychain class, service and account attributes
            // that we will use to find exact item and replace it
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            
            // Attributes dictionary:
            // Contains our new data to update KeyChain
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            // Ask Keychain API to replace item matching query with attributes[kSecvalue]
            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            
            // Check if it was successful
            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
            // 2. If token does not exist create a new Keychain item entry
        } else {
            
            // Query Dictionary
            // Defines Keychain attributes
            // We will use to create a new Keychain item
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data
            ]
            
            // Ask Keychain API to insert new item matching the query we defined
            let status = SecItemAdd(query as CFDictionary, nil)
            
            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }
        }
    }
    
    // RETRIEVE TOKEN FROM KEYCHAIN
    func retrieveToken() -> String? {
        
        // 1. Query Dictionary
        // Contains the field values we are searching for in the keychain item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,          // Ask for the Data blob
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        // 2. Ask Keychain API to delete item that matches this query
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8)
                
        else {
            return nil
        }
        return token
    }
    
    // DELETE TOKEN FROM KEYCHAIN
    func deleteToken() throws {
        // 1. Query Dictionary
        // Defines Keychain attributes (class, service, account)
        // that we will use to find the exact item to delete
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        // 2. Ask keychain to delete item matching the query
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

enum KeychainError: LocalizedError {
    case unhandledError(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .unhandledError(let status):
            return "Keychain error (status: \(status))."
        }
    }
}
