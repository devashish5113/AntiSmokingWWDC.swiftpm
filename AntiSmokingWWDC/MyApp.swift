import SwiftUI

// Entry Point
@main
struct SmokeFreeApp: App {
    @State private var showOnboarding = true
    
    init() {
        // Ensure 3D models are available in documents directory
        copyModelsToDocumentsDirectory()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showOnboarding) {
                    WelcomeView(isPresented: $showOnboarding)
                }
        }
    }
    
    // Helper function to copy models to a location where they can be accessed
    private func copyModelsToDocumentsDirectory() {
        // These model files should be part of the app bundle
        let modelNames = ["brain", "healthylung", "smokerlung", "healthyvsmokerlung", "cigarette"]
        let fileManager = FileManager.default
        
        // Get documents directory
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // Could not access documents directory
            return
        }
        
        // Create 3D Models directory in the documents directory
        let modelsDirectory = documentsDirectory.appendingPathComponent("3D Models")
        
        // Create the models directory if it doesn't exist
        if !fileManager.fileExists(atPath: modelsDirectory.path) {
            do {
                try fileManager.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
                // Created models directory successfully
            } catch {
                // Failed to create models directory
                return
            }
        }
        
        // Try to find and copy each model
        for modelName in modelNames {
            // Destination path in documents directory
            let destinationURL = modelsDirectory.appendingPathComponent("\(modelName).usdz")
            
            // Skip if file already exists in documents directory
            if fileManager.fileExists(atPath: destinationURL.path) {
                // Model already exists in documents
                continue
            }
            
            // Try to find model in assets (the most reliable way)
            if let modelData = NSDataAsset(name: "Models", bundle: Bundle.main)?.data {
                // First check if we can extract the model from the data asset
                do {
                    try modelData.write(to: destinationURL)
                    // Extracted model from asset catalog to documents directory
                    continue
                } catch {
                    // Failed to extract model from asset
                }
            }
            
            // Fallback to traditional methods
            var foundSourceURL: URL? = nil
            
            // Method 1: Try to load directly from the bundle resource
            if let bundleURL = Bundle.main.url(forResource: modelName, withExtension: "usdz") {
                foundSourceURL = bundleURL
                // Found model in bundle using resource API
            } 
            // Method 2: Check in a subdirectory
            else if let bundleURL = Bundle.main.url(forResource: modelName, withExtension: "usdz", subdirectory: "3D Models") {
                foundSourceURL = bundleURL
                // Found model in 3D Models subdirectory using resource API
            }
            // Method 3: Check if models are in the "AntiSmokingWWDC" subdirectory
            else if let bundleURL = Bundle.main.url(forResource: modelName, withExtension: "usdz", subdirectory: "AntiSmokingWWDC") {
                foundSourceURL = bundleURL
                // Found model in AntiSmokingWWDC subdirectory
            }
            // Method 4: Check in known paths with manual path construction
            else {
                // Try various possible locations
                let possiblePaths = [
                    Bundle.main.bundlePath + "/\(modelName).usdz",
                    Bundle.main.bundlePath + "/3D Models/\(modelName).usdz",
                    Bundle.main.bundlePath + "/AntiSmokingWWDC/\(modelName).usdz",
                    Bundle.main.bundlePath + "/AntiSmokingWWDC/3D Models/\(modelName).usdz",
                    Bundle.main.bundlePath + "/AntiSmokingWWDC.swiftpm/AntiSmokingWWDC/\(modelName).usdz",
                    Bundle.main.bundlePath + "/AntiSmokingWWDC.swiftpm/AntiSmokingWWDC/3D Models/\(modelName).usdz",
                    Bundle.main.bundlePath + "/Assets.car/\(modelName).usdz",
                    Bundle.main.bundlePath + "/Assets.xcassets/Models.dataset/\(modelName).usdz"
                ]
                
                for path in possiblePaths {
                    if fileManager.fileExists(atPath: path) {
                        foundSourceURL = URL(fileURLWithPath: path)
                        // Found model at manual path
                        break
                    }
                }
            }
            
            // If we found the source, copy it to documents directory
            if let sourceURL = foundSourceURL {
                do {
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                    // Copied model to documents directory
                } catch {
                    // Failed to copy model
                }
            }
        }
    }
}
