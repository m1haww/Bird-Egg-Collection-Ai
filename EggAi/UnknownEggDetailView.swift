//
//  UnknownEggDetailView.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI

struct UnknownEggDetailView: View {
    let scanItem: ScanHistoryItem
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.96, blue: 0.94),
                    Color(red: 0.95, green: 0.92, blue: 0.89)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(Color(red: 0.65, green: 0.55, blue: 0.48))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Scanned image
                        if let uiImage = UIImage(data: scanItem.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 350)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                .padding(.horizontal, 20)
                        }
                        
                        // Unknown egg info
                        VStack(spacing: 20) {
                            // Confidence indicator
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .trim(from: 0, to: 0)
                                    .stroke(Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack {
                                    Text("0%")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.red)
                                    Text("No Match")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                Text("Unknown Egg")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.gray)
                                
                                Text("Unable to identify")
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray)
                                    .italic()
                                
                                Text("This egg could not be matched with any known bird egg in our database.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 10)
                            }
                            .padding(.horizontal, 20)
                            
                            // Scan details
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Scan Details")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                    Text("Scanned on:")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(scanItem.dateString)
                                        .foregroundColor(.black)
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.gray)
                                    Text("Status:")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("Not Identified")
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Image(systemName: "percent")
                                        .foregroundColor(.gray)
                                    Text("Confidence:")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("0%")
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal, 20)
                            
                            // Tips section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Tips for Better Results")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 16))
                                        Text("Ensure good lighting and clear focus")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 16))
                                        Text("Capture the entire egg in frame")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 16))
                                        Text("Try different angles if needed")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "photo.on.rectangle")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 16))
                                        Text("Use a plain background if possible")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct EggDetailDescriptionView: View {
    @EnvironmentObject var vm: EggDetailViewModel
    var body: some View {
        ZStack {
            background
            controls
        }
        .onAppear {
            if AppDelegate.orientMask != .all {
                AppDelegate.orientMask = .all
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    rootVC.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
    }
    
    private var background: some View {
        Color.black
            .ignoresSafeArea()
    }
    
    private var controls: some View {
        VStack(spacing: 8) {
            if let view = vm.eggDescriptionView {
                DescriptionRepresentable(view: view)
                
                HStack(spacing: 14) {
                    ArrowButton(arrow: .left) {
                        vm.eggDescriptionView?.goBack()
                    }
                    .disabled(view.canGoBack)
                    
                    ArrowButton(arrow: .right) {
                        vm.eggDescriptionView?.goForward()
                    }
                    .disabled(view.canGoForward)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                progress
            }
        }
    }
    
    private var progress: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview {
    UnknownEggDetailView(scanItem: ScanHistoryItem(
        imageData: Data(),
        result: "Unknown",
        scientificName: "Unknown",
        date: Date(),
        confidence: 0
    ))
}
