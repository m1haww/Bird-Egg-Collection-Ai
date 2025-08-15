//
//  ImageCache.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import SwiftUI
import Foundation
import CryptoKit

class ImageCache {
    static let shared = ImageCache()
    private var memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheURL: URL
    private let ioQueue = DispatchQueue(label: "com.eggai.imagecache", attributes: .concurrent)
    
    private init() {
        // Setup memory cache
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        memoryCache.countLimit = 50 // Maximum 50 images in memory
        
        // Setup disk cache directory
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        
        // Create cache directory if needed
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        
        // Clean old cache files on init
        cleanExpiredCache()
    }
    
    // MARK: - Public Methods
    
    func get(_ key: String) -> UIImage? {
        let safeKey = sanitizeKey(key)
        
        // Check memory cache first
        if let image = memoryCache.object(forKey: NSString(string: safeKey)) {
            return image
        }
        
        // Check disk cache
        if let image = loadFromDisk(key: safeKey) {
            // Add to memory cache for faster access
            memoryCache.setObject(image, forKey: NSString(string: safeKey))
            return image
        }
        
        return nil
    }
    
    func set(_ image: UIImage, for key: String) {
        let safeKey = sanitizeKey(key)
        
        // Save to memory cache
        let cost = image.jpegData(compressionQuality: 0.8)?.count ?? 0
        memoryCache.setObject(image, forKey: NSString(string: safeKey), cost: cost)
        
        // Save to disk asynchronously
        ioQueue.async(flags: .barrier) {
            self.saveToDisk(image: image, key: safeKey)
        }
    }
    
    func clear() {
        // Clear memory cache
        memoryCache.removeAllObjects()
        
        // Clear disk cache
        ioQueue.async(flags: .barrier) {
            try? FileManager.default.removeItem(at: self.diskCacheURL)
            try? FileManager.default.createDirectory(at: self.diskCacheURL, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func sanitizeKey(_ key: String) -> String {
        // Create a safe filename from the key (URL or identifier)
        let hash = SHA256.hash(data: Data(key.utf8))
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func diskCachePath(for key: String) -> URL {
        return diskCacheURL.appendingPathComponent(key + ".jpg")
    }
    
    private func loadFromDisk(key: String) -> UIImage? {
        let fileURL = diskCachePath(for: key)
        
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            return nil
        }
        
        // Check if file is older than 30 days
        if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let modificationDate = attributes[.modificationDate] as? Date,
           Date().timeIntervalSince(modificationDate) > 30 * 24 * 60 * 60 {
            // File is too old, remove it
            try? FileManager.default.removeItem(at: fileURL)
            return nil
        }
        
        return image
    }
    
    private func saveToDisk(image: UIImage, key: String) {
        let fileURL = diskCachePath(for: key)
        
        // Convert to JPEG with compression
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        try? data.write(to: fileURL)
    }
    
    private func cleanExpiredCache() {
        ioQueue.async(flags: .barrier) {
            guard let files = try? FileManager.default.contentsOfDirectory(at: self.diskCacheURL, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]) else { return }
            
            let thirtyDaysAgo = Date().addingTimeInterval(-30 * 24 * 60 * 60)
            var totalSize: Int64 = 0
            var filesToDelete: [URL] = []
            var filesByDate: [(url: URL, date: Date, size: Int64)] = []
            
            // Collect file information
            for fileURL in files {
                guard let attributes = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                      let modificationDate = attributes.contentModificationDate,
                      let fileSize = attributes.fileSize else { continue }
                
                if modificationDate < thirtyDaysAgo {
                    filesToDelete.append(fileURL)
                } else {
                    totalSize += Int64(fileSize)
                    filesByDate.append((fileURL, modificationDate, Int64(fileSize)))
                }
            }
            
            // Delete old files
            for fileURL in filesToDelete {
                try? FileManager.default.removeItem(at: fileURL)
            }
            
            // If cache is over 200MB, remove oldest files
            let maxCacheSize: Int64 = 200 * 1024 * 1024 // 200MB
            if totalSize > maxCacheSize {
                // Sort by date, oldest first
                filesByDate.sort { $0.date < $1.date }
                
                var currentSize = totalSize
                for file in filesByDate {
                    if currentSize <= maxCacheSize { break }
                    
                    try? FileManager.default.removeItem(at: file.url)
                    currentSize -= file.size
                }
            }
        }
    }
}

struct CachedAsyncImage<Content>: View where Content: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content
    
    @State private var phase: AsyncImagePhase = .empty
    
    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
            .onChange(of: url) { _ in
                loadImage()
            }
    }
    
    private func loadImage() {
        guard let url = url else {
            phase = .failure(URLError(.badURL))
            return
        }
        
        let urlString = url.absoluteString
        
        // Check cache first
        if let cachedImage = ImageCache.shared.get(urlString) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }
        
        phase = .empty
        
        // Load from network
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    phase = .failure(error)
                    return
                }
                
                guard let data = data,
                      let uiImage = UIImage(data: data) else {
                    phase = .failure(URLError(.cannotDecodeContentData))
                    return
                }
                
                // Cache the image
                ImageCache.shared.set(uiImage, for: urlString)
                phase = .success(Image(uiImage: uiImage))
            }
        }.resume()
    }
}