//
//  OnboardingView.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI
import Combine

struct OnboardingView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    
    var body: some View {
        if isOnboardingComplete || subscriptionManager.hasUnlockedPremium {
            ContentView()
        } else {
            TabView(selection: $currentPage) {
                WelcomeScreen(onGetStarted: {
                    withAnimation {
                        currentPage = 1
                    }
                })
                    .tag(0)
                
                AIFeaturesScreen(onContinue: {
                    withAnimation {
                        currentPage = 2
                    }
                })
                    .tag(1)
                
                ThirdScreen(onContinue: {
                    withAnimation {
                        hasCompletedOnboarding = true
                        isOnboardingComplete = true
                    }
                })
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            .ignoresSafeArea()
            .background(Color(red: 0.7, green: 0.6, blue: 0.55).ignoresSafeArea())
            .onReceive(subscriptionManager.$hasUnlockedPremium) { isPremium in
                if isPremium {
                    print("🎉 Premium detected in onboarding, completing onboarding")
                    withAnimation {
                        isOnboardingComplete = true
                    }
                }
            }
        }
    }
}

struct WelcomeScreen: View {
    let onGetStarted: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.78, green: 0.68, blue: 0.62),
                    Color(red: 0.65, green: 0.55, blue: 0.48),
                    Color(red: 0.72, green: 0.6, blue: 0.52)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle overlay pattern
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 350, height: 350)
                        .offset(x: -100, y: -50)
                        .blur(radius: 40)
                    
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 400, height: 400)
                        .offset(x: geometry.size.width - 150, y: geometry.size.height - 200)
                        .blur(radius: 50)
                    
                    Circle()
                        .fill(Color(red: 0.8, green: 0.7, blue: 0.6).opacity(0.15))
                        .frame(width: 250, height: 250)
                        .offset(x: 50, y: geometry.size.height / 2)
                        .blur(radius: 30)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // App Icon
                        Image("bird")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                        
                        VStack(spacing: 16) {
                            Text("Welcome to")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                Text("Bird Egg Identifier!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                Text("🥚")
                                    .font(.system(size: 28))
                            }
                        }
                        
                        Text("The #1 app for bird egg identification")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 30) {
                        HStack(spacing: 60) {
                            VStack(spacing: 8) {
                                Text("500K+")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Users")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            VStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Text("4.8")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("★")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.yellow)
                                }
                                Text("Rating")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            VStack(spacing: 8) {
                                Text("1M+")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Scans")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        VStack(spacing: 16) {
                            Text("Incredibly accurate! Helped me identify over 30 different bird species by their eggs during my birdwatching adventures.")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.white.opacity(0.95))
                                .multilineTextAlignment(.center)
                                .italic()
                                .lineSpacing(4)
                            
                            Text("- Sarah M., Bird Enthusiast")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.15))
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    Button(action: onGetStarted) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.35))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                }
            }
        }
    }

struct ArrowButton: View {
    enum Arrow: String {
        case left = "chevron.left"
        case right = "chevron.right"
    }
    
    let arrow: Arrow
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: arrow.rawValue)
                .imageScale(.large)
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct AIFeaturesScreen: View {
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.72, green: 0.62, blue: 0.56),
                    Color(red: 0.68, green: 0.58, blue: 0.5),
                    Color(red: 0.75, green: 0.63, blue: 0.55)
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
            
            // Subtle overlay pattern
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 300, height: 300)
                        .offset(x: geometry.size.width - 100, y: 100)
                        .blur(radius: 60)
                    
                    Circle()
                        .fill(Color(red: 0.85, green: 0.75, blue: 0.65).opacity(0.1))
                        .frame(width: 350, height: 350)
                        .offset(x: -50, y: geometry.size.height - 250)
                        .blur(radius: 40)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)
                
                // Icon and title section
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Text("AI-Powered Magic")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("✨")
                                .font(.system(size: 28))
                        }
                        
                        Text("Discover the power of artificial intelligence")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                    .frame(height: 60)
                
                // Features list
                VStack(alignment: .leading, spacing: 28) {
                    FeatureRow(
                        icon: "camera.fill",
                        title: "Instant Recognition",
                        description: "Simply take a photo and get precise results in seconds"
                    )
                    
                    FeatureRow(
                        icon: "textformat",
                        title: "Multilingual",
                        description: "Available in German and English with localized results"
                    )
                    
                    FeatureRow(
                        icon: "flask.fill",
                        title: "Scientifically Accurate",
                        description: "Based on cutting-edge AI Vision technology"
                    )
                    
                    FeatureRow(
                        icon: "clock.arrow.circlepath",
                        title: "Personal History",
                        description: "Save and manage all your discoveries"
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.35))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

struct ThirdScreen: View {
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.76, green: 0.66, blue: 0.6),
                    Color(red: 0.66, green: 0.56, blue: 0.49),
                    Color(red: 0.74, green: 0.62, blue: 0.54)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle overlay pattern
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.0)
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 200
                        ))
                        .frame(width: 400, height: 400)
                        .offset(x: geometry.size.width / 2 - 200, y: geometry.size.height / 2 - 200)
                    
                    Ellipse()
                        .fill(Color(red: 0.82, green: 0.72, blue: 0.62).opacity(0.12))
                        .frame(width: 300, height: 200)
                        .offset(x: 20, y: 50)
                        .blur(radius: 45)
                        .rotationEffect(.degrees(-15))
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)
                
                // Icon and title section
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Text("Global Database")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("🌍")
                                .font(.system(size: 28))
                        }
                        
                        Text("Access our comprehensive bird egg collection")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                    .frame(height: 60)
                
                // Features list
                VStack(alignment: .leading, spacing: 28) {
                    FeatureRow(
                        icon: "map.fill",
                        title: "Worldwide Coverage",
                        description: "Identify eggs from all continents"
                    )
                    
                    FeatureRow(
                        icon: "book.fill",
                        title: "Expert Knowledge",
                        description: "Curated by ornithologists"
                    )
                    
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Growing Database",
                        description: "New species added weekly"
                    )
                    
                    FeatureRow(
                        icon: "hand.raised.fill",
                        title: "Conservation Focus",
                        description: "Support wildlife protection"
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue button
                Button(action: onContinue) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.35))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

struct LoadScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.78, green: 0.68, blue: 0.62),
                    Color(red: 0.65, green: 0.55, blue: 0.48),
                    Color(red: 0.72, green: 0.6, blue: 0.52)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle overlay pattern
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 350, height: 350)
                        .offset(x: -100, y: -50)
                        .blur(radius: 40)
                    
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 400, height: 400)
                        .offset(x: geometry.size.width - 150, y: geometry.size.height - 200)
                        .blur(radius: 50)
                    
                    Circle()
                        .fill(Color(red: 0.8, green: 0.7, blue: 0.6).opacity(0.15))
                        .frame(width: 250, height: 250)
                        .offset(x: 50, y: geometry.size.height / 2)
                        .blur(radius: 30)
                }
            }
            .ignoresSafeArea()
            
            ProgressView()
                .tint(.white)
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .padding(.bottom, 50)
        }
    }
}

#Preview {
    OnboardingView()
}
