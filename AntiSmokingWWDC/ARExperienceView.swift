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
import AVFoundation

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
                        .edgesIgnoringSafeArea(.all)
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
                    // Model preview without reset button
                    ARModelPreview(modelName: model.id)
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

// AR-specific model preview without reset button
struct ARModelPreview: View {
    let modelName: String
    
    var body: some View {
        // Scene view with model
        SceneView(
            scene: createARPreviewScene(),
            options: [.autoenablesDefaultLighting, .allowsCameraControl],
            preferredFramesPerSecond: 60
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func createARPreviewScene() -> SCNScene {
        let scene = SCNScene()
        print("🔍 Attempting to load AR preview model: \(modelName)")
        
        // Try to find the model file
        var modelURL: URL?
        let fileManager = FileManager.default
        
        // First check for specific asset for each model type
        switch modelName.lowercased() {
        case "brain":
            if let specificAsset = NSDataAsset(name: "Brain") {
                print("✅ AR Preview: Loading brain model from Brain asset")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("brain.usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ AR Preview: Extracted brain model to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ AR Preview: Failed to extract brain model: \(error)")
                }
            }
        case "healthylung":
            if let specificAsset = NSDataAsset(name: "HealthyLung") {
                print("✅ AR Preview: Loading healthy lung model from asset")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("healthylung.usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ AR Preview: Extracted healthy lung model to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ AR Preview: Failed to extract healthy lung model: \(error)")
                }
            }
        case "smokerlung":
            if let specificAsset = NSDataAsset(name: "SmokerLung") {
                print("✅ AR Preview: Loading smoker's lung model from asset")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("smokerlung.usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ AR Preview: Extracted smoker's lung model to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ AR Preview: Failed to extract smoker's lung model: \(error)")
                }
            }
        case "healthyvsmokerlung":
            if let specificAsset = NSDataAsset(name: "HealthyVSSmokerLung") {
                print("✅ AR Preview: Loading comparison lung model from asset")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("healthyvsmokerlung.usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ AR Preview: Extracted comparison lung model to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ AR Preview: Failed to extract comparison lung model: \(error)")
                }
            }
        case "cigarette":
            if let specificAsset = NSDataAsset(name: "Cigarette") {
                print("✅ AR Preview: Loading cigarette model from asset")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("cigarette.usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ AR Preview: Extracted cigarette model to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ AR Preview: Failed to extract cigarette model: \(error)")
                }
            }
        default:
            // Try to load model with exact name
            if let specificAsset = NSDataAsset(name: modelName) {
                print("✅ AR Preview: Loading model from asset with exact name: \(modelName)")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("\(modelName.lowercased()).usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ AR Preview: Extracted model to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ AR Preview: Failed to extract model: \(error)")
                }
            }
        }
        
        // If still no model URL, try direct loading from Bundle
        if modelURL == nil {
            modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz")
        }
        
        // Check if model exists in the 3D Models directory if not found in assets
        if modelURL == nil {
            if let bundle = Bundle.main.resourceURL?.appendingPathComponent("3D Models") {
                let modelFileName = "\(modelName.lowercased()).usdz"
                let potentialModelURL = bundle.appendingPathComponent(modelFileName)
                if fileManager.fileExists(atPath: potentialModelURL.path) {
                    print("✅ AR Preview: Found model in 3D Models directory: \(potentialModelURL.path)")
                    modelURL = potentialModelURL
                } else {
                    print("❌ AR Preview: Could not find model in 3D Models directory: \(potentialModelURL.path)")
                }
            }
        }
        
        // Check if model exists in base directory
        if modelURL == nil {
            if let bundle = Bundle.main.resourceURL {
                let modelFileName = "\(modelName.lowercased()).usdz"
                let potentialModelURL = bundle.appendingPathComponent(modelFileName)
                if fileManager.fileExists(atPath: potentialModelURL.path) {
                    print("✅ AR Preview: Found model in base directory: \(potentialModelURL.path)")
                    modelURL = potentialModelURL
                } else {
                    print("❌ AR Preview: Could not find model in base directory: \(potentialModelURL.path)")
                }
            }
        }
        
        // Load the model if found
        if let modelURL = modelURL {
            do {
                print("✅ Loading model from URL: \(modelURL.path)")
                let modelScene = try SCNScene(url: modelURL, options: nil)
                print("✅ Successfully created SCNScene from URL")
                
                if let modelNode = modelScene.rootNode.childNodes.first {
                    // Create a pivot node for centered rotation
                    let pivotNode = SCNNode()
                    scene.rootNode.addChildNode(pivotNode)
                    
                    // Scale model appropriately
                    let scale: Float = 0.12
                    modelNode.scale = SCNVector3(scale, scale, scale)
                    
                    // Position model at center
                    modelNode.position = SCNVector3(0, 0, 0)
                    pivotNode.position = SCNVector3(0, 0, -1.2)
                    
                    // Set proper initial orientation based on model type
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
                    
                    // Add model to pivot node
                    pivotNode.addChildNode(modelNode)
                    print("✅ Successfully loaded model: \(modelName)")
                    
                    // Successfully loaded the model - return without creating fallback
                    return scene
                } else {
                    print("❌ No child nodes found in model: \(modelName)")
                }
            } catch {
                print("❌ Error loading model: \(error.localizedDescription)")
            }
        } else {
            print("❌ Could not find model URL for: \(modelName)")
        }
        
        // If we get here, create a procedural model instead of using fallback shapes
        print("⚠️ Creating procedural model for: \(modelName)")
        createProceduralModel(for: modelName, in: scene)
        
        // Add lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 1000
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 1400
        directionalLight.position = SCNVector3(x: 5, y: 5, z: 5)
        scene.rootNode.addChildNode(directionalLight)
        
        let backLight = SCNNode()
        backLight.light = SCNLight()
        backLight.light?.type = .directional
        backLight.light?.intensity = 1200
        backLight.position = SCNVector3(x: -5, y: 0, z: -5)
        scene.rootNode.addChildNode(backLight)
        
        return scene
    }
    
    private func createProceduralModel(for modelName: String, in scene: SCNScene) {
        let modelNode = SCNNode()
        let pivotNode = SCNNode()
        scene.rootNode.addChildNode(pivotNode)
        pivotNode.position = SCNVector3(0, 0, -1.2)
        
        switch modelName {
        case "brain":
            // Create brain-like geometry
            let brainSphere = SCNSphere(radius: 0.5)
            brainSphere.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0.6, blue: 0.6, alpha: 1.0)
            brainSphere.firstMaterial?.specular.contents = UIColor.white
            brainSphere.firstMaterial?.roughness.contents = 0.2
            
            let brainNode = SCNNode(geometry: brainSphere)
            modelNode.addChildNode(brainNode)
            
            // Add stem
            let stemCylinder = SCNCylinder(radius: 0.1, height: 0.3)
            stemCylinder.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0.6, blue: 0.6, alpha: 1.0)
            
            let stemNode = SCNNode(geometry: stemCylinder)
            stemNode.position = SCNVector3(0, -0.6, 0)
            stemNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
            modelNode.addChildNode(stemNode)
            
            // Position and rotate the brain - exactly like in homeView
            modelNode.eulerAngles = SCNVector3(0, Float.pi * 0.5, Float.pi * 0.15)
            modelNode.position = SCNVector3(0, 0, 0)
            // Move the pivot closer to camera and scale the brain model
            pivotNode.position = SCNVector3(0, 0, -1.0)
            modelNode.scale = SCNVector3(1.2, 1.2, 1.2)
            
        case "healthylung":
            // Create a pair of lungs
            createLungModel(in: modelNode, isHealthy: true)
            
        case "smokerlung":
            // Create a smoker's lungs
            createLungModel(in: modelNode, isHealthy: false)
            
        case "healthyvsmokerlung":
            // Create healthy lung 
            let healthyLung = SCNCapsule(capRadius: 0.25, height: 0.7)
            healthyLung.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.6, blue: 0.6, alpha: 1.0)
            let healthyLungNode = SCNNode(geometry: healthyLung)
            healthyLungNode.position = SCNVector3(0.5, 0, 0)
            modelNode.addChildNode(healthyLungNode)
            
            // Create smoker's lung
            let smokerLung = SCNCapsule(capRadius: 0.25, height: 0.7)
            smokerLung.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            let smokerLungNode = SCNNode(geometry: smokerLung)
            smokerLungNode.position = SCNVector3(-0.5, 0, 0)
            modelNode.addChildNode(smokerLungNode)
            
            // Set the lungs orientation
            modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
            
        case "cigarette":
            // Create cigarette model
            let filter = SCNCylinder(radius: 0.04, height: 0.2)
            filter.firstMaterial?.diffuse.contents = UIColor(white: 0.9, alpha: 1.0)
            let filterNode = SCNNode(geometry: filter)
            filterNode.position = SCNVector3(0, -0.3, 0)
            modelNode.addChildNode(filterNode)
            
            let tobacco = SCNCylinder(radius: 0.04, height: 0.4)
            tobacco.firstMaterial?.diffuse.contents = UIColor(white: 0.8, alpha: 1.0)
            let tobaccoNode = SCNNode(geometry: tobacco)
            tobaccoNode.position = SCNVector3(0, 0, 0)
            modelNode.addChildNode(tobaccoNode)
            
            let ash = SCNCone(topRadius: 0.01, bottomRadius: 0.04, height: 0.1)
            ash.firstMaterial?.diffuse.contents = UIColor.darkGray
            let ashNode = SCNNode(geometry: ash)
            ashNode.position = SCNVector3(0, 0.25, 0)
            modelNode.addChildNode(ashNode)
            
        default:
            // Create a default cube
            let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
            box.firstMaterial?.diffuse.contents = UIColor.blue
            let boxNode = SCNNode(geometry: box)
            modelNode.addChildNode(boxNode)
        }
        
        // Add rotation animation with home tab's speed
        let rotationDuration: TimeInterval = 40 // Match home tab speed
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: rotationDuration)
        let repeatAction = SCNAction.repeatForever(rotationAction)
        pivotNode.runAction(repeatAction)
        
        // Add model to pivot node
        pivotNode.addChildNode(modelNode)
    }
    
    private func createLungModel(in parentNode: SCNNode, isHealthy: Bool) {
        let color = isHealthy ? 
            UIColor(red: 0.9, green: 0.6, blue: 0.6, alpha: 1.0) : 
            UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        
        // Right lung
        let rightLung = SCNCapsule(capRadius: 0.25, height: 0.7)
        rightLung.firstMaterial?.diffuse.contents = color
        let rightLungNode = SCNNode(geometry: rightLung)
        rightLungNode.position = SCNVector3(0.3, 0, 0)
        rightLungNode.eulerAngles = SCNVector3(0, 0, Float.pi/8)
        parentNode.addChildNode(rightLungNode)
        
        // Left lung
        let leftLung = SCNCapsule(capRadius: 0.25, height: 0.7)
        leftLung.firstMaterial?.diffuse.contents = color
        let leftLungNode = SCNNode(geometry: leftLung)
        leftLungNode.position = SCNVector3(-0.3, 0, 0)
        leftLungNode.eulerAngles = SCNVector3(0, 0, -Float.pi/8)
        parentNode.addChildNode(leftLungNode)
        
        // Add trachea
        let trachea = SCNCylinder(radius: 0.08, height: 0.4)
        trachea.firstMaterial?.diffuse.contents = UIColor.white
        let tracheaNode = SCNNode(geometry: trachea)
        tracheaNode.position = SCNVector3(0, 0.55, 0)
        parentNode.addChildNode(tracheaNode)
        
        // Set the lungs orientation
        parentNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
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
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            print("Camera access granted")
                        } else {
                            print("Camera access denied")
                        }
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
        
        // Reset tracking and run session
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        // Show debug information
        #if DEBUG
        arView.debugOptions = [.showFeaturePoints]
        #endif
        
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
            var modelURL: URL?
            
            // First check for specific asset for each model type
            switch modelName.lowercased() {
            case "brain":
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
            case "healthylung":
                if let specificAsset = NSDataAsset(name: "HealthyLung") {
                    print("✅ AR: Loading healthy lung model from asset")
                    
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("healthylung.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        print("✅ AR: Extracted healthy lung model to temp file: \(tempFileURL.path)")
                        modelURL = tempFileURL
                    } catch {
                        print("❌ AR: Failed to extract healthy lung model: \(error)")
                    }
                }
            case "smokerlung":
                if let specificAsset = NSDataAsset(name: "SmokerLung") {
                    print("✅ AR: Loading smoker's lung model from asset")
                    
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("smokerlung.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        print("✅ AR: Extracted smoker's lung model to temp file: \(tempFileURL.path)")
                        modelURL = tempFileURL
                    } catch {
                        print("❌ AR: Failed to extract smoker's lung model: \(error)")
                    }
                }
            case "healthyvsmokerlung":
                if let specificAsset = NSDataAsset(name: "HealthyVSSmokerLung") {
                    print("✅ AR: Loading comparison lung model from asset")
                    
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("healthyvsmokerlung.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        print("✅ AR: Extracted comparison lung model to temp file: \(tempFileURL.path)")
                        modelURL = tempFileURL
                    } catch {
                        print("❌ AR: Failed to extract comparison lung model: \(error)")
                    }
                }
            case "cigarette":
                if let specificAsset = NSDataAsset(name: "Cigarette") {
                    print("✅ AR: Loading cigarette model from asset")
                    
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("cigarette.usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        print("✅ AR: Extracted cigarette model to temp file: \(tempFileURL.path)")
                        modelURL = tempFileURL
                    } catch {
                        print("❌ AR: Failed to extract cigarette model: \(error)")
                    }
                }
            default:
                // Try to load model with exact name
                if let specificAsset = NSDataAsset(name: modelName) {
                    print("✅ AR: Loading model from asset with exact name: \(modelName)")
                    
                    // Create a temporary file
                    let tempDir = NSTemporaryDirectory()
                    let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("\(modelName.lowercased()).usdz")
                    
                    do {
                        try specificAsset.data.write(to: tempFileURL)
                        print("✅ AR: Extracted model to temp file: \(tempFileURL.path)")
                        modelURL = tempFileURL
                    } catch {
                        print("❌ AR: Failed to extract model: \(error)")
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
                        print("✅ AR: Found model in 3D Models directory: \(potentialModelURL.path)")
                        modelURL = potentialModelURL
                    } else {
                        print("❌ AR: Could not find model in 3D Models directory: \(potentialModelURL.path)")
                    }
                }
            }
            
            // Check if model exists in base directory
            if modelURL == nil {
                if let bundlePath = Bundle.main.resourceURL {
                    let modelFileName = "\(modelName.lowercased()).usdz"
                    let potentialModelURL = bundlePath.appendingPathComponent(modelFileName)
                    if fileManager.fileExists(atPath: potentialModelURL.path) {
                        print("✅ AR: Found model in base directory: \(potentialModelURL.path)")
                        modelURL = potentialModelURL
                    } else {
                        print("❌ AR: Could not find model in base directory: \(potentialModelURL.path)")
                    }
                }
            }
            
            if let modelURL = modelURL {
                do {
                    let modelScene = try SCNScene(url: modelURL, options: nil)
                    
                    // Get the root node of the loaded model
                    if let modelNode = modelScene.rootNode.childNodes.first {
                        // Create a pivot node for better control
                        let pivotNode = SCNNode()
                        
                        // Adjust scale
                        modelNode.scale = SCNVector3(0.003, 0.003, 0.003)
                        
                        // Add the model to the pivot node
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
                    print("Error loading model: \(error.localizedDescription)")
                }
            }
        }
    }
}
