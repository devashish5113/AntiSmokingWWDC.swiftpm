//
//  File.swift
//  AntiSmokingWWDC
//
//  Created by Batch - 1 on 05/02/25.
//

import SwiftUI
import SceneKit
import ARKit
import RealityKit

struct ARExperienceView: View {
    @State private var selectedModel: String? = nil
    @State private var showARView = false
    
    // Model information
    let arModels = [
        ARModelInfo(id: "brain", name: "Brain", description: "View the brain in AR to understand impact of smoking on neural pathways", icon: "brain"),
        ARModelInfo(id: "healthylung", name: "Healthy Lung", description: "Explore a healthy lung in augmented reality", icon: "lungs"),
        ARModelInfo(id: "smokerlung", name: "Smoker's Lung", description: "See how smoking damages lung tissue", icon: "lungs.fill"),
        ARModelInfo(id: "healthyvsmokerlung", name: "Comparison", description: "Compare healthy and smoker's lungs side by side", icon: "arrow.left.arrow.right"),
        ARModelInfo(id: "cigarette", name: "Cigarette", description: "Examine a cigarette and its harmful components", icon: "flame")
    ]
    
    // Grid layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("View in Your Space")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    Text("Select a 3D model to view in augmented reality")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(arModels) { model in
                            ARModelCard(model: model) {
                                selectedModel = model.id
                                showARView = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("AR Guide")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ARInstructionCard(
                        title: "How to use AR",
                        instructions: [
                            "Point your camera at a flat surface",
                            "Move slowly to detect surfaces",
                            "Tap to place the 3D model",
                            "Pinch to resize the model",
                            "Drag to rotate or reposition"
                        ]
                    )
                    .padding(.horizontal)
                }
            }
            .healthStyleNavigation(title: "AR Experience")
            .fullScreenCover(isPresented: $showARView) {
                if let modelID = selectedModel {
                    ARModelViewerContainer(modelName: modelID)
                }
            }
        }
    }
}

// Model information structure
struct ARModelInfo: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
}

// Individual AR model card
struct ARModelCard: View {
    let model: ARModelInfo
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    // Model preview
                    EnhancedModelPreview(modelName: model.id, cardColor: .blue)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // AR badge
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        
                        Image(systemName: "arkit")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                    .padding(8)
                }
                
                Text(model.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(model.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // debugModelPaths call removed
        }
    }
    
    // Helper function to debug model loading has been removed
}

// AR instructions card
struct ARInstructionCard: View {
    let title: String
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(instructions.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 24, height: 24)
                            
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        Text(instructions[index])
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// AR Viewer container
struct ARModelViewerContainer: View {
    let modelName: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            SceneKitARModelViewer(modelName: modelName)
                .edgesIgnoringSafeArea(.all)
            
            // Close button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 0)
                    .padding(20)
            }
        }
    }
}

// AR view using ARKit and SceneKit (more stable approach)
struct SceneKitARModelViewer: UIViewRepresentable {
    let modelName: String
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        // Set up scene
        let scene = SCNScene()
        arView.scene = scene
        
        // Set the delegate
        arView.delegate = context.coordinator
        
        // Setup tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        context.coordinator.arView = arView
        context.coordinator.modelName = modelName
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    @MainActor
    class Coordinator: NSObject, ARSCNViewDelegate {
        var arView: ARSCNView?
        var modelName: String?
        var placedNode: SCNNode?
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            Task { @MainActor in
                guard let arView = arView, placedNode == nil else { return }
                
                // Get tap location
                let location = gesture.location(in: arView)
                
                // Use modern API instead of deprecated hitTest
                if #available(iOS 14.0, *) {
                    guard let query = arView.raycastQuery(from: location, allowing: .existingPlaneInfinite, alignment: .horizontal) else {
                        return
                    }
                    
                    let results = arView.session.raycast(query)
                    guard let hitResult = results.first else { return }
                    
                    // Create anchor node
                    let anchorNode = SCNNode()
                    
                    // Get position from hit test
                    let hitTransform = hitResult.worldTransform
                    let hitPosition = SCNVector3(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
                    anchorNode.position = hitPosition
                    
                    placeModel(at: anchorNode)
                } else {
                    // Fallback for iOS 13 - using deprecated API
                    let hitTestResults = arView.hitTest(location, types: .existingPlaneUsingExtent)
                    
                    if let hitResult = hitTestResults.first {
                        // Create anchor node
                        let anchorNode = SCNNode()
                        
                        // Get position from hit test
                        let hitTransform = hitResult.worldTransform
                        let hitPosition = SCNVector3(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
                        anchorNode.position = hitPosition
                        
                        placeModel(at: anchorNode)
                    }
                }
            }
        }
        
        @MainActor
        private func placeModel(at anchorNode: SCNNode) {
            guard let arView = arView, let modelName = modelName else { return }
            
            // Try loading model from file
            let loadedModel = loadModelFromFile(modelName: modelName, anchorNode: anchorNode)
            
            // If file loading failed, create a procedural model
            if !loadedModel {
                print("AR: Creating procedural model for \(modelName)")
                createProceduralModel(modelName: modelName, anchorNode: anchorNode)
            }
        }
        
        @MainActor
        private func createProceduralModel(modelName: String, anchorNode: SCNNode) {
            guard let arView = arView else { return }
            
            let modelNode = SCNNode()
            
            switch modelName {
            case "brain":
                // Create brain-like geometry
                let brainSphere = SCNSphere(radius: 0.05)
                brainSphere.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.8)
                brainSphere.firstMaterial?.specular.contents = UIColor.white
                
                // Add wrinkle-like texture
                let material = brainSphere.firstMaterial!
                material.diffuse.contents = UIColor(red: 0.8, green: 0.6, blue: 0.6, alpha: 1.0)
                material.normal.contents = UIImage(named: "brain_normal") ?? UIColor.red
                material.roughness.contents = 0.2
                
                let brainNode = SCNNode(geometry: brainSphere)
                modelNode.addChildNode(brainNode)
                
                // Add stem
                let stemCylinder = SCNCylinder(radius: 0.01, height: 0.03)
                stemCylinder.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0.6, blue: 0.6, alpha: 1.0)
                
                let stemNode = SCNNode(geometry: stemCylinder)
                stemNode.position = SCNVector3(0, -0.06, 0)
                stemNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
                modelNode.addChildNode(stemNode)
                
            case "healthylung":
                // Create healthy lung model
                let rightLung = SCNCapsule(capRadius: 0.025, height: 0.07)
                rightLung.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.6, blue: 0.6, alpha: 1.0)
                let rightLungNode = SCNNode(geometry: rightLung)
                rightLungNode.position = SCNVector3(0.03, 0, 0)
                rightLungNode.eulerAngles = SCNVector3(0, 0, Float.pi/8)
                modelNode.addChildNode(rightLungNode)
                
                let leftLung = SCNCapsule(capRadius: 0.025, height: 0.07)
                leftLung.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.6, blue: 0.6, alpha: 1.0)
                let leftLungNode = SCNNode(geometry: leftLung)
                leftLungNode.position = SCNVector3(-0.03, 0, 0)
                leftLungNode.eulerAngles = SCNVector3(0, 0, -Float.pi/8)
                modelNode.addChildNode(leftLungNode)
                
                // Add trachea
                let trachea = SCNCylinder(radius: 0.008, height: 0.04)
                trachea.firstMaterial?.diffuse.contents = UIColor.white
                let tracheaNode = SCNNode(geometry: trachea)
                tracheaNode.position = SCNVector3(0, 0.055, 0)
                modelNode.addChildNode(tracheaNode)
                
            case "smokerlung":
                // Create smoker's lung model (darker color, rougher texture)
                let rightLung = SCNCapsule(capRadius: 0.025, height: 0.07)
                rightLung.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                let rightLungNode = SCNNode(geometry: rightLung)
                rightLungNode.position = SCNVector3(0.03, 0, 0)
                rightLungNode.eulerAngles = SCNVector3(0, 0, Float.pi/8)
                modelNode.addChildNode(rightLungNode)
                
                let leftLung = SCNCapsule(capRadius: 0.025, height: 0.07)
                leftLung.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                let leftLungNode = SCNNode(geometry: leftLung)
                leftLungNode.position = SCNVector3(-0.03, 0, 0)
                leftLungNode.eulerAngles = SCNVector3(0, 0, -Float.pi/8)
                modelNode.addChildNode(leftLungNode)
                
                // Add trachea
                let trachea = SCNCylinder(radius: 0.008, height: 0.04)
                trachea.firstMaterial?.diffuse.contents = UIColor.white
                let tracheaNode = SCNNode(geometry: trachea)
                tracheaNode.position = SCNVector3(0, 0.055, 0)
                modelNode.addChildNode(tracheaNode)
                
            case "healthyvsmokerlung":
                // Create healthy lung 
                let healthyLung = SCNCapsule(capRadius: 0.025, height: 0.07)
                healthyLung.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.6, blue: 0.6, alpha: 1.0)
                let healthyLungNode = SCNNode(geometry: healthyLung)
                healthyLungNode.position = SCNVector3(0.05, 0, 0)
                modelNode.addChildNode(healthyLungNode)
                
                // Create smoker's lung
                let smokerLung = SCNCapsule(capRadius: 0.025, height: 0.07)
                smokerLung.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                let smokerLungNode = SCNNode(geometry: smokerLung)
                smokerLungNode.position = SCNVector3(-0.05, 0, 0)
                modelNode.addChildNode(smokerLungNode)
                
            case "cigarette":
                // Create cigarette model
                let filter = SCNCylinder(radius: 0.004, height: 0.02)
                filter.firstMaterial?.diffuse.contents = UIColor(white: 0.9, alpha: 1.0)
                let filterNode = SCNNode(geometry: filter)
                filterNode.position = SCNVector3(0, -0.03, 0)
                modelNode.addChildNode(filterNode)
                
                let tobacco = SCNCylinder(radius: 0.004, height: 0.04)
                tobacco.firstMaterial?.diffuse.contents = UIColor(white: 0.8, alpha: 1.0)
                let tobaccoNode = SCNNode(geometry: tobacco)
                tobaccoNode.position = SCNVector3(0, 0, 0)
                modelNode.addChildNode(tobaccoNode)
                
                let ash = SCNCone(topRadius: 0.001, bottomRadius: 0.004, height: 0.01)
                ash.firstMaterial?.diffuse.contents = UIColor.darkGray
                let ashNode = SCNNode(geometry: ash)
                ashNode.position = SCNVector3(0, 0.025, 0)
                modelNode.addChildNode(ashNode)
                
            default:
                // Create a default cube
                let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.005)
                box.firstMaterial?.diffuse.contents = UIColor.orange
                let boxNode = SCNNode(geometry: box)
                modelNode.addChildNode(boxNode)
            }
            
            // Add the model to the anchor node
            anchorNode.addChildNode(modelNode)
            
            // Add the anchor to the scene
            arView.scene.rootNode.addChildNode(anchorNode)
            
            // Store reference
            placedNode = modelNode
            
            print("AR: Successfully created procedural model for: \(modelName)")
        }
        
        @MainActor
        private func loadModelFromFile(modelName: String, anchorNode: SCNNode) -> Bool {
            guard let arView = arView else { return false }
            
            // Try to find the model file
            var modelURL: URL?
            let fileManager = FileManager.default
            
            // First try specific asset for this model - use brain-specific handling for brain model
            if modelName.lowercased() == "brain" {
                if let specificAsset = NSDataAsset(name: "Brain") {
                    print("✅ AR: Loading brain model from Brain asset")
                    
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("brain.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        print("✅ AR: Extracted brain model to temp file: \(tempFileURL.path)")
                        modelURL = tempFileURL
                    } catch {
                        print("❌ AR: Failed to extract brain model: \(error)")
                    }
                }
            } else {
                // For other models, use the exact asset name
                let assetName = modelName
                if let specificAsset = NSDataAsset(name: assetName) {
                    print("✅ AR: Loading specific asset for \(modelName): \(assetName)")
                    
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("\(modelName).usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        print("✅ AR: Extracted model from specific asset to temp file: \(tempFileURL.path)")
                        modelURL = tempFileURL
                    } catch {
                        print("❌ AR: Failed to extract model from specific asset: \(error)")
                    }
                } else {
                    print("❌ AR: Could not find NSDataAsset named: \(assetName) for model: \(modelName)")
                }
            }
            
            // Check if model exists in the 3D Models directory if not found in assets
            if modelURL == nil, let bundle = Bundle.main.resourceURL?.appendingPathComponent("3D Models") {
                let modelFileName = modelName.lowercased() == "brain" ? "brain.usdz" : "\(modelName.lowercased()).usdz"
                let potentialModelURL = bundle.appendingPathComponent(modelFileName)
                if fileManager.fileExists(atPath: potentialModelURL.path) {
                    print("✅ AR: Found model in 3D Models directory: \(potentialModelURL.path)")
                    modelURL = potentialModelURL
                } else {
                    print("❌ AR: Could not find model in 3D Models directory: \(potentialModelURL.path)")
                }
            }
            
            // Check if model exists in base directory
            if modelURL == nil, let bundle = Bundle.main.resourceURL {
                let modelFileName = modelName.lowercased() == "brain" ? "brain.usdz" : "\(modelName.lowercased()).usdz"
                let potentialModelURL = bundle.appendingPathComponent(modelFileName)
                if fileManager.fileExists(atPath: potentialModelURL.path) {
                    print("✅ AR: Found model in base directory: \(potentialModelURL.path)")
                    modelURL = potentialModelURL
                } else {
                    print("❌ AR: Could not find model in base directory: \(potentialModelURL.path)")
                }
            }
            
            // Load model if URL was found
            if let modelURL = modelURL {
                do {
                    print("✅ AR: Loading model from URL: \(modelURL.path)")
                    let modelScene = try SCNScene(url: modelURL, options: nil)
                    print("✅ AR: Successfully created SCNScene from URL")
                    
                    // Get the root node of the loaded model
                    let childNodes = modelScene.rootNode.childNodes
                    print("AR: Model has \(childNodes.count) child nodes")
                    
                    if let modelNode = childNodes.first {
                        // Adjust scale
                        modelNode.scale = SCNVector3(0.003, 0.003, 0.003)
                        
                        // Add to anchor
                        anchorNode.addChildNode(modelNode)
                        
                        // Add anchor to scene
                        arView.scene.rootNode.addChildNode(anchorNode)
                        
                        // Store reference
                        placedNode = modelNode
                        print("✅ AR: Successfully loaded and placed model: \(modelName)")
                        return true
                    } else {
                        print("❌ AR: No child nodes found in model: \(modelName)")
                        return false
                    }
                } catch {
                    print("❌ AR: Error loading model: \(error.localizedDescription)")
                    return false
                }
            } else {
                print("❌ AR: Could not find model URL for: \(modelName)")
                return false
            }
        }
    }
}

