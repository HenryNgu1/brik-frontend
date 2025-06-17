//
//  DateToAge.swift
//  Brik
//
//  Created by Henry Nguyen on 29/5/2025.
//

import Foundation

// Extends Swift UI Date class
extension Date {
    
    // Custom method to swift UI Date type
    // 1. since and using are parameter labels.
    // 1.1 Date ask for a date, if none provided defaults too date now
    // 1.2 Calender, specify the calender system being used, if none provided use users current system
    func years(since date: Date = Date(), using calender: Calendar = .current) -> Int {
        
        // 2. Calender computes .year component difference from self(birthdate) to date(now)
        let components = calender.dateComponents([.year], from: self, to: date)
        
        // 3. Return only in full years difference in years, default to 0 if nil
        return components.year ?? 0
    }
}
