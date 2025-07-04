//
//  ImageSlotGrid.swift
//  Brik
//
//  Created by Henry Nguyen on 4/7/2025.
//

import SwiftUI
import PhotosUI

struct ImageSlotGridView: View {
    @Binding var existingImageURLs: [String]
    @Binding var replacedImages: [Int: UIImage]

    @State private var selectedSlot: Int?
    @State private var selectedItem: PhotosPickerItem?
    @State private var isPickerPresented = false
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
            ForEach(0..<5, id: \.self) { index in
                ZStack {
                    // Your existing image display logic...
                    if let newImage = replacedImages[index] {
                        Image(uiImage: newImage)
                            .resizable()
                            .scaledToFill()
                    }
                    else if let urlStr = existingImageURLs[safe: index],
                            let url = URL(string: urlStr) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                    }
                    else {
                        Color.gray.opacity(0.2)
                        Image(systemName: "plus.circle")
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(10)
                .onTapGesture {
                    selectedSlot = index
                    isPickerPresented = true // Add this line
                }
            }
        }
        .photosPicker(isPresented: $isPickerPresented,
                              selection: $selectedItem,
                              matching: .images)
        .onChange(of: selectedItem) {
            guard let slot = selectedSlot else { return }
            Task {
                if let item = selectedItem,
                   let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    replacedImages[slot] = image
                }
                selectedItem = nil
                selectedSlot = nil
                isPickerPresented = false // Dismiss the sheet
            }
        }
    }
}
#if DEBUG
struct ImageSlotGridView_Previews: PreviewProvider {
    @State static var mockURLs: [String] = [
        "https://via.placeholder.com/100", "", "", "", ""
    ]
    @State static var mockReplaced: [Int: UIImage] = [:]

    static var previews: some View {
        ImageSlotGridView(
            existingImageURLs: $mockURLs,
            replacedImages: $mockReplaced
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
