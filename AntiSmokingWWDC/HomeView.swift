//
//  File.swift
//  AntiSmokingWWDC
//
//  Created by Batch - 1 on 05/02/25.
//

import SwiftUI
import SceneKit

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Lungs Impact Card
                    EnhancedImpactCard(
                        title: "Lungs",
                        subtitle: "Respiratory System Impact",
                        modelName: "healthylung",
                        color: Color.blue.opacity(0.8),
                        impacts: [
                            "Decreased lung capacity by up to 30%",
                            "Destruction of air sacs (alveoli)",
                            "Chronic bronchitis & inflammation",
                            "25x increased lung cancer risk"
                        ],
                        detailView: LungsImpactDetailView()
                    )
                    
                    // Brain Impact Card
                    EnhancedImpactCard(
                        title: "Brain",
                        subtitle: "Neurological System Impact",
                        modelName: "brain",
                        color: Color.purple.opacity(0.8),
                        impacts: [
                            "Disruption of dopamine system",
                            "Reduced brain volume and cortex thinning",
                            "Altered neurotransmitter balance",
                            "Doubled risk of stroke"
                        ],
                        detailView: EnhancedBrainImpactDetailView()
                    )
                    
                    Spacer(minLength: 60)
                }
                .padding(.top, 20)
                .padding(.bottom)
            }
            .navigationTitle("Impact")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct EnhancedImpactCard<DetailContent: View>: View {
    let title: String
    let subtitle: String
    let modelName: String
    let color: Color
    let impacts: [String]
    let detailView: DetailContent
    
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 20)
                
                // Content area
                HStack(alignment: .top, spacing: 0) {
                    // Model view integrated with card color
                    EnhancedModelPreview(modelName: modelName, cardColor: color)
                        .frame(width: 140, height: 160)
                        .padding(.leading, 10)
                        .padding(.vertical, 15)
                    
                    // Impact points
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Impacts")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        
                        ForEach(impacts, id: \.self) { impact in
                            HStack(alignment: .top, spacing: 10) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)
                                
                                Text(impact)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            NavigationView {
                detailView
                    .navigationBarItems(trailing: Button("Close") {
                        showDetail = false
                    })
                    .navigationBarTitle("\(title) Impact", displayMode: .inline)
            }
        }
    }
}

struct EnhancedModelPreview: View {
    let modelName: String
    let cardColor: Color
    
    @State private var resetTrigger = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Scene view with model
            SceneView(
                scene: createEnhancedScene(), 
                options: [.autoenablesDefaultLighting, .allowsCameraControl],
                preferredFramesPerSecond: 60
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(resetTrigger) // Force view refresh on reset
            
            // Reset button
            Button(action: {
                resetTrigger.toggle()
            }) {
                Image(systemName: "arrow.counterclockwise.circle")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(5)
                    .background(Circle().fill(cardColor.opacity(0.3)))
            }
            .padding(8)
        }
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
    
    private func createEnhancedScene() -> SCNScene {
        let scene = SCNScene()
        
        // Try the approach that works for cigarette model
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz") {
            print("Found model with plain name at: \(modelURL)")
            
            do {
                let modelScene = try SCNScene(url: modelURL, options: nil)
                
                // Get all child nodes and handle the first one
                if let modelNode = modelScene.rootNode.childNodes.first {
                    // Create a pivot node for centered rotation
                    let pivotNode = SCNNode()
                    scene.rootNode.addChildNode(pivotNode)
                    
                    // Scale model appropriately for the card preview
                    let scale: Float = 0.12
                    modelNode.scale = SCNVector3(scale, scale, scale)
                    
                    // Position model at center 
                    modelNode.position = SCNVector3(0, 0, 0)
                    pivotNode.position = SCNVector3(0, 0, -1.2) // Move pivot away from camera
                    
                    // Set proper initial orientation based on request
                    if modelName == "brain" {
                        // Match brain orientation exactly with second screenshot
                        modelNode.eulerAngles = SCNVector3(Float.pi/6 + Float.pi, Float.pi/2, -Float.pi/4 - Float.pi/6)
                    } else if modelName.contains("healthyvsmoker") || 
                              modelName.contains("smokerlung") || 
                              modelName.contains("healthylung") {
                        // Invert lungs (flip upside down from current position)
                        modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
                    }
                    
                    // Add rotation animation for visibility - around Y axis only
                    let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 40)
                    let repeatAction = SCNAction.repeatForever(rotationAction)
                    pivotNode.runAction(repeatAction)
                    
                    // Add model to pivot node
                    pivotNode.addChildNode(modelNode)
                    
                    print("Successfully loaded model: \(modelName)")
                } else {
                    print("No child nodes found in model: \(modelName)")
                    addFallbackShape(to: scene)
                }
            } catch {
                print("Error loading model: \(error.localizedDescription)")
                addFallbackShape(to: scene)
            }
        } else {
            print("Could not find model URL for: \(modelName)")
            addFallbackShape(to: scene)
        }
        
        // Add enhanced lighting for better visibility
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 1000
        ambientLight.light?.color = UIColor.white
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
    
    private func addFallbackShape(to scene: SCNScene) {
        let geometry: SCNGeometry
        
        if modelName == "brain" {
            geometry = SCNSphere(radius: 0.5)
            geometry.firstMaterial?.diffuse.contents = UIColor.purple.withAlphaComponent(0.8)
        } else {
            // For lungs, create a simple pair of spheres
            let node = SCNNode()
            
            let leftLung = SCNSphere(radius: 0.4)
            leftLung.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.8)
            let leftNode = SCNNode(geometry: leftLung)
            leftNode.position = SCNVector3(-0.3, 0, 0)
            
            let rightLung = SCNSphere(radius: 0.4)
            rightLung.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.8)
            let rightNode = SCNNode(geometry: rightLung)
            rightNode.position = SCNVector3(0.3, 0, 0)
            
            node.addChildNode(leftNode)
            node.addChildNode(rightNode)
            scene.rootNode.addChildNode(node)
            return
        }
        
        let node = SCNNode(geometry: geometry)
        scene.rootNode.addChildNode(node)
    }
}

struct CompactRecoveryTimeline: View {
    let recoverySteps: [(timeframe: String, description: String, color: Color)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recovery Timeline")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                ForEach(Array(recoverySteps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(step.color)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.timeframe)
                                .font(.headline)
                            
                            Text(step.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

struct LungsImpactDetailView: View {
    @State private var selectedTab = 0
    @State private var showComparison = false
    
    let lungsRecoverySteps = [
        (timeframe: "24-48 hours", description: "Carbon monoxide levels in blood drop to normal. Oxygen levels increase.", color: Color.green),
        (timeframe: "2-3 weeks", description: "Lung function begins to improve. Breathing becomes easier.", color: Color.green),
        (timeframe: "1-9 months", description: "Cilia in lungs regrow, improving ability to clear mucus and reduce infections.", color: Color.blue),
        (timeframe: "10 years", description: "Risk of lung cancer drops to about half that of a smoker.", color: Color.purple)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Model display section with improved design
                VStack {
                    if showComparison {
                        // Comparison model
                        Text("Healthy vs Smoker's Lungs")
                            .font(.headline)
                            .padding(.top)
                        
                        EnhancedLargeModelView(modelName: "healthyvsmokerlung")
                            .frame(height: 300)
                            .padding()
                    } else {
                        // Individual lung models based on selected tab with improved design
                        Picker("Lung Type", selection: $selectedTab) {
                            Text("Healthy").tag(0)
                            Text("Smoker").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.top)
                        
                        EnhancedLargeModelView(modelName: selectedTab == 0 ? "healthylung" : "smokerlung")
                            .frame(height: 300)
                            .padding()
                    }
                    
                    Button(action: {
                        withAnimation {
                            showComparison.toggle()
                        }
                    }) {
                        Text(showComparison ? "View Individual Lungs" : "Compare Lungs")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                                    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 3)
                            )
                            .padding(.horizontal)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.blue.opacity(0.1))
                )
                .padding(.horizontal)
                
                // Information section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Impact on Lungs")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ImpactInfoCard(
                        title: "Decreased Lung Function",
                        description: "Smoking causes inflammation and narrowing of the airways, reducing lung capacity by up to 30%.",
                        iconName: "lungs.fill",
                        color: .blue
                    )
                    
                    ImpactInfoCard(
                        title: "Structural Damage",
                        description: "Tar and chemicals destroy the air sacs (alveoli) in lungs, reducing oxygen exchange efficiency.",
                        iconName: "exclamationmark.triangle.fill",
                        color: .orange
                    )
                    
                    ImpactInfoCard(
                        title: "Chronic Bronchitis",
                        description: "Persistent inflammation leads to constant mucus production and chronic cough.",
                        iconName: "waveform.path.ecg",
                        color: .red
                    )
                    
                    ImpactInfoCard(
                        title: "Cancer Risk",
                        description: "Carcinogens in tobacco smoke damage DNA in lung cells, increasing cancer risk by 25 times.",
                        iconName: "cross.case.fill",
                        color: .purple
                    )
                }
                .padding(.top)
                
                // New compact recovery timeline
                CompactRecoveryTimeline(recoverySteps: lungsRecoverySteps)
                    .padding(.top)
            }
            .padding(.bottom, 50)
        }
    }
}

struct EnhancedBrainImpactDetailView: View {
    @State private var showingNeurotransmitterInfo = false
    @State private var isNeurotransmitterExpanded = false
    
    let brainRecoverySteps = [
        (timeframe: "12-24 hours", description: "Brain oxygen levels normalize as carbon monoxide is cleared from the body.", color: Color.green),
        (timeframe: "2 weeks to 3 months", description: "Neurotransmitter levels begin to normalize. Anxiety and irritability decrease.", color: Color.blue),
        (timeframe: "1-2 years", description: "Neural pathways related to addiction begin to rewire. Cravings significantly reduce.", color: Color.purple)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Model display section with improved design 
                VStack {
                    Text("Brain Anatomy")
                        .font(.headline)
                        .padding(.top)
                    
                    EnhancedLargeModelView(modelName: "brain")
                        .frame(height: 300)
                        .padding()
                }
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.purple.opacity(0.1))
                )
                .padding(.horizontal)
                
                // Neurological Impact section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Neurological Impact")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ImpactInfoCard(
                        title: "Dopamine System Disruption",
                        description: "Nicotine triggers dopamine release, creating addiction patterns similar to heroin and cocaine.",
                        iconName: "brain",
                        color: .purple
                    )
                    
                    ImpactInfoCard(
                        title: "Reduced Brain Volume",
                        description: "Long-term smoking is associated with accelerated thinning of the brain's cortex, affecting cognitive function.",
                        iconName: "arrow.down.circle.fill",
                        color: .red
                    )
                    
                    ImpactInfoCard(
                        title: "Increased Stroke Risk",
                        description: "Smoking doubles stroke risk by narrowing blood vessels and promoting clot formation in the brain.",
                        iconName: "bolt.heart.fill",
                        color: .orange
                    )
                }
                .padding(.top)
                
                // Neurotransmitter section with heading outside card
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Neurotransmitter Changes")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showingNeurotransmitterInfo = true }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                        }
                        
                        Button(action: {
                            withAnimation {
                                isNeurotransmitterExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isNeurotransmitterExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                                .imageScale(.large)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Neurotransmitter content
                    VStack(spacing: 15) {
                        NeurotransmitterBar(
                            name: "Dopamine",
                            normalLevel: 0.4,
                            smokingLevel: 0.9,
                            normalColor: .blue,
                            smokingColor: .red,
                            impact: "Initially increases but leads to receptor desensitization"
                        )
                        
                        if isNeurotransmitterExpanded {
                            NeurotransmitterBar(
                                name: "Serotonin",
                                normalLevel: 0.65,
                                smokingLevel: 0.35,
                                normalColor: .blue,
                                smokingColor: .red,
                                impact: "Disrupted regulation affects mood stability"
                            )
                            
                            NeurotransmitterBar(
                                name: "GABA",
                                normalLevel: 0.6,
                                smokingLevel: 0.25,
                                normalColor: .blue,
                                smokingColor: .red,
                                impact: "Decreased levels increase anxiety"
                            )
                            
                            NeurotransmitterBar(
                                name: "Acetylcholine",
                                normalLevel: 0.7,
                                smokingLevel: 0.45,
                                normalColor: .blue,
                                smokingColor: .red,
                                impact: "Receptor desensitization impairs memory"
                            )
                        }
                    }
                }
                .padding(.top)
                .sheet(isPresented: $showingNeurotransmitterInfo) {
                    NavigationView {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // Header with icon
                                HStack(spacing: 15) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 30))
                                        .foregroundColor(.purple)
                                    
                                    Text("Understanding Neurotransmitters")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal)
                                
                                // Introduction text
                                Text("Neurotransmitters are chemical messengers in your brain that regulate everything from mood to memory. They're crucial for normal brain function and are significantly impacted by smoking.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                // Neurotransmitter cards
                                VStack(alignment: .leading, spacing: 20) {
                                    NeurotransmitterExplanation(
                                        name: "Dopamine",
                                        description: "The 'reward' chemical that creates feelings of pleasure and reinforces behaviors. Smoking artificially stimulates its release."
                                    )
                                    
                                    NeurotransmitterExplanation(
                                        name: "Serotonin",
                                        description: "Regulates mood, sleep, and appetite. Smoking disrupts its natural balance, potentially leading to mood disorders."
                                    )
                                    
                                    NeurotransmitterExplanation(
                                        name: "GABA",
                                        description: "The brain's main inhibitory neurotransmitter that helps reduce anxiety and stress. Smoking alters its effectiveness."
                                    )
                                    
                                    NeurotransmitterExplanation(
                                        name: "Acetylcholine",
                                        description: "Essential for memory and learning. Nicotine binds to these receptors, leading to both short-term enhancement and long-term dysfunction."
                                    )
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                        }
                        .navigationTitle("Neurotransmitter Guide")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingNeurotransmitterInfo = false
                                }
                            }
                        }
                    }
                }
                
                // Recovery timeline
                CompactRecoveryTimeline(recoverySteps: brainRecoverySteps)
                    .padding(.top)
            }
            .padding(.bottom, 50)
        }
    }
}

struct NeurotransmitterExplanation: View {
    let name: String
    let description: String
    
    var iconName: String {
        switch name {
        case "Dopamine": return "brain.head.profile"
        case "Serotonin": return "heart.circle.fill"
        case "GABA": return "waveform.path.ecg"
        case "Acetylcholine": return "memorychip"
        default: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch name {
        case "Dopamine": return .purple
        case "Serotonin": return .blue
        case "GABA": return .green
        case "Acetylcholine": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

struct NeurotransmitterBar: View {
    let name: String
    let normalLevel: Double
    let smokingLevel: Double
    let normalColor: Color
    let smokingColor: Color
    let impact: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                // Normal level label
                Text("Normal")
                    .font(.subheadline)
                    .frame(width: 70, alignment: .trailing)
                
                // Normal level bar
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(normalColor)
                        .frame(width: geometry.size.width * CGFloat(normalLevel), height: 12)
                }
                .frame(height: 12)
            }
            
            HStack(spacing: 20) {
                // Smoking level label
                Text("Smoking")
                    .font(.subheadline)
                    .frame(width: 70, alignment: .trailing)
                
                // Smoking level bar
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(smokingColor)
                        .frame(width: geometry.size.width * CGFloat(smokingLevel), height: 12)
                }
                .frame(height: 12)
            }
            
            // Impact description
            Text(impact)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct EnhancedLargeModelView: View {
    let modelName: String
    
    @State private var resetTrigger = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Use SceneView with allowsCameraControl option for rotation
            SceneView(
                scene: createEnhancedLargeScene(), 
                options: [.autoenablesDefaultLighting, .allowsCameraControl],
                preferredFramesPerSecond: 60
            )
            .background(Color.white)
            .cornerRadius(12)
            .id(resetTrigger) // Force view refresh on reset
            
            // Reset button
            Button(action: {
                resetTrigger.toggle()
            }) {
                Image(systemName: "arrow.counterclockwise.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.7)))
            }
            .padding(12)
        }
    }
    
    private func createEnhancedLargeScene() -> SCNScene {
        let scene = SCNScene()
        
        // Try the approach that works for cigarette model
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz") {
            print("Found large model with plain name at: \(modelURL)")
            
            do {
                let modelScene = try SCNScene(url: modelURL, options: nil)
                
                // Get all child nodes and handle the first one
                if let modelNode = modelScene.rootNode.childNodes.first {
                    // Create a pivot node for centered rotation
                    let pivotNode = SCNNode()
                    scene.rootNode.addChildNode(pivotNode)
                    
                    // Scale model appropriately
                    let scale: Float = 0.15
                    modelNode.scale = SCNVector3(scale, scale, scale)
                    
                    // Position model at center for good visibility
                    modelNode.position = SCNVector3(0, 0, 0)
                    pivotNode.position = SCNVector3(0, 0, -1.2) // Move pivot away from camera
                    
                    // Set proper initial orientation based on request
                    if modelName == "brain" {
                        // Match brain orientation exactly with second screenshot
                        modelNode.eulerAngles = SCNVector3(Float.pi/6 + Float.pi, Float.pi/2, -Float.pi/4 - Float.pi/6)
                    } else if modelName.contains("healthyvsmoker") || 
                              modelName.contains("smokerlung") || 
                              modelName.contains("healthylung") {
                        // Invert lungs (flip upside down from current position)
                        modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
                    }
                    
                    // Add very slow rotation animation for subtle movement
                    let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 120) // Extremely slow rotation
                    let repeatAction = SCNAction.repeatForever(rotationAction)
                    pivotNode.runAction(repeatAction)
                    
                    // Add model to pivot node
                    pivotNode.addChildNode(modelNode)
                    
                    print("Successfully loaded large model: \(modelName)")
                } else {
                    print("No child nodes found in large model: \(modelName)")
                    addFallbackShape(to: scene)
                }
            } catch {
                print("Error loading large model: \(error.localizedDescription)")
                addFallbackShape(to: scene)
            }
        } else {
            print("Could not find large model URL for: \(modelName)")
            addFallbackShape(to: scene)
        }
        
        // Enhanced lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 1400
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 1800
        directionalLight.position = SCNVector3(x: 5, y: 5, z: 5)
        scene.rootNode.addChildNode(directionalLight)
        
        let backLight = SCNNode()
        backLight.light = SCNLight()
        backLight.light?.type = .directional
        backLight.light?.intensity = 1400
        backLight.position = SCNVector3(x: -5, y: 0, z: -5)
        scene.rootNode.addChildNode(backLight)
        
        return scene
    }
    
    private func addFallbackShape(to scene: SCNScene) {
        let geometry: SCNGeometry
        
        if modelName == "brain" {
            geometry = SCNSphere(radius: 0.5)
            geometry.firstMaterial?.diffuse.contents = UIColor.purple.withAlphaComponent(0.8)
        } else if modelName.contains("healthy") && modelName.contains("smoker") {
            // For comparison view, create both side by side
            let node = SCNNode()
            
            // Healthy lungs (left side)
            let healthyLeft = SCNSphere(radius: 0.4)
            healthyLeft.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.8)
            let healthyLeftNode = SCNNode(geometry: healthyLeft)
            healthyLeftNode.position = SCNVector3(-0.8, 0, 0)
            
            let healthyRight = SCNSphere(radius: 0.4)
            healthyRight.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.8)
            let healthyRightNode = SCNNode(geometry: healthyRight)
            healthyRightNode.position = SCNVector3(-0.2, 0, 0)
            
            // Smoker lungs (right side)
            let smokerLeft = SCNSphere(radius: 0.4)
            smokerLeft.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.8)
            let smokerLeftNode = SCNNode(geometry: smokerLeft)
            smokerLeftNode.position = SCNVector3(0.2, 0, 0)
            
            let smokerRight = SCNSphere(radius: 0.4)
            smokerRight.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.8)
            let smokerRightNode = SCNNode(geometry: smokerRight)
            smokerRightNode.position = SCNVector3(0.8, 0, 0)
            
            node.addChildNode(healthyLeftNode)
            node.addChildNode(healthyRightNode)
            node.addChildNode(smokerLeftNode)
            node.addChildNode(smokerRightNode)
            scene.rootNode.addChildNode(node)
            return
        } else if modelName.contains("smoker") {
            // For smoker lungs
            let node = SCNNode()
            
            let leftLung = SCNSphere(radius: 0.4)
            leftLung.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.8)
            let leftNode = SCNNode(geometry: leftLung)
            leftNode.position = SCNVector3(-0.3, 0, 0)
            
            let rightLung = SCNSphere(radius: 0.4)
            rightLung.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.8)
            let rightNode = SCNNode(geometry: rightLung)
            rightNode.position = SCNVector3(0.3, 0, 0)
            
            node.addChildNode(leftNode)
            node.addChildNode(rightNode)
            scene.rootNode.addChildNode(node)
            return
        } else {
            // For healthy lungs
            let node = SCNNode()
            
            let leftLung = SCNSphere(radius: 0.4)
            leftLung.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.8)
            let leftNode = SCNNode(geometry: leftLung)
            leftNode.position = SCNVector3(-0.3, 0, 0)
            
            let rightLung = SCNSphere(radius: 0.4)
            rightLung.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.8)
            let rightNode = SCNNode(geometry: rightLung)
            rightNode.position = SCNVector3(0.3, 0, 0)
            
            node.addChildNode(leftNode)
            node.addChildNode(rightNode)
            scene.rootNode.addChildNode(node)
            return
        }
        
        let node = SCNNode(geometry: geometry)
        scene.rootNode.addChildNode(node)
    }
}

struct ImpactInfoCard: View {
    let title: String
    let description: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
            .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
