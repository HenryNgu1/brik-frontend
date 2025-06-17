//
//  PreferenceView.swift
//  Brik
//
//  Created by Henry Nguyen on 4/6/2025.
//

import Foundation
import SwiftUI

struct PreferencesView: View, LocalizedError {
    @EnvironmentObject var session : SessionManager
    @StateObject var viewModel = PreferencesViewModel()
    
    // CONTENT VIEW
    var body: some View {
        
        ZStack {
            Color("SplashBackground")
                .ignoresSafeArea(edges: .all)
            
            ScrollView(.vertical, showsIndicators: true) {
                
                VStack(spacing: 36) {
                    // LOGO + TEXT
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .padding(.top, 16)
                    
                    Text("Personalize your matches.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                                        
                    VStack(alignment: .leading, spacing: 20){
                        // 1. LOCATION FIELD
                        Text("Prefered Suburb")
                            
                        TextField("Prefered Suburb", text: $viewModel.preferredLocation)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.preferedLocationError == nil
                                            ? Color.gray.opacity(0.5)
                                            : Color.red,
                                            lineWidth: 1)
                            )
                        // 1.1 LOCATION ERROR MESSAGE
                        if let error = viewModel.preferedLocationError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        
                        HStack {
                            VStack(alignment: .leading) {
                                // 2. MIN BUDGET FIELD
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
                                // 2.1 MIN BUDGET ERROR MESSAGE
                                if let error = viewModel.minbudgetError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                
                            }
                            
                            VStack(alignment: .leading) {
                                // 2.3 MAX BUDGET FIELD
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
                                // 2.4 MAX BUDGET ERROR MESSAGE
                                if let error = viewModel.maxbudgetError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        // 3. PET ALLOWED FIELD
                        Toggle("Pets Allowed", isOn: $viewModel.petsAllowed)
                        
                        // 4. SMOKING ALLOWED FIELD
                        Toggle("Smoking Allowed", isOn: $viewModel.smokingAllowed)
                        
                        // 4. MIN AGE FIELD
                        Stepper("Min Age: \(viewModel.minAge)", value: $viewModel.minAge, in: 18...100)
                        
                        // 4.1 MIN AGE ERROR MESSAGE
                        if let error = viewModel.minAgeError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 5. MAX AGE FIELD
                        Stepper("Max Age: \(viewModel.maxAge)", value: $viewModel.maxAge, in: viewModel.minAge...100)
    
                        // 5.1 MAX AGE ERROR MESSAGE
                        if let error = viewModel.maxAgeError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // 6. CLEAN FIELD
                        Text("Cleanliness Level")
                        Picker("Cleanliness Level", selection: $viewModel.cleanlinessLevel) {
                            Text("Low").tag("Low")
                            Text("Medium").tag("Medium")
                            Text("High").tag("High")
                        }
                        .pickerStyle(.segmented)
                        
                        // 7. LIFESTYLE FIELD
                        Text("Lifestyle")
                        Picker("Lifestyle", selection: $viewModel.lifeStyle) {
                            Text("Quite").tag("Quite")
                            Text("Relaxed").tag("Relaxed")
                            Text("Active").tag("Active")
                        }
                        .pickerStyle(.segmented)
                        
                        
                    } // Group end
                    
                    // 8. NETWORK CALL ERROR MESSAGES
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    // 9. SAVE BUTTON
                    Button(action: {
                        // 9.1 VALIDATE REQUIRED FIELDS
                        viewModel.validateFields()
                        Task {
                            // 9.2 CALL SAVE PREF -> CALLS PUT/POST REQUEST
                            await viewModel.savePreferences()
                        }
                    }) {
                        // 9.3 IF NETWORK CALL IN PROGRESS SHOW LOADER
                        if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        // 9.4 IF NO NETWORK CALL ONGOING SHOW DEFAULT SAVE TEXT
                        else {
                            Text("Save Preferences")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 26)
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, 24)
            }
            // Fetch current user preferences when view loads
            .onAppear {
                Task {
                    await viewModel.loadPreferences()
                }
            }
        }
        .navigationTitle("Edit Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    PreferencesView()
}


    
