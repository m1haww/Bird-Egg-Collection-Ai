////
////  PaywallView+StoreKit.swift
////  EggAi
////
////  StoreKit integration for PaywallView
////
//
//import SwiftUI
//import StoreKit
//
//struct PaywallViewWithStore: View {
//    @StateObject private var storeManager = StoreManager.shared
//    @State private var selectedProduct: Product?
//    @State private var showRestoreAlert = false
//    @State private var showTermsSheet = false
//    @State private var isPurchasing = false
//    @State private var showError = false
//    @State private var errorMessage = ""
//    
//    let onComplete: () -> Void
//    
//    var weeklyProduct: Product? {
//        storeManager.products.first { $0.id.contains("weekly") }
//    }
//    
//    var yearlyProduct: Product? {
//        storeManager.products.first { $0.id.contains("yearly") }
//    }
//    
//    var body: some View {
//        ZStack {
//            Color(red: 0.96, green: 0.96, blue: 0.96)
//                .ignoresSafeArea()
//            
//            if storeManager.isLoading {
//                VStack {
//                    ProgressView()
//                        .scaleEffect(1.5)
//                    Text("Loading products...")
//                        .font(.system(size: 16))
//                        .foregroundColor(.gray)
//                        .padding(.top, 20)
//                }
//            } else {
//                VStack(spacing: 0) {
//                    // Close button
//                    HStack {
//                        Spacer()
//                        Button(action: onComplete) {
//                            Image(systemName: "xmark.circle.fill")
//                                .font(.system(size: 28))
//                                .foregroundColor(.gray.opacity(0.6))
//                        }
//                        .padding(.trailing, 20)
//                        .padding(.top, 60)
//                    }
//                    
//                    Spacer()
//                        .frame(height: 40)
//                    
//                    // Icon and title
//                    VStack(spacing: 24) {
//                        ZStack {
//                            Circle()
//                                .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
//                                .frame(width: 100, height: 100)
//                            
//                            Circle()
//                                .fill(Color(red: 0.65, green: 0.55, blue: 0.48))
//                                .frame(width: 80, height: 80)
//                                .overlay(
//                                    Image(systemName: "leaf.fill")
//                                        .font(.system(size: 32))
//                                        .foregroundColor(.white)
//                                )
//                        }
//                        
//                        Text("Unlimited Access")
//                            .font(.system(size: 34, weight: .bold))
//                            .foregroundColor(.black)
//                    }
//                    
//                    Spacer()
//                        .frame(height: 50)
//                    
//                    // Features
//                    VStack(alignment: .leading, spacing: 24) {
//                        FeatureItem(
//                            icon: "drop.fill",
//                            text: "Identify unlimited bird eggs",
//                            color: Color(red: 0.65, green: 0.55, blue: 0.48)
//                        )
//                        
//                        FeatureItem(
//                            icon: "xmark.circle.fill",
//                            text: "No identification limits",
//                            color: Color(red: 0.9, green: 0.3, blue: 0.3)
//                        )
//                        
//                        FeatureItem(
//                            icon: "infinity",
//                            text: "Full egg database access",
//                            color: Color(red: 0.6, green: 0.4, blue: 0.8)
//                        )
//                    }
//                    .padding(.horizontal, 50)
//                    
//                    Spacer()
//                    
//                    // Subscription options
//                    VStack(spacing: 12) {
//                        // Yearly plan
//                        if let yearly = yearlyProduct {
//                            SubscriptionButton(
//                                product: yearly,
//                                isSelected: selectedProduct == yearly,
//                                badge: "SAVE 90%",
//                                badgeColor: .orange,
//                                showStrikethrough: true
//                            ) {
//                                selectedProduct = yearly
//                            }
//                        }
//                        
//                        // Weekly plan with free trial
//                        if let weekly = weeklyProduct {
//                            SubscriptionButton(
//                                product: weekly,
//                                isSelected: selectedProduct == weekly,
//                                badge: "3 DAY TRIAL",
//                                badgeColor: Color(red: 0.95, green: 0.3, blue: 0.5)
//                            ) {
//                                selectedProduct = weekly
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 24)
//                    
//                    Spacer()
//                        .frame(height: 20)
//                    
//                    // CTA Button
//                    Button(action: {
//                        Task {
//                            await purchaseSelectedProduct()
//                        }
//                    }) {
//                        HStack {
//                            if isPurchasing {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                    .scaleEffect(0.8)
//                            } else {
//                                Text(selectedProduct?.id.contains("weekly") == true ? "Start Free Trial" : "Subscribe Now")
//                                    .font(.system(size: 18, weight: .semibold))
//                                    .foregroundColor(.white)
//                                
//                                Image(systemName: "arrow.right")
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .foregroundColor(.white)
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 56)
//                        .background(Color(red: 0.65, green: 0.55, blue: 0.48))
//                        .cornerRadius(28)
//                    }
//                    .disabled(selectedProduct == nil || isPurchasing)
//                    .opacity(selectedProduct == nil ? 0.6 : 1.0)
//                    .padding(.horizontal, 24)
//                    .padding(.top, 20)
//                    
//                    // Footer links
//                    HStack {
//                        Button("Restore") {
//                            Task {
//                                await restorePurchases()
//                            }
//                        }
//                        .font(.system(size: 14))
//                        .foregroundColor(.gray.opacity(0.7))
//                        
//                        Spacer()
//                        
//                        Button("Terms & Privacy") {
//                            showTermsSheet = true
//                        }
//                        .font(.system(size: 14))
//                        .foregroundColor(.gray.opacity(0.7))
//                    }
//                    .padding(.horizontal, 30)
//                    .padding(.top, 20)
//                    .padding(.bottom, 40)
//                }
//            }
//            
//            if isPurchasing {
//                Color.black.opacity(0.3)
//                    .ignoresSafeArea()
//            }
//        }
//        .onAppear {
//            // Select yearly by default
//            if selectedProduct == nil {
//                selectedProduct = yearlyProduct
//            }
//        }
//        .alert("Purchase Restored", isPresented: $showRestoreAlert) {
//            Button("OK", role: .cancel) { 
//                if storeManager.isSubscribed {
//                    onComplete()
//                }
//            }
//        } message: {
//            Text(storeManager.isSubscribed ? 
//                 "Your subscription has been restored successfully!" : 
//                 "No active subscriptions found. Please subscribe to continue.")
//        }
//        .alert("Error", isPresented: $showError) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(errorMessage)
//        }
//        .sheet(isPresented: $showTermsSheet) {
//            TermsAndPrivacyView(isPresented: $showTermsSheet)
//        }
//    }
//    
//    @MainActor
//    private func purchaseSelectedProduct() async {
//        guard let product = selectedProduct else { return }
//        
//        isPurchasing = true
//        
//        do {
//            if let transaction = try await storeManager.purchase(product) {
//                // Purchase successful
//                onComplete()
//            }
//        } catch {
//            errorMessage = "Purchase failed: \(error.localizedDescription)"
//            showError = true
//        }
//        
//        isPurchasing = false
//    }
//    
//    @MainActor
//    private func restorePurchases() async {
//        isPurchasing = true
//        await storeManager.restorePurchases()
//        isPurchasing = false
//        showRestoreAlert = true
//    }
//}
//
//// SubscriptionButton moved to SubscriptionButton+Simplified.swift
