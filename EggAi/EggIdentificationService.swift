//
//  EggIdentificationService.swift
//  EggAi
//
//  Created by Mihail Ozun on 11.08.2025.
//

import Foundation
import UIKit

class EggIdentificationService {
    static let shared = EggIdentificationService()
    
    private var apiKey = ""
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    private let configURL = "https://firebasestorage.googleapis.com/v0/b/social-media-finder-4869f.appspot.com/o/file.json?alt=media&token=dcf46b46-e1f7-4615-ad8a-4d030cd58e84"
    
    private init() {
        fetchAPIKey()
    }
    
    private func fetchAPIKey() {
        guard let url = URL(string: configURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let key = json["apiKey"] as? String else {
                print("❌ Failed to fetch API key from remote config")
                return
            }
            
            self.apiKey = key
            print("✅ API key loaded from remote config")
        }.resume()
    }
    
    func identifyEgg(from image: UIImage, completion: @escaping (BirdEgg?, Int) -> Void) {
        print("🔍 identifyEgg called")
        
        // Check if API key is loaded
        if apiKey.isEmpty {
            print("⏳ API key not loaded yet, waiting...")
            // Retry after a delay to allow fetchAPIKey to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.apiKey.isEmpty {
                    print("❌ Failed to load API key from remote config")
                    completion(nil, 0)
                    return
                }
                self.identifyEgg(from: image, completion: completion)
            }
            return
        }
        
        print("🔑 API Key: \(apiKey.prefix(10))...") // Only print first 10 chars for security
        print("✅ Using REAL OpenAI API")
        
        // First, load all eggs from JSON
        guard let eggDatabase = loadEggDatabase() else {
            print("❌ Failed to load egg database")
            completion(nil, 0)
            return
        }
        
        print("📚 Loaded \(eggDatabase.eggs.count) eggs from database")
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data")
            completion(nil, 0)
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        print("📸 Image converted to base64, length: \(base64Image.count)")
        
        // Create the prompt with egg database information
        let eggList = eggDatabase.eggs.map { egg in
            "\(egg.name) (\(egg.scientificName)): \(egg.eggColor), size: \(egg.eggSize), habitat: \(egg.habitat)"
        }.joined(separator: "\n")
        
        // Group eggs by color for better analysis
        let _ = eggDatabase.eggs.filter { $0.eggColor.lowercased().contains("blue") }
        let _ = eggDatabase.eggs.filter { 
            $0.eggColor.lowercased().contains("speckled") || 
            $0.eggColor.lowercased().contains("spotted") ||
            $0.eggColor.lowercased().contains("mottled")
        }
        
        let prompt = """
        You are an expert ornithologist. Analyze this egg image and match it to the EXACT bird from our database.
        
        DATABASE (50 species):
        \(eggList)
        
        COMPREHENSIVE IDENTIFICATION GUIDE:
        
        1. PURE WHITE EGGS (NO MARKINGS):
        - Mourning Dove: 2 eggs, pure white, 2.6-3.0 cm
        - Rock Pigeon: 2 eggs, pure white, 3.8-4.0 cm
        - Great Horned Owl: Round white, 5.0-5.5 cm, early nester
        - Ruby-throated Hummingbird: Tiny! 1.2-1.4 cm, like peas
        - Barn Owl: White, elongated, 3.8-4.4 cm
        - Pileated Woodpecker: Glossy white, 3.2-3.5 cm
        - Belted Kingfisher: Pure white, glossy, 3.3-3.5 cm
        - Purple Martin: Pure white, 2.4-2.5 cm, colonial nester
        - Tree Swallow: Pure white, 1.8-1.9 cm
        
        2. WHITE/CREAM WITH SPOTS/SPECKLES:
        - House Sparrow: White with brown spots, 2.0-2.2 cm
        - Northern Cardinal: Grayish white HEAVILY mottled brown/gray, 2.2-2.7 cm
        - European Robin: White/cream with RED spots, 1.9-2.2 cm
        - Great Tit: White with RED spots, small 1.6-1.8 cm
        - Barn Swallow: White with brown spots, 1.7-2.0 cm
        - Black-capped Chickadee: White with fine red-brown dots, tiny 1.5-1.6 cm
        - White-breasted Nuthatch: White with red spots, 1.8-2.0 cm
        - Tufted Titmouse: Cream with brown speckles, 1.7-1.9 cm
        - Brown-headed Cowbird: White HEAVILY spotted brown, 2.0-2.3 cm
        - Common Yellowthroat: White with brown/lilac spots, 1.7-1.9 cm
        
        3. SOLID BLUE/GREEN EGGS:
        - American Robin: Sky blue, NO marks, 2.8-3.0 cm, 3-5 eggs, MATTE
        - European Starling: GLOSSY blue-green, 2.7-3.2 cm, 4-6 eggs
        - Eastern Bluebird: Pale blue, NO marks, 2.1-2.3 cm
        - American Goldfinch: VERY pale blue/white, 1.6-1.8 cm
        - Indigo Bunting: White to pale blue, unmarked, 1.8-2.0 cm
        
        4. BLUE/GREEN WITH MARKINGS:
        - Blue Jay: OLIVE with brown spots, 2.5-3.0 cm
        - Common Blackbird: Blue-green with red-brown speckles, 2.6-3.2 cm
        - House Finch: Bluish white with black/lavender dots, 1.6-2.1 cm
        - Red-winged Blackbird: Pale blue-green with dark SCRAWLS, 2.4-2.6 cm
        - Northern Mockingbird: Blue-green with brown spots, 2.4-2.5 cm
        - Common Grackle: Light blue with dark SCRAWLS, 2.8-3.0 cm
        - Scarlet Tanager: Blue-green with brown marks, 2.3-2.5 cm
        
        5. GREENISH/OLIVE EGGS:
        - Song Sparrow: GREENISH white HEAVILY spotted brown, 1.9-2.5 cm
        - Common Raven: Green with brown marks, large 4.5-5.5 cm
        - Common Loon: OLIVE brown with spots, huge 8.9-9.0 cm
        - Green Heron: Pale green-blue, 3.8-4.0 cm
        
        6. BUFF/TAN/BROWN EGGS:
        - Killdeer: BUFF with HEAVY black spots, 3.5-3.7 cm, ground nest
        - Wild Turkey: Tan with brown spots, 6.0-7.0 cm
        - Canada Goose: Creamy white, huge 8.0-9.0 cm
        - Peregrine Falcon: Cream HEAVILY marked red-brown, 5.0-5.2 cm
        
        7. GRAY-BASED EGGS:
        - Cedar Waxwing: Gray-blue with black/brown spots, 2.2-2.4 cm
        - Yellow Warbler: Gray-white with spots in ring pattern, 1.6-1.8 cm
        - Baltimore Oriole: Pale gray with dark scrawls, 2.2-2.4 cm
        
        8. SPECIAL CASES:
        - Mallard: Pale GREEN to white, 5.0-6.0 cm
        - Wood Duck: GLOSSY cream, 5.0-5.5 cm
        - Great Blue Heron: Pale blue-green, large 6.0-7.0 cm
        - Bald Eagle: Off-white, huge 7.0-8.0 cm
        - Red-tailed Hawk: White with brown marks, 5.8-6.5 cm
        - Osprey: Cream HEAVILY blotched brown, 6.0-6.5 cm
        - Chicken: White to brown, 5.0-6.0 cm
        - Ostrich: Cream, ENORMOUS 15-18 cm!
        
        KEY IDENTIFICATION FEATURES:
        1. ESTIMATE SIZE FIRST! Use context clues:
           - Compare to nest materials (twigs, leaves)
           - Look for scale references
           - Large eggs (>5cm) in ground nests = likely raptors/waterfowl
           - Tiny eggs (<2cm) = small songbirds
        2. COUNT eggs (clutch size is diagnostic)
        3. Note COLOR precisely:
           - Pure white vs off-white vs cream
           - Clean white vs dirty/stained white
        4. Check SURFACE texture:
           - Glossy/shiny vs matte/dull
           - Smooth vs slightly rough
        5. Describe any MARKINGS
        6. NEST CONTEXT is crucial:
           - Ground nest with sticks = large birds (eagles, geese)
           - Tree cavity = woodpeckers, owls
           - Cup nest = songbirds
           - Platform nest = herons, raptors
        
        CRITICAL DISTINCTIONS:
        - Blue eggs + 5-6 count + glossy = European Starling NOT Robin!
        - Heavy mottling on pale base = Northern Cardinal
        - Red/reddish spots = European Robin, Great Tit, or chickadee
        - Scrawls (not spots) = blackbirds, grackles, orioles
        
        WHITE EGG DISTINCTIONS (SIZE IS KEY!):
        - HUGE white eggs (7-8cm) + ground nest = Bald Eagle (off-white, dull)
        - Large white eggs (5-5.5cm) = Great Horned Owl (round)
        - Medium white eggs (3.8-4cm) = Rock Pigeon or Barn Owl
        - Small white eggs (2.6-3cm) + 2 eggs = Mourning Dove (pure white)
        - Tiny white eggs (1.2-1.4cm) = Ruby-throated Hummingbird
        
        CRITICAL: Large eggs on ground ≠ small tree-nesting birds!
        If eggs look bigger than a golf ball in ground nest = raptor/waterfowl!
        
        Response format:
        Bird Name: [exact name from database]
        Confidence: [0-100%]
        """
        
        // Create the API request
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)",
                                "detail": "high"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 150
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ Failed to create JSON request body")
            completion(nil, 0)
            return
        }
        
        print("📤 Creating API request to: \(apiURL)")
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("🚀 Sending request to OpenAI...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, 0)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Response status code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    completion(nil, 0)
                }
                return
            }
            
            print("📦 Received data: \(data.count) bytes")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("📋 Full JSON response: \(String(describing: json))")
                
                if let error = json?["error"] as? [String: Any] {
                    print("❌ API Error: \(error)")
                    DispatchQueue.main.async {
                        completion(nil, 0)
                    }
                    return
                }
                
                if let choices = json?["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    print("✅ AI Response: \(content)")
                    
                    // Parse the response
                    let (birdName, confidence) = self.parseResponse(content)
                    print("🦜 Parsed bird name: \(birdName), confidence: \(confidence)%")
                    
                    // Find the matching egg from database
                    let matchingEgg = eggDatabase.eggs.first { egg in
                        egg.name.lowercased() == birdName.lowercased()
                    }
                    
                    if let egg = matchingEgg {
                        print("✅ Found matching egg: \(egg.name)")
                    } else {
                        print("⚠️ No matching egg found for: \(birdName)")
                    }
                    
                    DispatchQueue.main.async {
                        completion(matchingEgg, confidence)
                    }
                } else {
                    print("❌ Failed to parse response structure")
                    DispatchQueue.main.async {
                        completion(nil, 0)
                    }
                }
            } catch {
                print("❌ Error parsing OpenAI response: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Raw response: \(responseString)")
                }
                DispatchQueue.main.async {
                    completion(nil, 0)
                }
            }
        }.resume()
    }
    
    private func parseResponse(_ response: String) -> (String, Int) {
        var birdName = "Unknown"
        var confidence = 0
        
        let lines = response.components(separatedBy: "\n")
        for line in lines {
            if line.contains("Bird Name:") {
                birdName = line.replacingOccurrences(of: "Bird Name:", with: "").trimmingCharacters(in: .whitespaces)
                
                // Remove scientific name in parentheses if present
                if let openParen = birdName.firstIndex(of: "(") {
                    birdName = String(birdName[..<openParen]).trimmingCharacters(in: .whitespaces)
                }
                
                print("🔍 Cleaned bird name: '\(birdName)'")
            } else if line.contains("Confidence:") {
                let confidenceString = line.replacingOccurrences(of: "Confidence:", with: "").trimmingCharacters(in: .whitespaces)
                confidence = Int(confidenceString.replacingOccurrences(of: "%", with: "")) ?? 0
            }
        }
        
        return (birdName, confidence)
    }
    
    private func loadEggDatabase() -> BirdEggData? {
        guard let url = Bundle.main.url(forResource: "bird_eggs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let eggData = try? JSONDecoder().decode(BirdEggData.self, from: data) else {
            return nil
        }
        return eggData
    }
    
    // Mock identification for testing without API key
    private func mockIdentifyEgg(completion: @escaping (BirdEgg?, Int) -> Void) {
        print("🎭 Mock identification started")
        // Simulate API delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guard let eggDatabase = self.loadEggDatabase() else {
                print("❌ Mock: Failed to load database")
                completion(nil, 0)
                return
            }
            
            // Randomly decide if we can identify the egg (80% success rate)
            let canIdentify = Int.random(in: 1...10) <= 8
            print("🎲 Mock: Can identify = \(canIdentify)")
            
            if canIdentify {
                // Pick a random egg from the database
                if let randomEgg = eggDatabase.eggs.randomElement() {
                    let confidence = Int.random(in: 70...95)
                    print("✅ Mock: Selected \(randomEgg.name) with \(confidence)% confidence")
                    completion(randomEgg, confidence)
                } else {
                    print("❌ Mock: No eggs in database")
                    completion(nil, 0)
                }
            } else {
                // Return unknown
                print("⚠️ Mock: Returning unknown (simulated failure)")
                completion(nil, 0)
            }
        }
    }
}
