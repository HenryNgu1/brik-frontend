//
//  PreferenceView.swift
//  Brik
//
//  Created by Henry Nguyen on 4/6/2025.
//

import Foundation
import SwiftUI

struct PreferencesView: View, LocalizedError {
    
    @StateObject var viewModel = PreferencesViewModel()
    @StateObject private var autocomplete = SuburbAutoCompleteService()
    
    // CONTENT VIEW
    var body: some View {
        
        ZStack {
            Color("SplashBackground")
                .ignoresSafeArea(edges: .all)
            
            ScrollView(.vertical, showsIndicators: true) {
                
                VStack(spacing: 36) {
                    //
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .padding(.top, 16)
                    
                    //
                    Text("Edit preferences to get better matches")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Prefered Suburb", text: $viewModel.preferedLocation)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
//                        .onChange(of: viewModel.preferedLocation) {
//                            autocomplete.update(query: viewModel.preferedLocation)
//                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.preferedLocationError == nil
                                        ? Color.gray.opacity(0.5)
                                        : Color.red,
                                        lineWidth: 1)
                        )
                    //
                    if let error = viewModel.preferedLocationError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 20){
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Min budget")
                                TextField("0", text: $viewModel.minBudget)
                                    .keyboardType(.numberPad)
                                    .background(Color(.secondarySystemBackground))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(viewModel.minbudgetError == nil
                                                    ? Color.gray.opacity(0.5)
                                                    : Color.red,
                                                    lineWidth: 1)
                                    )
                                //
                                if let error = viewModel.minbudgetError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Max budget")
                                TextField("0", text: $viewModel.maxBudget)
                                    .keyboardType(.numberPad)
                                    .background(Color(.secondarySystemBackground))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(viewModel.maxbudgetError == nil
                                                    ? Color.gray.opacity(0.5)
                                                    : Color.red,
                                                    lineWidth: 1)
                                    )
                                //
                                if let error = viewModel.maxbudgetError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        // 3. Pets & Smoking Toggles
                        Toggle("Pets Allowed", isOn: $viewModel.petsAllowed)
                        // Inline comment: Toggle binds directly to a Bool, toggles UI state.
                        Toggle("Smoking Allowed", isOn: $viewModel.smokingAllowed)
                        
                        Stepper("Min Age: \(viewModel.minAge)", value: $viewModel.minAge, in: 18...100)
                            
                        if let error = viewModel.minAgeError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        //
                        Stepper("Max Age: \(viewModel.maxAge)", value: $viewModel.maxAge, in: viewModel.minAge...100)
                        
                        if let error = viewModel.maxAgeError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        //
                        Text("Cleanliness Level")
                        Picker("Cleanliness Level", selection: $viewModel.cleanlinessLevel) {
                            Text("Low").tag("Low")
                            Text("Medium").tag("Medium")
                            Text("High").tag("High")
                        }
                        .pickerStyle(.segmented)
                        
                        //
                        Text("Lifestyle")
                        Picker("Lifestyle", selection: $viewModel.lifeStyle) {
                            Text("Quite").tag("Quite")
                            Text("Relaxed").tag("Relaxed")
                            Text("Active").tag("Active")
                        }
                        .pickerStyle(.segmented)
                        
                        
                    } // group end
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Button(action: {
                        viewModel.validateFields()
                        Task {
                            await viewModel.createPreferences()
                        }
                    }) {
                        Text("Save Preferences")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 26)
                }.padding(.horizontal, 24)
            }
            .onAppear {
                Task {
                    await viewModel.loadPreferences()
                }
            }
        }
    }
}
#Preview {
    PreferencesView()
}


    
