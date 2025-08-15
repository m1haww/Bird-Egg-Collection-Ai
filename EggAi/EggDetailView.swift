//
//  EggDetailView.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI

struct EggDetailView: View {
    let egg: BirdEgg
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
                        // Egg image
                        CachedAsyncImage(url: URL(string: egg.image)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 300)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            case .failure(_):
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .frame(height: 300)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    
                                    VStack(spacing: 16) {
                                        Text("🥚")
                                            .font(.system(size: 80))
                                        Text("Image unavailable")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            case .empty:
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .frame(height: 300)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    
                                    VStack(spacing: 16) {
                                        ProgressView()
                                        Text("Loading...")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            @unknown default:
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .frame(height: 300)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    
                                    VStack(spacing: 16) {
                                        Text("🥚")
                                            .font(.system(size: 80))
                                        Text("Image unavailable")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Bird name and scientific name
                        VStack(spacing: 8) {
                            Text(egg.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(egg.scientificName)
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .italic()
                        }
                        .padding(.horizontal, 20)
                        
                        // Quick info cards
                        HStack(spacing: 12) {
                            InfoCard(
                                icon: "ruler",
                                title: "Size",
                                value: egg.eggSize,
                                color: .blue
                            )
                            
                            InfoCard(
                                icon: "paintpalette",
                                title: "Color",
                                value: egg.eggColor,
                                color: .purple
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            InfoCard(
                                icon: "leaf",
                                title: "Habitat",
                                value: egg.habitat,
                                color: .green
                            )
                            
                            InfoCard(
                                icon: "map",
                                title: "Region",
                                value: egg.region,
                                color: .orange
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Description section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Description")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text(egg.description)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .lineSpacing(8)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        
                        // Additional info section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Quick Facts")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                            
                            FactRow(icon: "circle.fill", title: "Egg Shape", value: "Oval")
                            FactRow(icon: "calendar", title: "Breeding Season", value: "Spring to Summer")
                            FactRow(icon: "number.circle", title: "Clutch Size", value: "3-5 eggs")
                            FactRow(icon: "timer", title: "Incubation", value: "12-14 days")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct FactRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.65, green: 0.55, blue: 0.48))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    EggDetailView(egg: BirdEgg(
        id: 1,
        name: "American Robin",
        scientificName: "Turdus migratorius",
        image: "american_robin_egg",
        eggColor: "Sky blue",
        eggSize: "2.8-3.0 cm",
        description: "One of the most recognizable bird eggs with its distinctive blue color. Typically lays 3-5 eggs per clutch.",
        habitat: "Gardens, parks, forests",
        region: "North America"
    ))
}