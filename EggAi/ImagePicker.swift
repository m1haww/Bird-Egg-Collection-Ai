//
//  ImagePicker.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// Wrapper view that handles permissions
struct PhotoPickerView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @State private var authorizationStatus = PHPhotoLibrary.authorizationStatus()
    @State private var showingSettings = false
    
    var body: some View {
        Group {
            switch authorizationStatus {
            case .authorized, .limited:
                ImagePicker(selectedImage: $selectedImage)
            
            case .notDetermined:
                PermissionRequestView {
                    PHPhotoLibrary.requestAuthorization { status in
                        DispatchQueue.main.async {
                            authorizationStatus = status
                            if status == .authorized || status == .limited {
                                // Permissions granted, the view will automatically update
                            } else {
                                // Permissions denied, dismiss
                                isPresented = false
                            }
                        }
                    }
                }
            
            case .denied, .restricted:
                PermissionDeniedView(showingSettings: $showingSettings)
                
            @unknown default:
                PermissionDeniedView(showingSettings: $showingSettings)
            }
        }
        .onAppear {
            // Refresh authorization status when view appears
            authorizationStatus = PHPhotoLibrary.authorizationStatus()
        }
        .alert("Open Settings", isPresented: $showingSettings) {
            Button("Cancel") { }
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                isPresented = false
            }
        } message: {
            Text("Please enable photo library access in Settings to select images.")
        }
    }
}

struct PermissionRequestView: View {
    let requestAction: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.65, green: 0.55, blue: 0.48))
            
            VStack(spacing: 16) {
                Text("Access Your Photos")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Bird Egg Identifier needs access to your photo library to analyze egg images.")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)
            }
            
            Button(action: requestAction) {
                Text("Allow Access")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.65, green: 0.55, blue: 0.48))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }
}

struct PermissionDeniedView: View {
    @Binding var showingSettings: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 16) {
                Text("Photo Access Required")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Please enable photo library access in Settings to select images for identification.")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 16) {
                Button(action: {
                    showingSettings = true
                }) {
                    Text("Open Settings")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.65, green: 0.55, blue: 0.48))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.65, green: 0.55, blue: 0.48))
                }
            }
            .padding(.horizontal, 40)
        }
    }
}