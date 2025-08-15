//
//  EggListView.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI

struct BirdEggData: Codable {
    let eggs: [BirdEgg]
}

struct BirdEgg: Codable, Identifiable {
    let id: Int
    let name: String
    let scientificName: String
    let image: String
    let eggColor: String
    let eggSize: String
    let description: String
    let habitat: String
    let region: String
}

struct EggListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var eggs: [BirdEgg] = []
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var isLoading = false
    
    let categories = ["All", "Small", "Medium", "Large", "Blue", "White", "Spotted", "North America", "Europe", "Worldwide"]
    
    var filteredEggs: [BirdEgg] {
        if searchText.isEmpty && selectedCategory == "All" {
            return eggs
        }
        
        return eggs.filter { egg in
            let matchesSearch = searchText.isEmpty || 
                egg.name.localizedCaseInsensitiveContains(searchText) ||
                egg.scientificName.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == "All" || {
                switch selectedCategory {
                case "Small":
                    return egg.eggSize.contains("1.") || egg.eggSize.contains("2.0") || egg.eggSize.contains("2.1") || egg.eggSize.contains("2.2")
                case "Medium":
                    return egg.eggSize.contains("2.") || egg.eggSize.contains("3.") || egg.eggSize.contains("4.")
                case "Large":
                    return egg.eggSize.contains("5.") || egg.eggSize.contains("6.") || egg.eggSize.contains("7.") || egg.eggSize.contains("8.") || egg.eggSize.contains("9.")
                case "Blue":
                    return egg.eggColor.localizedCaseInsensitiveContains("blue")
                case "White":
                    return egg.eggColor.localizedCaseInsensitiveContains("white")
                case "Spotted":
                    return egg.eggColor.localizedCaseInsensitiveContains("spot") || egg.eggColor.localizedCaseInsensitiveContains("mark")
                default:
                    return egg.region.localizedCaseInsensitiveContains(selectedCategory)
                }
            }()
            
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        ZStack {
            // Simplified background
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
                    
                    Text("Bird Egg Collection")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible button for symmetry
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .opacity(0)
                    .disabled(true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                .background(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Search and filters section
                VStack(spacing: 16) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search bird eggs...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.black)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                    
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                CategoryChip(
                                    title: category,
                                    isSelected: selectedCategory == category,
                                    action: {
                                        selectedCategory = category
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading bird eggs...")
                        .padding()
                    Spacer()
                } else if eggs.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No eggs found")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        Text("Please ensure bird_eggs.json is added to the project")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else if filteredEggs.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No matches found")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        Text("Try adjusting your search or filter criteria")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    // Results count
                    HStack {
                        Text("\(filteredEggs.count) eggs found")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Eggs list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEggs) { egg in
                                NavigationLink(destination: EggDetailView(egg: egg)) {
                                    EggCard(egg: egg)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if eggs.isEmpty {
                loadJSONData()
            }
        }
    }
    
    func loadJSONData() {
        if let url = Bundle.main.url(forResource: "bird_eggs", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let eggData = try JSONDecoder().decode(BirdEggData.self, from: data)
                self.eggs = eggData.eggs
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("bird_eggs.json not found in bundle")
        }
    }
}

struct EggCard: View {
    let egg: BirdEgg
    
    var body: some View {
        HStack(spacing: 16) {
            // Egg image
            CachedAsyncImage(url: URL(string: egg.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                case .failure(_):
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.65, green: 0.55, blue: 0.48).opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Text("🥚")
                            .font(.system(size: 30))
                    }
                case .empty:
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                @unknown default:
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.65, green: 0.55, blue: 0.48).opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Text("🥚")
                            .font(.system(size: 30))
                    }
                }
            }
            
            // Egg information
            VStack(alignment: .leading, spacing: 4) {
                Text(egg.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(egg.scientificName)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .italic()
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(getEggColor(egg.eggColor))
                            .frame(width: 12, height: 12)
                        Text(egg.eggColor)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    Text("•")
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text(egg.eggSize)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Text(egg.habitat)
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.8))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func getEggColor(_ description: String) -> Color {
        let lowercased = description.lowercased()
        if lowercased.contains("blue") {
            return .blue.opacity(0.6)
        } else if lowercased.contains("brown") {
            return .brown.opacity(0.6)
        } else if lowercased.contains("white") {
            return .gray.opacity(0.3)
        } else if lowercased.contains("olive") {
            return .green.opacity(0.5)
        } else if lowercased.contains("green") {
            return .green.opacity(0.6)
        } else if lowercased.contains("red") {
            return .red.opacity(0.5)
        } else if lowercased.contains("turquoise") {
            return .cyan.opacity(0.6)
        } else if lowercased.contains("buff") {
            return Color(red: 0.9, green: 0.8, blue: 0.6)
        } else if lowercased.contains("cream") {
            return Color(red: 1.0, green: 0.95, blue: 0.8)
        } else {
            return .gray.opacity(0.5)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.4, green: 0.35, blue: 0.3))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(red: 0.65, green: 0.55, blue: 0.48).opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    EggListView()
}