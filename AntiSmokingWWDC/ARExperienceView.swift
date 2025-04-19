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
    }
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
                .onAppear {
                    // Request camera permission explicitly
                    AVCaptureDevice.requestAccess(for: .video) { _ in
                        // Permission handling complete
                    }
                }
            
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
            
            // Initialize FileManager
            let fileManager = FileManager.default
            
            // Variable to store model URL
            var modelURL: URL? = nil
            
            // First check for specific asset for each model type
            switch modelName.lowercased() {
            case "brain":
                if let specificAsset = NSDataAsset(name: "Brain") {
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("brain.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        modelURL = tempFileURL
                    } catch {
                        // Failed to extract brain model
                    }
                }
            case "healthylung":
                if let specificAsset = NSDataAsset(name: "HealthyLung") {
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("healthylung.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        modelURL = tempFileURL
                    } catch {
                        // Failed to extract healthy lung model
                    }
                }
            case "smokerlung":
                if let specificAsset = NSDataAsset(name: "SmokerLung") {
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("smokerlung.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        modelURL = tempFileURL
                    } catch {
                        // Failed to extract smoker's lung model
                    }
                }
            case "healthyvsmokerlung":
                if let specificAsset = NSDataAsset(name: "HealthyVSSmokerLung") {
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("healthyvsmokerlung.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        modelURL = tempFileURL
                    } catch {
                        // Failed to extract comparison lung model
                    }
                }
            case "cigarette":
                if let specificAsset = NSDataAsset(name: "Cigarette") {
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("cigarette.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        modelURL = tempFileURL
                    } catch {
                        // Failed to extract cigarette model
                    }
                }
            default:
                // Try to load model with exact name
                if let specificAsset = NSDataAsset(name: modelName) {
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("\(modelName.lowercased()).usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        modelURL = tempFileURL
                    } catch {
                        // Failed to extract model
                    }
                }
            }
            
            // If still no model URL, try direct loading from Bundle
            if modelURL == nil {
                modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz")
            }
            
            // Check if model exists in the 3D Models directory if not found in assets
            if modelURL == nil {
                if let bundlePath = Bundle.main.resourceURL?.appendingPathComponent("3D Models") {
                    let modelFileName = "\(modelName.lowercased()).usdz"
                    let potentialModelURL = bundlePath.appendingPathComponent(modelFileName)
                    if fileManager.fileExists(atPath: potentialModelURL.path) {
                        modelURL = potentialModelURL
                    }
                }
            }
            
            // Check if model exists in base directory
            if modelURL == nil {
                if let bundlePath = Bundle.main.resourceURL {
                    let modelFileName = "\(modelName.lowercased()).usdz"
                    let potentialModelURL = bundlePath.appendingPathComponent(modelFileName)
                    if fileManager.fileExists(atPath: potentialModelURL.path) {
                        modelURL = potentialModelURL
                    }
                }
            }
            
            // Load model if URL was found
            if let modelURL = modelURL {
                do {
                    let modelScene = try SCNScene(url: modelURL, options: nil)
                    
                    // Get the root node of the loaded model
                    if let modelNode = modelScene.rootNode.childNodes.first {
                        // Adjust scale
                        modelNode.scale = SCNVector3(0.003, 0.003, 0.003)
                        
                        // Add the model to the pivot node
                        let pivotNode = SCNNode()
                        pivotNode.addChildNode(modelNode)
                        
                        // Set the pivot node position to the anchor position
                        pivotNode.position = anchorNode.position
                        
                        // Make adjustments based on model type
                        if modelName.lowercased() == "brain" {
                            // Update brain orientation to match the screenshot - stem visible at bottom with left tilt
                            modelNode.eulerAngles = SCNVector3(0, Float.pi * 0.5, Float.pi * 0.15)
                            // Increase scale for better visibility in AR
                            modelNode.scale = SCNVector3(0.005, 0.005, 0.005)
                            // Slightly offset the brain position to look better in AR
                            pivotNode.position.y += 0.05
                        } else if modelName.lowercased().contains("lung") {
                            // Invert lungs (flip upside down)
                            modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
                        }
                        
                        // Add rotation animation with home tab's speed
                        let rotationDuration: TimeInterval = 40 // Match home tab speed
                        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: rotationDuration)
                        let repeatAction = SCNAction.repeatForever(rotationAction)
                        pivotNode.runAction(repeatAction)
                        
                        // Add pivot node to the scene
                        arView.scene.rootNode.addChildNode(pivotNode)
                        
                        // Store reference
                        placedNode = pivotNode
                    }
                } catch {
                    // Error handling for model loading
                }
            }
        }
    }
}
