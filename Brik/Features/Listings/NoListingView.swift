//
//  NoListingView.swift
//  Brik
//
//  Created by Henry Nguyen on 17/6/2025.
//

import Foundation
import SwiftUI

struct NoListingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("You don't have a listing yet.")
                .font(.title3)
                .foregroundColor(.secondary)
            
            NavigationLink(
                destination: EditListingView(
                    // Hand in a “blank” Listing
                    listing: Listing(
                        id: 0,
                        userId: 0,
                        description: "",
                        location: "",
                        rentPriceWeekly: "",
                        availabilityDate: "",
                        petsAllowed: false,
                        imageUrls: [],
                        createdAt: ""
                    )
                )
            ) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Create Listing")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoListingView()
}
