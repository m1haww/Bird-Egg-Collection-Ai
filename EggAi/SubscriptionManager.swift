import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var subscriptions: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []
    @Published var subscriptionGroupStatus: RenewalState?
    @Published var isLoading = false
    @Published var hasUnlockedPremium = false
    
    private let productIds = [
        "com.vemix.weekly",
        "com.vemix.yearly"
    ]
    
    private var updateListenerTask: Task<Void, Error>?
    
    enum RenewalState {
        case subscribed(Product, Product.SubscriptionInfo.RenewalState)
        case expired(Product, expirationDate: Date?)
        case revoked(Product, revokedDate: Date?)
    }
    
    private init() {
        Task {
            await loadProducts()
            await updateCustomerProductStatus()
        }
        
        updateListenerTask = Task {
            await listenForTransactions()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                
                await updateCustomerProductStatus()
                
                await transaction.finish()
            } catch {
                print("Transaction failed verification: \(error)")
            }
        }
    }
    
    @MainActor
    func loadProducts() async {
        isLoading = true
        do {
            subscriptions = try await Product.products(for: productIds)
                .sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed to load products: \(error)")
            subscriptions = []
        }
        isLoading = false
    }
    
    @MainActor
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            await updateCustomerProductStatus()
            
            await transaction.finish()
            
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        print("🔄 Checking subscription status...")
        var purchasedSubscriptions: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                print("✅ Found active subscription: \(transaction.productID)")
                
                if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                    purchasedSubscriptions.append(subscription)
                }
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
        
        self.purchasedSubscriptions = purchasedSubscriptions
        
        let previousStatus = hasUnlockedPremium
        hasUnlockedPremium = !purchasedSubscriptions.isEmpty
        
        if hasUnlockedPremium {
            print("👑 Premium Status: ACTIVE (Found \(purchasedSubscriptions.count) active subscription(s))")
        } else {
            print("🔒 Premium Status: INACTIVE (No active subscriptions)")
        }
        
        if previousStatus != hasUnlockedPremium {
            print("📢 Premium status changed from \(previousStatus) to \(hasUnlockedPremium)")
        }
        
        // Check subscription status for purchased products
        if let purchasedProduct = subscriptions.first(where: { purchasedSubscriptions.contains($0) }) {
            if let status = try? await purchasedProduct.subscription?.status {
                if let renewalInfo = status.first {
                    subscriptionGroupStatus = renewalInfo.state.toRenewalState(for: purchasedProduct)
                }
            }
        }
    }
    
    @MainActor
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updateCustomerProductStatus()
    }
    
    func isPremiumUser() -> Bool {
        return hasUnlockedPremium
    }
    
    @MainActor
    func refreshStatusIfNeeded() async {
        // Only refresh if we haven't checked in a while or after a purchase
        // This prevents excessive API calls
        await updateCustomerProductStatus()
    }
    
    func tier(for productId: String) -> SubscriptionTier {
        switch productId {
        case "com.vemix.weekly":
            return .weekly
        case "com.vemix.yearly":
            return .yearly
        default:
            return .none
        }
    }
}

extension Product.SubscriptionPeriod.Unit {
    var localizedDescription: String {
        switch self {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return "period"
        }
    }
}

extension Product.SubscriptionOffer.PaymentMode {
    var localizedDescription: String {
        switch self {
        case .freeTrial: return "Free Trial"
        case .payAsYouGo: return "Pay as you go"
        case .payUpFront: return "Pay upfront"
        default: return "Offer"
        }
    }
}

extension Product.SubscriptionInfo.RenewalState {
    func toRenewalState(for product: Product?) -> SubscriptionManager.RenewalState? {
        guard let product = product else { return nil }
        
        switch self {
        case .subscribed:
            return .subscribed(product, self)
        case .expired:
            return .expired(product, expirationDate: nil)
        case .inBillingRetryPeriod:
            return .subscribed(product, self)
        case .inGracePeriod:
            return .subscribed(product, self)
        case .revoked:
            return .revoked(product, revokedDate: nil)
        default:
            return nil
        }
    }
}

enum SubscriptionTier: Int, Comparable {
    case none = 0
    case weekly = 1
    case yearly = 2
    
    static func < (lhs: SubscriptionTier, rhs: SubscriptionTier) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

enum StoreError: Error, LocalizedError {
    case failedVerification
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Your purchase could not be verified by the App Store."
        case .productNotFound:
            return "The product could not be found."
        }
    }
}

