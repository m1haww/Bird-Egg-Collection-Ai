//
//  ContentView.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI
import PhotosUI
import Combine
import StoreKit

struct ContentView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var freeScanManager = FreeScanManager.shared
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var isFlashOn = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var capturePhoto = false
    @State private var capturedImage: UIImage?
    @State private var showingScanResult = false
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
        ZStack {
            // Full screen camera
            CameraView(capturePhoto: $capturePhoto, isFlashOn: $isFlashOn, capturedImage: $capturedImage)
                .ignoresSafeArea()
            
            VStack {
                // Top app bar
                HStack {
                    // History button
                    Button(action: {
                        showHistory.toggle()
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // App title
                    Text("Bird Egg Identifier")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Egg Collection button
                        NavigationLink(destination: EggListView()) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        // Settings button
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                Spacer()
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Scan limit indicator
                    if !subscriptionManager.hasUnlockedPremium {
                        Text(freeScanManager.getScanLimitMessage())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(freeScanManager.remainingFreeScans > 0 ? .green : .red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(16)
                    }
                    
                    // Instruction text
                    Text("Point camera at bird egg")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                    
                    HStack(spacing: 50) {
                        // Gallery button
                        Button(action: {
                            if freeScanManager.canScan(isPremium: subscriptionManager.hasUnlockedPremium) {
                                showingImagePicker = true
                            } else {
                                showPaywall = true
                            }
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        // Capture button
                        Button(action: {
                            if freeScanManager.canScan(isPremium: subscriptionManager.hasUnlockedPremium) {
                                capturePhoto = true
                            } else {
                                showPaywall = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: 3)
                                            .frame(width: 70, height: 70)
                                    )
                            }
                        }
                        
                        // Flash button
                        Button(action: {
                            isFlashOn.toggle()
                        }) {
                            Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showHistory) {
            NavigationView {
                HistoryView()
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationView {
                SettingsView()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoPickerView(selectedImage: $selectedImage, isPresented: $showingImagePicker)
        }
        .onChange(of: capturedImage) { image in
            if image != nil {
                showingScanResult = true
            }
        }
        .sheet(isPresented: $showingScanResult, onDismiss: {
            // Reset captured image when sheet is dismissed
            capturedImage = nil
        }) {
            if let image = capturedImage {
                NavigationView {
                    ScanResultView(capturedImage: image)
                }
            }
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                capturedImage = image
                showingScanResult = true
                selectedImage = nil
                // Use a free scan when image is processed
                if !subscriptionManager.hasUnlockedPremium {
                    freeScanManager.useScan()
                }
            }
        }
        .onChange(of: capturedImage) { image in
            if image != nil {
                // Use a free scan when camera captures image
                if !subscriptionManager.hasUnlockedPremium {
                    freeScanManager.useScan()
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .onDisappear {
                    print("📱 Paywall dismissed from ContentView")
                }
        }
        .onReceive(subscriptionManager.$hasUnlockedPremium) { isPremium in
            if isPremium {
                freeScanManager.resetForPremium()
            }
        }
    }
}

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var historyManager = ScanHistoryManager.shared
    @State private var showingDeleteAlert = false
    
    @ViewBuilder
    func destinationView(for item: ScanHistoryItem) -> some View {
        if item.result == "Unknown" {
            UnknownEggDetailView(scanItem: item)
        } else {
            // Find the egg in the database
            if let eggDatabase = loadEggDatabase(),
               let egg = eggDatabase.eggs.first(where: { $0.name == item.result }) {
                EggDetailView(egg: egg)
            } else {
                UnknownEggDetailView(scanItem: item)
            }
        }
    }
    
    private func loadEggDatabase() -> BirdEggData? {
        guard let url = Bundle.main.url(forResource: "bird_eggs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let eggData = try? JSONDecoder().decode(BirdEggData.self, from: data) else {
            return nil
        }
        return eggData
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.94)
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
                    
                    Text("Scan History")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                .background(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                if historyManager.scanHistory.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No scan history")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        Text("Your scan results will appear here")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(historyManager.scanHistory) { item in
                                NavigationLink(destination: destinationView(for: item)) {
                                    ScanHistoryCard(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete All History"),
                message: Text("Are you sure you want to delete all scan history? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    historyManager.clearHistory()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ScanHistoryItem: Identifiable {
    let id: UUID
    let imageData: Data // Store actual image data from camera
    let result: String
    let scientificName: String
    let date: Date
    let confidence: Int
    
    init(imageData: Data, result: String, scientificName: String, date: Date, confidence: Int) {
        self.id = UUID()
        self.imageData = imageData
        self.result = result
        self.scientificName = scientificName
        self.date = date
        self.confidence = confidence
    }
    
    init(id: UUID, imageData: Data, result: String, scientificName: String, date: Date, confidence: Int) {
        self.id = id
        self.imageData = imageData
        self.result = result
        self.scientificName = scientificName
        self.date = date
        self.confidence = confidence
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM dd"
            return formatter.string(from: date)
        }
    }
}

struct ScanHistoryCard: View {
    let item: ScanHistoryItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Scan image
            Group {
                if let uiImage = UIImage(data: item.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            }
            
            // Scan information
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.result)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(item.confidence > 0 ? .black : .gray)
                    
                    Spacer()
                    
                    if item.confidence > 0 {
                        Text("\(item.confidence)%")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    } else {
                        Text("0%")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                    }
                }
                
                Text(item.scientificName)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .italic()
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(item.dateString)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if item.result != "Unknown" {
                        Text("New")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.confidence > 70 ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.94)
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
                    
                    Text("Settings")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.clear)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                .background(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Get Pro button - only show if user doesn't have premium
                        if !subscriptionManager.hasUnlockedPremium {
                            Button(action: {
                                showPaywall = true
                            }) {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.yellow)
                                    
                                    Text("Get Pro")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1, green: 0.95, blue: 0.7),
                                            Color(red: 1, green: 0.9, blue: 0.6)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                        }
                        
                        // Privacy button
                        Button(action: {
                            if let url = URL(string: "https://www.termsfeed.com/live/d81c1b9b-7c23-496a-b1fb-ce3475c14788") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.65, green: 0.55, blue: 0.48))
                                
                                Text("Privacy")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Contact button
                        Button(action: {
                            if let url = URL(string: "https://www.termsfeed.com/live/d81c1b9b-7c23-496a-b1fb-ce3475c14788") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.65, green: 0.55, blue: 0.48))
                                
                                Text("Contact")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Rate Us button
                        Button(action: {
                            // Show native iOS rating dialog
                            if let windowScene = UIApplication.shared.windows.first?.windowScene {
                                SKStoreReviewController.requestReview(in: windowScene)
                            }
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                                
                                Text("Rate Us")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Version info
                        HStack {
                            Text("Version")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("1.0.0")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    ContentView()
}
