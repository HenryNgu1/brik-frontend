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
    
    init (listing: Listing) {
        _viewModel = StateObject(wrappedValue: EditListingViewModel(listing: listing))
    }
    
    var body: some View {
        Form {
            Section("Description & Location") {
                TextField("Description", text: $viewModel.description)
                TextField("Location",    text: $viewModel.location)
            }
            
            Section("Details") {
                TextField("Rent Price (weekly)", text: $viewModel.rentPriceWeekly)
                    .keyboardType(.decimalPad)
                DatePicker("Available from", selection: $viewModel.availabilityDate, displayedComponents: .date)
                Toggle("Pets Allowed", isOn: $viewModel.petsAllowed)
            }

            Section("Photos (max 5)") {
                PhotosPicker(
                    selection: $viewModel.selectedItems,
                    maxSelectionCount: 5,
                    matching: .images
                ) {
                    Text("Select Photos")
                }
                .onChange(of: viewModel.selectedItems) { _ in
                    Task {viewModel.loadImages() }
                }
                
                // Thumbnails
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.images, id: \.self) { img in
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
            }
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Section {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Button("Save") {
                        Task {
                            await viewModel.saveListing()
                        }
                    }
                    .disabled(viewModel.description.isEmpty || viewModel.location.isEmpty)
                }
            }
        }
        .navigationTitle("Edit Listing")
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
                rentPriceWeekly: "350",
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

