//
//  ListingsView.swift
//  Brik
//
//  Created by Henry Nguyen on 6/6/2025.
//

import SwiftUI
import PhotosUI

struct EditListingView: View {
    
    @StateObject private var viewModel: EditListingViewModel
    @EnvironmentObject private var listingsViewModel: ListingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    
    init (listing: Listing) {
        _viewModel = StateObject(wrappedValue: EditListingViewModel(listing: listing))
    }
    
    var body: some View {
        ScrollView {
            
            // IMAGE PICKER
            VStack(alignment: .leading) {
                Text("Uploaded Images")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ImageSlotGridView(
                    existingImageURLs: $viewModel.existingImgURLs,
                    replacedImages: $viewModel.replacedImages
                )
                .padding()
                
                VStack(alignment: .leading) {
                    
                    // Description
                    Text("Description")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.top, 12)
                    
                    // Description Input box
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 90)
                        .padding(4)
                        .cornerRadius(8)
                        
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5),lineWidth: 1)
                               
                )
                
                // LOCATION
                Text("Suburb")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Suburb", text: $viewModel.location)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5),lineWidth: 1)
                    )
                
                Text("Weekly Price")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField(
                  "Weekly rent price",
                  value: $viewModel.rentPriceWeekly,
                  format: .number.precision(.fractionLength(0...2))
                )
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5),lineWidth: 1)
                )
                .keyboardType(.decimalPad)
                
                // AVAILABLE DATE
                Text("Available Date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                DatePicker("Available Date", selection: $viewModel.availabilityDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    .background(Color(.secondarySystemBackground)) // Color
                    .cornerRadius(8) // Rounded corners
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5),lineWidth: 1)
                    )
                
                // PETS ALLOWED
                Toggle("Pets Allowed", isOn: $viewModel.petsAllowed)
                
                // 1) Simple title + action
                Button {
                  Task {
                      await viewModel.saveListing()
                      await listingsViewModel.fetchListing()
                      dismiss()
                  }
                }
                label: {
                    Text("Save")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
               
            }
            .padding()
        }
        .navigationTitle(Text("Edit Listing"))
        .navigationBarTitleDisplayMode(.inline)
    }

}
#if DEBUG
struct EditListingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            // 1) Create a fake Listing model:
            let sampleListing = Listing(
                id: 1,
                userId: 1,
                description: "Sunny 1-bed apartment",
                location: "Richmond, VIC",
                rentPriceWeekly: "350000",
                availabilityDate: "",
                petsAllowed: true,
                imageUrls: [], // or supply [URL] if you want thumbnails
                createdAt: ""
            )

            // 2) Call your new init(listing:)
            EditListingView(listing: sampleListing)
        }
    }
}
#endif

