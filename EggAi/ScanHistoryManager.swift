//
//  ScanHistoryManager.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import Foundation
import UIKit
import CryptoKit

class ScanHistoryManager: ObservableObject {
    static let shared = ScanHistoryManager()
    
    @Published var scanHistory: [ScanHistoryItem] = []
    private let documentsDirectory: URL
    private let historyFileURL: URL
    private let scannedImagesDirectory: URL
    private let maxHistoryItems = 50
    
    private init() {
        // Setup directories
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        historyFileURL = documentsDirectory.appendingPathComponent("scan_history.json")
        scannedImagesDirectory = documentsDirectory.appendingPathComponent("ScannedImages", isDirectory: true)
        
        // Create scanned images directory if needed
        try? FileManager.default.createDirectory(at: scannedImagesDirectory, withIntermediateDirectories: true)
        
        loadHistory()
    }
    
    func addScanResult(image: UIImage, result: String, scientificName: String, confidence: Int) {
        // Save image to disk and get filename
        let imageId = UUID().uuidString
        let imageFileName = "\(imageId).jpg"
        
        // Save image to disk
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let imageURL = scannedImagesDirectory.appendingPathComponent(imageFileName)
            try? imageData.write(to: imageURL)
        }
        
        // Create scan item with image reference
        let scanItem = PersistableScanHistoryItem(
            id: imageId,
            imageFileName: imageFileName,
            result: result,
            scientificName: scientificName,
            date: Date(),
            confidence: confidence
        )
        
        // Convert to display item and add to history
        if let displayItem = scanItem.toScanHistoryItem(imagesDirectory: scannedImagesDirectory) {
            scanHistory.insert(displayItem, at: 0)
        }
        
        // Keep only the last maxHistoryItems scans
        if scanHistory.count > maxHistoryItems {
            // Remove old items and their images
            let itemsToRemove = Array(scanHistory.suffix(from: maxHistoryItems))
            scanHistory = Array(scanHistory.prefix(maxHistoryItems))
            
            // Clean up old image files
            for item in itemsToRemove {
                if let fileName = extractFileName(from: item) {
                    let imageURL = scannedImagesDirectory.appendingPathComponent(fileName)
                    try? FileManager.default.removeItem(at: imageURL)
                }
            }
        }
        
        saveHistory()
    }
    
    func clearHistory() {
        // Remove all image files
        for item in scanHistory {
            if let fileName = extractFileName(from: item) {
                let imageURL = scannedImagesDirectory.appendingPathComponent(fileName)
                try? FileManager.default.removeItem(at: imageURL)
            }
        }
        
        scanHistory.removeAll()
        saveHistory()
    }
    
    private func saveHistory() {
        // Convert to persistable items
        let persistableItems = scanHistory.compactMap { item -> PersistableScanHistoryItem? in
            guard let fileName = extractFileName(from: item) else { return nil }
            
            return PersistableScanHistoryItem(
                id: item.id.uuidString,
                imageFileName: fileName,
                result: item.result,
                scientificName: item.scientificName,
                date: item.date,
                confidence: item.confidence
            )
        }
        
        // Encode and save to file
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(persistableItems)
            try data.write(to: historyFileURL)
        } catch {
            print("Failed to save scan history: \(error)")
        }
    }
    
    private func loadHistory() {
        guard FileManager.default.fileExists(atPath: historyFileURL.path) else {
            scanHistory = []
            return
        }
        
        do {
            let data = try Data(contentsOf: historyFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let persistableItems = try decoder.decode([PersistableScanHistoryItem].self, from: data)
            
            // Convert to display items
            scanHistory = persistableItems.compactMap { $0.toScanHistoryItem(imagesDirectory: scannedImagesDirectory) }
        } catch {
            print("Failed to load scan history: \(error)")
            scanHistory = []
        }
    }
    
    private func extractFileName(from item: ScanHistoryItem) -> String? {
        // Extract filename from the item ID or create from ID
        return "\(item.id.uuidString).jpg"
    }
}

// MARK: - Persistable Model

private struct PersistableScanHistoryItem: Codable {
    let id: String
    let imageFileName: String
    let result: String
    let scientificName: String
    let date: Date
    let confidence: Int
    
    func toScanHistoryItem(imagesDirectory: URL) -> ScanHistoryItem? {
        let imageURL = imagesDirectory.appendingPathComponent(imageFileName)
        
        guard let imageData = try? Data(contentsOf: imageURL) else {
            return nil
        }
        
        return ScanHistoryItem(
            id: UUID(uuidString: id) ?? UUID(),
            imageData: imageData,
            result: result,
            scientificName: scientificName,
            date: date,
            confidence: confidence
        )
    }
}