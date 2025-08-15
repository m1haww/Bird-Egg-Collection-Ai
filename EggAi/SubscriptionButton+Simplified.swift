//
//  SubscriptionButton+Simplified.swift
//  EggAi
//
//  Simplified version to avoid compiler timeout
//

import SwiftUI
import StoreKit

struct SubscriptionButton: View {
    let product: Product
    let isSelected: Bool
    var badge: String? = nil
    var badgeColor: Color = .orange
    var showStrikethrough: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                SelectionIndicator(isSelected: isSelected)
                ProductInfo(
                    product: product,
                    isSelected: isSelected,
                    badge: badge,
                    badgeColor: badgeColor,
                    showStrikethrough: showStrikethrough
                )
            }
            .padding(18)
            .background(backgroundView)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(backgroundColor)
            .overlay(borderOverlay)
    }
    
    private var backgroundColor: Color {
        isSelected ? Color(red: 0.95, green: 0.92, blue: 0.9) : Color.white
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(borderColor, lineWidth: borderWidth)
    }
    
    private var borderColor: Color {
        isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48) : Color(red: 0.8, green: 0.7, blue: 0.65)
    }
    
    private var borderWidth: CGFloat {
        isSelected ? 2 : 1
    }
}

struct SelectionIndicator: View {
    let isSelected: Bool
    
    var body: some View {
        Image(systemName: isSelected ? "circle.fill" : "circle")
            .font(.system(size: 20))
            .foregroundColor(indicatorColor)
    }
    
    private var indicatorColor: Color {
        isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48) : Color(red: 0.8, green: 0.7, blue: 0.65)
    }
}

struct ProductInfo: View {
    let product: Product
    let isSelected: Bool
    let badge: String?
    let badgeColor: Color
    let showStrikethrough: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HeaderRow(
                productName: product.displayName,
                badge: badge,
                badgeColor: badgeColor
            )
            PriceRow(
                product: product,
                isSelected: isSelected,
                showStrikethrough: showStrikethrough
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HeaderRow: View {
    let productName: String
    let badge: String?
    let badgeColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            Text(productName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            if let badge = badge {
                BadgeView(text: badge, color: badgeColor)
            }
        }
    }
}

struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(12)
    }
}

struct PriceRow: View {
    let product: Product
    let isSelected: Bool
    let showStrikethrough: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            if showStrikethrough && product.id.contains("yearly") {
                StrikethroughPrice()
            }
            
            CurrentPrice(
                product: product,
                isSelected: isSelected
            )
        }
    }
}

struct StrikethroughPrice: View {
    var body: some View {
        let weeklyTotal = Decimal(5.99) * 52
        let formatter = NumberFormatter()
         
        Text(formatter.string(from: NSDecimalNumber(decimal: weeklyTotal)) ?? "$311.48")
            .font(.system(size: 14))
            .foregroundColor(.gray)
            .strikethrough()
    }
}

struct CurrentPrice: View {
    let product: Product
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text(product.displayPrice)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(priceColor)
            
//            if let period = product.subscription?.subscriptionPeriod {
//                Text("per \(period.unit.localizedDescription(plural: false))")
//                    .font(.system(size: 15, weight: .medium))
//                    .foregroundColor(priceColor)
//            }
        }
    }
    
    private var priceColor: Color {
        isSelected ? .black : Color.gray.opacity(0.8)
    }
}
