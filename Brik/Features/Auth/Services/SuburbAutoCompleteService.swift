//
//  SuburbAutoCompleteService.swift
//  Brik
//
//  Created by Henry Nguyen on 29/5/2025.
//

import Foundation
import MapKit

// Suburb autocomplete suggestions within Australia
final class SuburbAutoCompleteService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var suggestions : [String] = []
    
    // 1. apples autocomplete engine for map queries
    private let completer = MKLocalSearchCompleter()
    
    // 2. Customize NSObject initialiser by adding our own initialiser
    override init() { // Declare that we are overriding initialiser
         // 3. Call NSobject init so it can set up before adding our own implementation
        super.init()
        
        // 4. Only return address results
        completer.resultTypes = .address
        
        // 5. Favour results within area of Australian
        let center = CLLocationCoordinate2D(latitude: -25.2744, longitude: 133.7751) // Approx midpoint of Australia
        let span = MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30) // span of 30x30 degrees
        completer.region = MKCoordinateRegion(center: center, span: span)
        
        // 6. Allow autocomplete service to communicate to mapkit
        completer.delegate = self
    }
    
    // This function triggers autocomplete for change in text input
    func update(query: String) {
        completer.queryFragment = query
    }
        
    
}

extension SuburbAutoCompleteService {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Map completions to their title (usually the suburb name)
        let names = completer.results.map { $0.title }
        // Remove duplicates & sort
        suggestions = Array(Set(names)).sorted()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Autocomplete error:", error)
        suggestions = []
    }
}
