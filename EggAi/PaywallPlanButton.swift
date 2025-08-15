//
//  PaywallPlanButton.swift
//  EggAi
//
//  Simplified subscription plan button
//

import SwiftUI

struct PaywallPlanButton: View {
    let title: String
    let price: String
    let strikethroughPrice: String?
    let period: String
    let badge: String?
    let badgeColor: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Selection indicator
                Image(systemName: isSelected ? "circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(selectionColor)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    titleRow
                    priceRow
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .background(backgroundView)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var selectionColor: Color {
        isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48) : Color(red: 0.8, green: 0.7, blue: 0.65)
    }
    
    @ViewBuilder
    private var titleRow: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            if let badge = badge {
                Text(badge)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badgeColor)
                    .cornerRadius(12)
            }
        }
    }
    
    @ViewBuilder
    private var priceRow: some View {
        HStack(spacing: 6) {
            if let strikethroughPrice = strikethroughPrice {
                Text(strikethroughPrice)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .strikethrough()
            }
            
            Text(price)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(priceTextColor)
            
            Text(period)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(priceTextColor)
        }
    }
    
    private var priceTextColor: Color {
        isSelected ? .black : Color.gray.opacity(0.8)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(isSelected ? Color(red: 0.95, green: 0.92, blue: 0.9) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color(red: 0.65, green: 0.55, blue: 0.48) : Color(red: 0.8, green: 0.7, blue: 0.65),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
    }
}