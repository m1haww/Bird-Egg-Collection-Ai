import SwiftUI
import StoreKit
import Combine

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProduct: Product?
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @State private var isProcessing = false
    @State private var isFreeTrialEnabled = true
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    
    // Callback for when user skips paywall
    let onSkip: (() -> Void)?
    
    init(onSkip: (() -> Void)? = nil) {
        self.onSkip = onSkip
    }
    
    private var buttonText: String {
        if isFreeTrialEnabled {
            return "Try for Free"
        } else {
            return "Subscribe Now"
        }
    }
    
    var body: some View {
        ZStack {
            // Background - matching the app's beige theme
            Color(red: 0.98, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { 
                        print("🔴 Close button tapped - skipping paywall")
                        
                        // Call the skip callback to complete onboarding
                        onSkip?()
                        
                        // Dismiss the paywall
                        dismiss()
                        presentationMode.wrappedValue.dismiss()
                        
                        print("✅ Paywall skipped and dismissed")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.gray.opacity(0.8))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Premium Badge and Title
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .fill(Color(red: 0.65, green: 0.55, blue: 0.48))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Unlimited Access")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Features List
                        VStack(alignment: .leading, spacing: 20) {
                            SimpleFeatureRow(
                                icon: "drop.fill",
                                iconColor: Color(red: 0.65, green: 0.55, blue: 0.48),
                                title: "Identify unlimited bird species"
                            )
                            
                            SimpleFeatureRow(
                                icon: "xmark.circle.fill",
                                iconColor: Color.red.opacity(0.7),
                                title: "No annoying paywalls"
                            )
                            
                            SimpleFeatureRow(
                                icon: "infinity",
                                iconColor: Color(red: 0.65, green: 0.55, blue: 0.48),
                                title: "Unlimited app usage"
                            )
                        }
                        .padding(.horizontal, 30)
                        
                        // Subscription Plans
                        VStack(spacing: 12) {
                            // Monthly Plan
                            SubscriptionPlanCard(
                                product: subscriptionManager.subscriptions.first { $0.id == "com.eggai.monthly" },
                                isMonthly: true,
                                isSelected: !isFreeTrialEnabled && (selectedProduct?.id == "com.eggai.monthly" || (!isFreeTrialEnabled && selectedProduct == nil)),
                                isProcessing: isProcessing
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if let monthlyProduct = subscriptionManager.subscriptions.first(where: { $0.id == "com.eggai.monthly" }) {
                                        selectedProduct = monthlyProduct
                                        isFreeTrialEnabled = false
                                    } else {
                                        print("Selected monthly plan (product not loaded yet)")
                                        isFreeTrialEnabled = false
                                    }
                                }
                            }
                            
                            // Weekly Plan
                            SubscriptionPlanCard(
                                product: subscriptionManager.subscriptions.first { $0.id == "com.eggai.weekly" },
                                isMonthly: false,
                                isSelected: isFreeTrialEnabled && (selectedProduct?.id == "com.eggai.weekly" || (isFreeTrialEnabled && selectedProduct == nil)),
                                isProcessing: isProcessing
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if let weeklyProduct = subscriptionManager.subscriptions.first(where: { $0.id == "com.eggai.weekly" }) {
                                        selectedProduct = weeklyProduct
                                        isFreeTrialEnabled = true
                                    } else {
                                        print("Selected weekly plan (product not loaded yet)")
                                        isFreeTrialEnabled = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Free Trial Toggle
                        VStack(spacing: 15) {
                            HStack {
                                Text("Free Trial Enabled")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isFreeTrialEnabled.toggle()
                                        updateSelectedPlan()
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(isFreeTrialEnabled ? Color(red: 0.65, green: 0.55, blue: 0.48) : Color.gray.opacity(0.3))
                                            .frame(width: 50, height: 30)
                                        
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 26, height: 26)
                                            .offset(x: isFreeTrialEnabled ? 10 : -10)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Purchase Button
                            Button(action: purchaseSubscription) {
                                HStack {
                                    if isProcessing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text(buttonText)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0.65, green: 0.55, blue: 0.48))
                                .cornerRadius(16)
                            }
                            .disabled(selectedProduct == nil || isProcessing)
                            .padding(.horizontal, 20)
                        }
                        
                        // Restore and Terms
                        VStack(spacing: 15) {
                            HStack {
                                Button(action: {
                                    Task {
                                        await restorePurchases()
                                    }
                                }) {
                                    HStack {
                                        if isProcessing {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        }
                                        Text("Restore")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .disabled(isProcessing)
                                
                                Spacer()
                                
                                Button(action: {
                                    if let url = URL(string: "https://www.termsfeed.com/live/d81c1b9b-7c23-496a-b1fb-ce3475c14788") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("Terms of Use & Privacy Policy")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            
            if subscriptionManager.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onReceive(subscriptionManager.$hasUnlockedPremium) { isPremium in
            if isPremium {
                print("🎉 Premium activated, dismissing paywall")
                dismiss()
            }
        }
        .task {
            if subscriptionManager.subscriptions.isEmpty {
                await subscriptionManager.loadProducts()
            }
            if !subscriptionManager.subscriptions.isEmpty && selectedProduct == nil {
                // Default selection based on free trial toggle
                updateSelectedPlan()
            }
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK") { }
        } message: {
            Text(restoreMessage)
        }
    }
    
    private func purchaseSubscription() {
        guard let product = selectedProduct else { return }
        
        isProcessing = true
        
        Task {
            do {
                let transaction = try await subscriptionManager.purchase(product)
                if transaction != nil {
                    await MainActor.run {
                        dismiss()
                    }
                }
            } catch {
                print("Purchase failed: \(error)")
            }
            
            await MainActor.run {
                isProcessing = false
            }
        }
    }
    
    private func restorePurchases() async {
        await MainActor.run {
            isProcessing = true
        }
        
        do {
            try await subscriptionManager.restorePurchases()
            
            await MainActor.run {
                if subscriptionManager.hasUnlockedPremium {
                    restoreMessage = "Your subscription has been restored successfully!"
                    showRestoreAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } else {
                    restoreMessage = "No active subscriptions found. Please subscribe to continue."
                    showRestoreAlert = true
                }
                isProcessing = false
            }
        } catch {
            await MainActor.run {
                restoreMessage = "Failed to restore purchases: \(error.localizedDescription)"
                showRestoreAlert = true
                isProcessing = false
            }
            print("Restore failed: \(error)")
        }
    }
    
    private func updateSelectedPlan() {
        if isFreeTrialEnabled {
            // Select weekly plan with free trial
            if let weeklyProduct = subscriptionManager.subscriptions.first(where: { $0.id == "com.eggai.weekly" }) {
                selectedProduct = weeklyProduct
            }
        } else {
            // Select monthly plan
            if let monthlyProduct = subscriptionManager.subscriptions.first(where: { $0.id == "com.eggai.monthly" }) {
                selectedProduct = monthlyProduct
            }
        }
    }
}

struct SimpleFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

struct PaywallFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SubscriptionPlanCard: View {
    let product: Product?
    let isMonthly: Bool
    let isSelected: Bool
    let isProcessing: Bool
    let action: () -> Void
    
    private var savings: String? {
        if isMonthly {
            return "SAVE 46%"
        }
        return nil
    }
    
    private var periodText: String {
        if let product = product, let subscription = product.subscription {
            let period = subscription.subscriptionPeriod
            let unit = period.unit
            let value = period.value
            
            // Debug logging
            print("🔍 Product: \(product.id), Unit: \(unit), Value: \(value)")
            
            if value == 1 {
                switch unit {
                case .day: return "day"
                case .week: return "week"
                case .month: 
                    // Check if this is supposed to be weekly based on product ID
                    if product.id.contains("weekly") {
                        return "week"
                    }
                    return "month"
                case .year: return "year"
                @unknown default: return ""
                }
            } else {
                switch unit {
                case .day: return "\(value) days"
                case .week: return "\(value) weeks"
                case .month:
                    // Check if this is supposed to be weekly based on product ID
                    if product.id.contains("weekly") {
                        return "\(value) weeks"
                    }
                    return "\(value) months"
                case .year: return "\(value) years"
                @unknown default: return ""
                }
            }
        } else {
            return isMonthly ? "month" : "week"
        }
    }
    
    private var displayPrice: String {
        return product?.displayPrice ?? (isMonthly ? "USD 6.99" : "USD 2.99")
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48) : Color.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.65, green: 0.55, blue: 0.48))
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(isMonthly ? "Monthly Plan" : "Weekly Plan")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48) : .black)
                        
                        Spacer()
                        
                        if isMonthly {
                            Text("SAVE 46%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(8)
                        } else {
                            Text("FREE TRIAL")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.pink.opacity(0.8))
                                .cornerRadius(8)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(displayPrice)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48) : .black)
                        
                        Text("per \(periodText)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48).opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2.5 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48).opacity(0.2) : .black.opacity(0.05), 
                   radius: isSelected ? 8 : 5, 
                   x: 0, 
                   y: isSelected ? 4 : 2)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isProcessing)
    }
}

#Preview {
    PaywallView()
}
