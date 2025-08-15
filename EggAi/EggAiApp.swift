//
//  EggAiApp.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI

@main
struct EggAiApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
