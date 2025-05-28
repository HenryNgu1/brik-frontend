//
//  EmailValidator.swift
//  Brik
//
//  Created by Henry Nguyen on 28/5/2025.
//

import Foundation

struct EmailValidator {
    
    // Returns a bool is the argument string matches the regex format
    static func isValid(_ email: String) -> Bool {
        
        // 1. Regex format
        // 1.1 uppercase, lowercase, numbers 0-9 and s. _ % + - symbols allowed
        // 1.2 one or more allowed '@'
        // 1.3 one or more "."
        // 1.4 ending most have at least 2 letters
        let pattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        
        // 2. Create predicate object that tests if the input matches the pattern defined
        let predicate = NSPredicate(format : "SELF MATCHES %@", pattern)
        
        // 3. Evaulate email with predicate object aginst regex
        return predicate.evaluate(with: email)
    }
}
