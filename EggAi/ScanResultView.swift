//
//  ScanResultView.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI

struct ScanResultView: View {
    let capturedImage: UIImage
    @Environment(\.presentationMode) var presentationMode
    @State private var isAnalyzing = true
    @State private var identificationResult: BirdEgg?
    @State private var confidence: Int = 0
    @State private var hasSavedToHistory = false
    @State private var hasAnalyzed = false
    
    var body: some View {
        ZStack {
            // Background
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
                    
                    Text("Scan Result")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Captured image
                        Image(uiImage: capturedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 350)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 20)
                        
                        if isAnalyzing {
                            // Analyzing animation
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Analyzing egg...")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 40)
                        } else {
                            // Results
                            VStack(spacing: 20) {
                                // Confidence indicator
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                                        .frame(width: 120, height: 120)
                                    
                                    Circle()
                                        .trim(from: 0, to: CGFloat(confidence) / 100)
                                        .stroke(
                                            confidence > 70 ? Color.green : confidence > 40 ? Color.orange : Color.red,
                                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                        )
                                        .frame(width: 120, height: 120)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeOut(duration: 1), value: confidence)
                                    
                                    VStack {
                                        Text("\(confidence)%")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Confidence")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                // Identification result
                                if let result = identificationResult {
                                    VStack(spacing: 12) {
                                        Text(result.name)
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.black)
                                        
                                        Text(result.scientificName)
                                            .font(.system(size: 18))
                                            .foregroundColor(.gray)
                                            .italic()
                                        
                                        Text(result.description)
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(4)
                                            .padding(.horizontal, 30)
                                        
                                        // Quick info
                                        HStack(spacing: 20) {
                                            InfoBadge(icon: "ruler", label: "Size", value: result.eggSize)
                                            InfoBadge(icon: "paintpalette", label: "Color", value: result.eggColor)
                                        }
                                        .padding(.top, 10)
                                        
                                        // View details button
                                        NavigationLink(destination: EggDetailView(egg: result)) {
                                            Text("View Full Details")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 16)
                                                .background(Color(red: 0.65, green: 0.55, blue: 0.48))
                                                .cornerRadius(12)
                                        }
                                        .padding(.horizontal, 30)
                                        .padding(.top, 10)
                                    }
                                } else {
                                    VStack(spacing: 12) {
                                        Text("Unknown Egg")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.gray)
                                        
                                        Text("Unable to identify this egg")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                        
                                        Text("Try taking another photo with better lighting or angle")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                    }
                                }
                            }
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Only analyze if we haven't done it before
            if !hasAnalyzed {
                analyzeImage()
                hasAnalyzed = true
            }
        }
    }
    
    private func analyzeImage() {
        // Use OpenAI Vision API to identify the egg
        EggIdentificationService.shared.identifyEgg(from: capturedImage) { egg, confidenceScore in
            self.identificationResult = egg
            self.confidence = confidenceScore
            self.isAnalyzing = false
            
            // Save to history only once, after identification is complete
            if !self.hasSavedToHistory {
                self.saveToHistory()
                self.hasSavedToHistory = true
            }
        }
    }
    
    private func getRandomEgg() -> BirdEgg? {
        // Load bird eggs from JSON
        guard let url = Bundle.main.url(forResource: "bird_eggs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let eggData = try? JSONDecoder().decode(BirdEggData.self, from: data) else {
            return nil
        }
        
        return eggData.eggs.randomElement()
    }
    
    private func saveToHistory() {
        if let result = identificationResult {
            ScanHistoryManager.shared.addScanResult(
                image: capturedImage,
                result: result.name,
                scientificName: result.scientificName,
                confidence: confidence
            )
        } else {
            ScanHistoryManager.shared.addScanResult(
                image: capturedImage,
                result: "Unknown",
                scientificName: "Unknown",
                confidence: 0
            )
        }
    }
}

struct InfoBadge: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.65, green: 0.55, blue: 0.48))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .lineLimit(1)
        }
        .frame(width: 100)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

extension UIApplication {
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
}


#Preview {
    ScanResultView(capturedImage: UIImage(systemName: "photo")!)
}
