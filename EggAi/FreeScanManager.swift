//
//  FreeScanManager.swift
//  EggAi
//
//  Manages free scan attempts for trial users
//

import SwiftUI

class FreeScanManager: ObservableObject {
    static let shared = FreeScanManager()
    
    @Published var remainingFreeScans: Int = 1
    @AppStorage("hasUsedFreeScan") private var hasUsedFreeScan = false
    
    private init() {
        // Reset remaining scans based on whether user has used their free scan
        remainingFreeScans = hasUsedFreeScan ? 0 : 1
    }
    
    func canScan(isPremium: Bool) -> Bool {
        if isPremium {
            return true // Premium users have unlimited scans
        }
        return remainingFreeScans > 0
    }
    
    func useScan() {
        if remainingFreeScans > 0 {
            remainingFreeScans -= 1
            hasUsedFreeScan = true
            print("🔢 Free scan used. Remaining: \(remainingFreeScans)")
        }
    }
    
    func resetForPremium() {
        // Called when user becomes premium
        remainingFreeScans = -1 // Unlimited for premium
        print("👑 Premium activated - unlimited scans enabled")
    }
    
    func getScanLimitMessage() -> String {
        if remainingFreeScans == 1 {
            return "1 free scan remaining"
        } else if remainingFreeScans == 0 {
            return "Free trial used - upgrade for unlimited scans"
        } else {
            return "Unlimited scans"
        }
    }
}