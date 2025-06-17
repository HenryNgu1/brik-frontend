//
//  ListingsView.swift
//  Brik
//
//  Created by Henry Nguyen on 17/6/2025.
//

import SwiftUI

import SwiftUI

struct ListingsView: View {
    @StateObject private var viewModel = ListingsViewModel()
    @State private var navigateToEdit = false

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
                        ScrollView(.horizontal,) {
                            HStack {
                                ForEach(listing.imageUrls, id: \.self) { urlStr in
                                    if let url = URL(string: urlStr) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                        }
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                        .cornerRadius(8)
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
                            Text("$\(String(format: "%.2f", listing.rentPriceWeekly))")
                                .font(.body)
                            
                            Text("Available from")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 10)
                            Text(listing.availabilityDate)
                                .font(.body)
                            
                            Toggle("Pets Allowed", isOn: .constant(listing.petsAllowed))
                                .disabled(true)
                                .padding(.top, 10)
                        }
                        .padding()

                        
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

