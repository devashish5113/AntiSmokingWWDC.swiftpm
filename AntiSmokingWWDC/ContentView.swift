import SwiftUI
import SceneKit

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                SceneView(
                    scene: {
                        let scene = SCNScene()
                        
                        // Add ambient light
                        let ambientLight = SCNNode()
                        ambientLight.light = SCNLight()
                        ambientLight.light?.type = .ambient
                        ambientLight.light?.intensity = 2000
                        scene.rootNode.addChildNode(ambientLight)
                        
                        // Add directional light for better visibility
                        let directionalLight = SCNNode()
                        directionalLight.light = SCNLight()
                        directionalLight.light?.type = .directional
                        directionalLight.light?.intensity = 3000
                        directionalLight.position = SCNVector3(x: 0, y: 10, z: 10)
                        scene.rootNode.addChildNode(directionalLight)
                        
                        // Load 3D model from asset catalog
                        if let modelScene = SCNScene(named: "cigarette.usdz", inDirectory: "3D Models", options: nil) {
                            let modelNode = modelScene.rootNode.childNodes.first!
                            modelNode.scale = SCNVector3(2.0, 2.0, 2.0)
                            modelNode.position = SCNVector3(0, 0, -5)
                            modelNode.eulerAngles = SCNVector3(x: 0, y: .pi / 4, z: 0)
                            scene.rootNode.addChildNode(modelNode)
                        } else {
                            print("Failed to load model: cigarette.usdz")
                        }
                        
                        return scene
                    }(),
                    options: [.allowsCameraControl, .autoenablesDefaultLighting]
                )
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.4)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                
                Text("What happens when you smoke?")
                    .font(.custom("Helvetica Neue", size: 28))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                NavigationLink(destination: ContentView()) {
                    Text("Try")
                        .font(.custom("Helvetica Neue", size: 24))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
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
