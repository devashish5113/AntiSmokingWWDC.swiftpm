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
            print("Could not access documents directory")
            return
        }
        
        // Create 3D Models directory in the documents directory
        let modelsDirectory = documentsDirectory.appendingPathComponent("3D Models")
        
        // Create the models directory if it doesn't exist
        if !fileManager.fileExists(atPath: modelsDirectory.path) {
            do {
                try fileManager.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
                print("✅ Created models directory at: \(modelsDirectory.path)")
            } catch {
                print("❌ Failed to create models directory: \(error)")
                return
            }
        }
        
        // Debug info
        print("📦 App bundle path: \(Bundle.main.bundlePath)")
        print("📂 Documents directory: \(documentsDirectory.path)")
        
        // Try to find and copy each model
        for modelName in modelNames {
            // Destination path in documents directory
            let destinationURL = modelsDirectory.appendingPathComponent("\(modelName).usdz")
            
            // Skip if file already exists in documents directory
            if fileManager.fileExists(atPath: destinationURL.path) {
                print("✅ Model \(modelName) already exists in documents")
                continue
            }
            
            // Try to find model in assets (the most reliable way)
            if let modelData = NSDataAsset(name: "Models", bundle: Bundle.main)?.data {
                // First check if we can extract the model from the data asset
                do {
                    try modelData.write(to: destinationURL)
                    print("✅ Extracted model \(modelName) from asset catalog to documents directory")
                    continue
                } catch {
                    print("❌ Failed to extract model \(modelName) from asset: \(error)")
                }
            }
            
            // Fallback to traditional methods
            var foundSourceURL: URL? = nil
            
            // Method 1: Try to load directly from the bundle resource
            if let bundleURL = Bundle.main.url(forResource: modelName, withExtension: "usdz") {
                foundSourceURL = bundleURL
                print("✅ Found model \(modelName) in bundle using resource API")
            } 
            // Method 2: Check in a subdirectory
            else if let bundleURL = Bundle.main.url(forResource: modelName, withExtension: "usdz", subdirectory: "3D Models") {
                foundSourceURL = bundleURL
                print("✅ Found model \(modelName) in 3D Models subdirectory using resource API")
            }
            // Method 3: Check if models are in the "AntiSmokingWWDC" subdirectory
            else if let bundleURL = Bundle.main.url(forResource: modelName, withExtension: "usdz", subdirectory: "AntiSmokingWWDC") {
                foundSourceURL = bundleURL
                print("✅ Found model \(modelName) in AntiSmokingWWDC subdirectory")
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
                        print("✅ Found model \(modelName) at manual path: \(path)")
                        break
                    }
                }
            }
            
            // If we found the source, copy it to documents directory
            if let sourceURL = foundSourceURL {
                do {
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                    print("✅ Copied model \(modelName) to documents directory")
                } catch {
                    print("❌ Failed to copy model \(modelName): \(error)")
                }
            } else {
                print("❌ Could not find model \(modelName) in app bundle")
                
                // Try an alternative approach - look inside the asset catalog binary
                if let assetURL = Bundle.main.url(forResource: "Assets", withExtension: "car") {
                    print("📦 Found Assets.car at: \(assetURL.path)")
                    // Unfortunately we can't easily extract files from compiled asset catalogs at runtime
                }
            }
        }
        
        // Verify models are in documents directory
        print("📄 Verification of models in documents directory:")
        if let contents = try? fileManager.contentsOfDirectory(atPath: modelsDirectory.path) {
            if contents.isEmpty {
                print("  No models found in documents directory")
            } else {
                for item in contents {
                    print("  - \(item)")
                }
            }
        } else {
            print("  Could not list models directory contents")
        }
    }
}
