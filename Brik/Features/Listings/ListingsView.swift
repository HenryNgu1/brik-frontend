//
//  ListingsView.swift
//  Brik
//
//  Created by Henry Nguyen on 17/6/2025.
//
import SwiftUI

struct ListingsView: View {
    @State private var navigateToEdit = false
    
    @StateObject private var viewModel: ListingsViewModel

    init(viewModel: ListingsViewModel = ListingsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            }
            else if let listing = viewModel.currentListing {
                ScrollView {
                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .padding(.top, 16)
                        
                        Text("Your current listing.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            NavigationLink {
                                EditListingView(listing: listing)
                                    .environmentObject(viewModel)
                                
                            } label: {
                                Image(systemName: "pencil")
                                Text("Edit Listing")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(listing.imageUrls, id: \.self) { urlStr in
                                    if let url = URL(string: urlStr) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 120, height: 120)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 120, height: 120)
                                                    .clipped()
                                                    .cornerRadius(8)
                                            case .failure:
                                                Color.red.opacity(0.3)
                                                    .frame(width: 120, height: 120)
                                                    .cornerRadius(8)
                                            @unknown default:
                                                Color.black
                                                    .frame(width: 120, height: 120)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        
                        
                        // Fields
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(listing.description)
                                .font(.body)
                            
                            Text("Location")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 10)
                            Text(listing.location)
                                .font(.body)
                            
                            Text("Rent per week")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 10)
                            let cleaned = listing.rentPriceWeekly.replacingOccurrences(of: ",", with: "")
                            let value = Double(cleaned) ?? 0.0
                            Text("$\(String(format: "%.2f", value))")

                            
                            Text("Available from")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 10)
                            

                            Text(listing.availabilityDate.formattedDateFromISO())
                                .font(.body)
                            
                            Toggle("Pets Allowed", isOn: .constant(listing.petsAllowed))
                                .disabled(true)
                                .padding(.top, 10)
                        }
                        .padding()
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        
                        Button("Delete") {
                            viewModel.showDeleteConfirmation = true
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(.red)
                        .cornerRadius(8)
                        
                    }
                }
                
                .navigationTitle("Your Listing")
                .navigationBarTitleDisplayMode(.inline)
                .alert("Delete Listing?",
                       isPresented: $viewModel.showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        Task { await viewModel.deleteListing() }
                    }
                } message: {
                    Text("This action cannot be undone.")
                }
            }
            else {
                NoListingView()
            }
        }
    }
}

#if DEBUG
struct ListingsViewWrapper: View {
    @StateObject private var mockVM: ListingsViewModel

    init() {
        let mock = ListingsViewModel()
        mock.currentListing = Listing(
            id: 1,
            userId: 1,
            description: "Preview listing",
            location: "Melbourne, VIC",
            rentPriceWeekly: "39000",
            availabilityDate: "2025-07-04T10:18:22.000Z",
            petsAllowed: false,
            imageUrls: [
                "https://via.placeholder.com/120",
                "https://via.placeholder.com/120"
            ],
            createdAt: "2025-07-04T10:18:22.000Z"
        )
        _mockVM = StateObject(wrappedValue: mock)
    }

    var body: some View {
        NavigationStack {
            ListingsView(viewModel: mockVM)
        }
    }
}


struct ListingsView_Previews: PreviewProvider {
    static var previews: some View {
        ListingsViewWrapper()
    }
}
#endif
