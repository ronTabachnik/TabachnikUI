//
//  File.swift
//  
//
//  Created by Ron Tabachnik on 10/08/2024.
//

import SwiftUI
import PhotosUI
import Vision
import CoreImage.CIFilterBuiltins

@available(iOS 16.0, *)
public struct PhotosImagePicker: View {
    @State public var selectedItems: [PhotosPickerItem] = []
    @State public var selections: [UIImage] = []
    @State public var error: Bool = false
    @State public var isProcessing: Bool = false
    @State public var limit: Int
    @State public var counter: Int = 0
    @State public var background: Color
    @State public var foregroundColor: Color
    @State public var textFont: UIFont
    @State public var selectedBackgroundColor: Color = .white
    @Binding public var images: [UIImage]
    
    // Quarter sheet states
    @State private var showSheet: Bool = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    let shouldRemoveBackground: Bool
    // Callback for processed images
    public var onProcessed: (([UIImage]) -> Void)?
    
    public init(
        images: Binding<[UIImage]>,
        limit: Int = 5,
        background: Color = .gray.opacity(0.1),
        foregroundColor: Color = .primary,
        textFont: UIFont = .systemFont(ofSize: 12),
        shouldRemoveBackground: Bool = true,
        onProcessed: (([UIImage]) -> Void)? = nil
    ) {
        self._images = images
        self.background = background
        self.foregroundColor = foregroundColor
        self.textFont = textFont
        self._limit = State(initialValue: limit)
        self.shouldRemoveBackground = shouldRemoveBackground
        self.onProcessed = onProcessed
    }
    
    public var body: some View {
        VStack {
            // Background Color Picker
            if shouldRemoveBackground {
                ColorPicker("Select Background Color", selection: $selectedBackgroundColor)
                    .lineHeight(font: textFont, lineHeight: 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            PhotosPicker(selection: $selectedItems, maxSelectionCount: limit, matching: .images) {
                VStack {
                    if !images.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 10) {
                            ForEach(images, id: \.self) { image in
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding()
                    } else {
                        if isProcessing {
                            ProgressView("Processing images...")
                                .lineHeight(font: textFont, lineHeight: 20)
                                .padding()
                        } else {
                            VStack(spacing: 16) {
                                Image("Upload")
                                    .resizable()
                                    .frame(width: 34, height: 34)
                                    .clipped()
                                Text(error ? "Error, try again" : "Upload Photos")
                                    .lineHeight(font: textFont, lineHeight: 20)
                                    .foregroundColor(background)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(
                            foregroundColor,
                            style: StrokeStyle(lineWidth: 1.5, dash: [10])
                        )
                        .allowsHitTesting(false)
                )
                .background(background.opacity(0.1).cornerRadius(28))
            }
            .onChange(of: selectedItems) { selectedItems in
                loadImages(from: selectedItems)
            }
        }
    }
    
    private func loadImages(from selectedItems: [PhotosPickerItem]) {
        images = []
        selections = []
        counter = selectedItems.count
        error = false
        isProcessing = true
        
        if selectedItems.isEmpty {
            error = true
            isProcessing = false
            return
        }
        
        for item in selectedItems {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let imageData):
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.selections.append(uiImage)
                        }
                    }
                case .failure(_):
                    self.error = true
                }
                counter -= 1
                
                if counter == 0 {
                    DispatchQueue.main.async {
                        self.images = selections
                        if shouldRemoveBackground {
                            self.processImages() // Process images after all are loaded
                        } else {
                            isProcessing = false
                        }
                    }
                }
            }
        }
    }
    
    private func processImages() {
        guard !images.isEmpty else {
            isProcessing = false
            return
        }
        
        Task {
            var processedImages: [UIImage] = []
            for image in images {
                if let inputImage = CIImage(image: image),
                   let maskImage = createMask(from: inputImage) {
                    let outputImage = applyMaskWithBackground(
                        mask: maskImage,
                        to: inputImage,
                        backgroundColor: selectedBackgroundColor
                    )
                    processedImages.append(convertToUIImage(ciImage: outputImage))
                } else {
                    processedImages.append(image) // Fallback to original image
                }
            }
            
            DispatchQueue.main.async {
                self.images = processedImages
                self.isProcessing = false
                self.onProcessed?(processedImages)
            }
        }
    }
    
    private func createMask(from inputImage: CIImage) -> CIImage? {
        if #available(iOS 17.0, *) {
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(ciImage: inputImage)
        
        do {
            try handler.perform([request])
            if let result = request.results?.first {
                let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                return CIImage(cvPixelBuffer: mask)
            }
        } catch {
            print("Error generating mask: \(error)")
        }
        return nil
        } else {
            return nil
        }
    }
    
    private func applyMaskWithBackground(mask: CIImage, to image: CIImage, backgroundColor: Color) -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.maskImage = mask
        
        // Create a solid color background
        let ciBackgroundColor = CIImage(color: CIColor(cgColor: UIColor(backgroundColor).cgColor))
            .cropped(to: image.extent)
        
        filter.backgroundImage = ciBackgroundColor
        return filter.outputImage!
    }
    
    private func convertToUIImage(ciImage: CIImage) -> UIImage {
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            fatalError("Failed to convert CIImage to UIImage")
        }
    }
}
