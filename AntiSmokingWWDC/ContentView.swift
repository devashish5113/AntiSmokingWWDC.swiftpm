import SwiftUI
import SceneKit
import UIKit

struct WelcomeView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Display the 3D cigarette model
            CigaretteView()
                .frame(maxHeight: UIScreen.main.bounds.height * 0.65)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.top, 10)
            
            Spacer().frame(height: 5)
                
                Text("What happens when you smoke?")
                .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                .padding(.bottom, 20)
                
            Button(action: {
                isPresented = false
            }) {
                    Text("Try")
                    .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            .padding(.bottom, 20)
            
            Spacer(minLength: 0)
        }
        .padding([.leading, .trailing])
    }
}

struct CigaretteView: View {
    // Scene setup with basic cigarette shape
    @State private var scene = SCNScene()
    @State private var rotationY: Float = 0
    @State private var rotationX: Float = -Float.pi/20  // Adjusted initial tilt angle for better view
    @State private var scale: Float = 1.2 // Increased initial scale
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 3D Scene View
            SceneView(scene: scene, options: [.autoenablesDefaultLighting])
                .onAppear {
                    setupScene()
                }
                // Combined gestures with simultaneousGesture
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update rotation with reduced speed for smoother movement
                            let deltaX = Float(value.translation.height) * 0.0005  // Reduced from 0.001
                            let deltaY = Float(value.translation.width) * 0.0005   // Reduced from 0.001
                            
                            // Limit X rotation to prevent the model from being hidden
                            rotationX = min(max(rotationX + deltaX, -Float.pi/3), Float.pi/3)
                            rotationY += deltaY
                            
                            // Apply rotation to both axes
                            updateModelTransform()
                        }
                )
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            // Calculate new scale with limits
                            let delta = Float(value) - 1.0
                            let newScale = scale + delta * 0.2 // Slower scaling speed (reduced from 0.3)
                            
                            // Expand zoom limits for larger frame (0.8 to 2.5)
                            scale = min(max(newScale, 0.8), 2.5)
                            
                            // Apply new scale
                            updateModelTransform()
                        }
                )
            
            // Subtle reset button in top-right corner, positioned for larger frame
            Button(action: {
                resetView()
            }) {
                Image(systemName: "arrow.counterclockwise.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
            .accessibility(label: Text("Reset View"))
            .padding(.trailing, 10)
            .padding(.top, 10)
        }
    }
    
    // Reset function to restore original view
    private func resetView() {
        // Reset values
        rotationX = -Float.pi/20  // Updated to match new initial tilt
        rotationY = 0
        scale = 1.2  // Updated to match new initial scale
        
        // Apply reset with animation
        if let pivotNode = scene.rootNode.childNode(withName: "cigarette-pivot", recursively: false),
           let containerNode = pivotNode.childNode(withName: "cigarette-container", recursively: false) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            containerNode.eulerAngles = SCNVector3(rotationX, rotationY, 0)
            pivotNode.scale = SCNVector3(scale, scale, scale)
            SCNTransaction.commit()
        }
    }
    
    // Update model transform (rotation and scale)
    private func updateModelTransform() {
        if let pivotNode = scene.rootNode.childNode(withName: "cigarette-pivot", recursively: false) {
            // Update scale
            pivotNode.scale = SCNVector3(scale, scale, scale)
            
            // Update rotation
            if let containerNode = pivotNode.childNode(withName: "cigarette-container", recursively: false) {
                containerNode.eulerAngles = SCNVector3(rotationX, rotationY, 0)
            }
        }
    }
    
    // Setup scene with lighting and model
    func setupScene() {
        // Create a new scene
        let newScene = SCNScene()
        
        // Add lighting
        addLighting(to: newScene)
        
        // Try to load the 3D model or use fallback
        loadCigaretteModel(to: newScene)
        
        // Update the scene
        scene = newScene
    }
    
    // Add proper lighting to the scene
    func addLighting(to scene: SCNScene) {
        // Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 500
        scene.rootNode.addChildNode(ambientLight)
        
        // Main directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 1000
        directionalLight.position = SCNVector3(x: 5, y: 5, z: 5)
        scene.rootNode.addChildNode(directionalLight)
        
        // Back light
        let backLight = SCNNode()
        backLight.light = SCNLight()
        backLight.light?.type = .directional
        backLight.light?.intensity = 800
        backLight.position = SCNVector3(x: -5, y: 0, z: -5)
        scene.rootNode.addChildNode(backLight)
    }
    
    // Try loading the cigarette model with multiple approaches
    func loadCigaretteModel(to scene: SCNScene) {
        // For diagnostic purposes
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        // Try a few different approaches to load the model
        var modelLoaded = false
        
        // Approach 1: Try with resource name and subdirectory parameter
        if let modelURL = Bundle.main.url(forResource: "cigarette", withExtension: "usdz", subdirectory: "AntiSmokingWWDC/3D Models") {
            print("Found model at: \(modelURL)")
            modelLoaded = loadModel(from: modelURL, into: scene, approach: "1")
        }
        
        // Approach 2: Try with plain resource name
        if !modelLoaded, let modelURL = Bundle.main.url(forResource: "cigarette", withExtension: "usdz") {
            print("Found model with plain name at: \(modelURL)")
            modelLoaded = loadModel(from: modelURL, into: scene, approach: "2")
        }
        
        // Approach 3: Try with subdirectory "3D Models"
        if !modelLoaded, let modelURL = Bundle.main.url(forResource: "cigarette", withExtension: "usdz", subdirectory: "3D Models") {
            print("Found model in 3D Models directory: \(modelURL)")
            modelLoaded = loadModel(from: modelURL, into: scene, approach: "3")
        }
        
        // Fallback to a simple model if all approaches fail
        if !modelLoaded {
            print("Using fallback cigarette model")
            let fallbackNode = createSimpleCigarette()
            scene.rootNode.addChildNode(fallbackNode)
        }
    }
    
    // Helper to load model from URL
    func loadModel(from url: URL, into scene: SCNScene, approach: String) -> Bool {
        do {
            let modelScene = try SCNScene(url: url, options: nil)
            if let modelNode = modelScene.rootNode.childNodes.first {
                // First create a pivot node at the center of the scene
                let pivotNode = SCNNode()
                pivotNode.name = "cigarette-pivot"
                // Position pivot at the center of the view
                pivotNode.position = SCNVector3(0, -2.5, -4.0) // Moved lower to position at bottom of larger frame
                scene.rootNode.addChildNode(pivotNode)
                
                // Create the container for the cigarette
                let containerNode = SCNNode()
                containerNode.name = "cigarette-container"
                // Add container to pivot
                pivotNode.addChildNode(containerNode)
                
                // Configure the model node
                modelNode.name = "cigarette"
                // Adjust scale for larger view - make it bigger
                modelNode.scale = SCNVector3(0.8, 1.2, 0.8) // Increased from (0.65, 1.0, 0.65)
                // Position it within the container
                modelNode.position = SCNVector3(0, 0, 0)
                // Set initial tilt
                modelNode.eulerAngles = SCNVector3(0, 0, 0)
                
                // Add model to container with initial rotation
                containerNode.addChildNode(modelNode)
                containerNode.eulerAngles = SCNVector3(rotationX, 0, 0)
                
                print("Successfully loaded model with approach \(approach)")
                return true
            } else {
                print("No nodes found in model with approach \(approach)")
                return false
            }
        } catch {
            print("Error loading model with approach \(approach): \(error)")
            return false
        }
    }
    
    // Create a simple cigarette model using SCNCylinder
    func createSimpleCigarette() -> SCNNode {
        // Create a pivot at the center of the scene
        let pivotNode = SCNNode()
        pivotNode.name = "cigarette-pivot"
        pivotNode.position = SCNVector3(0, -2.5, -4.0) // Moved lower to position at bottom of larger frame
        
        // Create a container node for rotation
        let containerNode = SCNNode()
        containerNode.name = "cigarette-container"
        pivotNode.addChildNode(containerNode)
        
        // Create the cigarette node
        let cigaretteNode = SCNNode()
        cigaretteNode.name = "cigarette"
        
        // White body - make it reasonable length
        let body = SCNCylinder(radius: 0.035, height: 1.6) // Increased size
        body.firstMaterial?.diffuse.contents = UIColor.white
        let bodyNode = SCNNode(geometry: body)
        bodyNode.eulerAngles.x = 0
        bodyNode.position = SCNVector3(0, 0, 0)
        cigaretteNode.addChildNode(bodyNode)
        
        // Orange filter
        let filter = SCNCylinder(radius: 0.035, height: 0.3) // Increased size
        filter.firstMaterial?.diffuse.contents = UIColor.orange
        let filterNode = SCNNode(geometry: filter)
        filterNode.position = SCNVector3(0, 0.95, 0) // Adjusted to match larger body
        cigaretteNode.addChildNode(filterNode)
        
        // Smoke wisp
        let smoke = SCNCylinder(radius: 0.018, height: 0.15) // Increased size
        smoke.firstMaterial?.diffuse.contents = UIColor.lightGray.withAlphaComponent(0.7)
        let smokeNode = SCNNode(geometry: smoke)
        smokeNode.position = SCNVector3(0, -0.875, 0) // Adjusted to match larger body
        cigaretteNode.addChildNode(smokeNode)
        
        // Add cigarette to container with initial rotation
        containerNode.addChildNode(cigaretteNode)
        containerNode.eulerAngles = SCNVector3(rotationX, 0, 0)
        
        return pivotNode
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ARExperienceView()
                .tabItem {
                    Image(systemName: "arkit")
                    Text("AR")
                }
            
            QuitSmokingView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Quit Smoking")
                }
        }
    }
}
