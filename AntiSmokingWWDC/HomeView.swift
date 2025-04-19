//
//  File.swift
//  AntiSmokingWWDC
//
//  Created by Batch - 1 on 05/02/25.
//

import SwiftUI
import SceneKit

struct HealthStyleNavigationBar: ViewModifier {
    let color: Color
    let title: String
    
    func body(content: Content) -> some View {
        ZStack {
            // Background gradient layer that extends under navigation bar
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.25),
                        color.opacity(0.18),
                        color.opacity(0.1),
                        color.opacity(0.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 350)
                
                Color(UIColor.systemGroupedBackground)
                    .frame(maxHeight: .infinity)
            }
            .ignoresSafeArea()
            
            // Content layer
            content
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Use NavigationLink only on the HomeView, not in UserProfileView
                        if title != "Profile" {
                            NavigationLink(destination: UserProfileView()) {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 28))
                            }
                        } else {
                            // Just a placeholder for consistent spacing when on profile
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 28))
                                .opacity(0.0) // Make invisible but keep spacing
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

extension View {
    func healthStyleNavigation(title: String, color: Color = .red) -> some View {
        self.modifier(HealthStyleNavigationBar(color: color, title: title))
    }
    
    // Add keyboard dismissal view modifier
    func dismissKeyboardOnTap() -> some View {
        self.modifier(DismissKeyboardOnTapModifier())
    }
}

// Keyboard dismissal modifier
struct DismissKeyboardOnTapModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
}

@MainActor
struct HomeView: View {
    init() {
        // Test if we can load model assets
        Task {
            HomeView.testModelAssets()
        }
    }
    
    // Test function to verify model assets
    private static func testModelAssets() {
        let modelNames = ["brain", "healthylung", "smokerlung", "healthyvsmokerlung", "cigarette"]
        
        for modelName in modelNames {
            // Try with exact names
            if let asset = NSDataAsset(name: modelName) {
                print("✅ ASSET TEST: Found asset with exact name: \(modelName)")
            } else {
                print("❌ ASSET TEST: Could not find asset with exact name: \(modelName)")
                
                // Try with capitalized first letter
                let capitalizedName = modelName.prefix(1).uppercased() + modelName.dropFirst()
                if let asset = NSDataAsset(name: capitalizedName) {
                    print("✅ ASSET TEST: Found asset with capitalized name: \(capitalizedName)")
                } else {
                    print("❌ ASSET TEST: Could not find asset with capitalized name: \(capitalizedName)")
                    
                    // Try with specific pattern for lung models
                    if modelName.contains("lung") {
                        var specialName = ""
                        if modelName.starts(with: "healthy") && !modelName.contains("vs") {
                            specialName = "Healthy" + modelName.dropFirst(7)
                        } else if modelName.starts(with: "smoker") {
                            specialName = "Smoker" + modelName.dropFirst(6)
                        } else if modelName.contains("vsmoker") {
                            specialName = "HealthyVSSmoker" + modelName.dropFirst(16)
                        }
                        
                        if !specialName.isEmpty {
                            if let asset = NSDataAsset(name: specialName) {
                                print("✅ ASSET TEST: Found asset with special name: \(specialName)")
                            } else {
                                print("❌ ASSET TEST: Could not find asset with special name: \(specialName)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Respiratory System Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Respiratory System")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        // Lungs Impact Card
                        lungsImpactCard
                    }
                    
                    // Neurological System Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Neurological System")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        // Brain Impact Card
                        EnhancedImpactCard(
                            title: "Brain",
                            subtitle: "",
                            modelName: "brain",
                            color: .red,
                            impacts: [
                                "Dopamine disruption",
                                "Brain volume reduction",
                                "Chemical imbalance",
                                "Stroke risk doubled"
                            ],
                            detailView: EnhancedBrainImpactDetailView()
                        )
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.top, 20)
                .padding(.bottom)
            }
            .healthStyleNavigation(title: "Impact")
        }
    }
    
    // Enhanced impact card for lungs
    private var lungsImpactCard: some View {
        EnhancedImpactCard(
            title: "Lungs",
            subtitle: "",
            modelName: "HealthyLung",  // Updated to match asset name
            color: .red,
            impacts: [
                "Lung capacity reduced by 30%",
                "Air sacs destruction",
                "Chronic inflammation",
                "High cancer risk"
            ],
            detailView: EnhancedLungsImpactDetailView()
        )
    }
}

// UserDefaults wrapper
class UserSettings: ObservableObject {
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }
    
    @Published var userAge: String {
        didSet {
            UserDefaults.standard.set(userAge, forKey: "userAge")
        }
    }
    
    @Published var smokingYears: String {
        didSet {
            UserDefaults.standard.set(smokingYears, forKey: "smokingYears")
        }
    }
    
    @Published var cigarettesPerDay: String {
        didSet {
            UserDefaults.standard.set(cigarettesPerDay, forKey: "cigarettesPerDay")
        }
    }
    
    @Published var quitDate: Date {
        didSet {
            UserDefaults.standard.set(quitDate, forKey: "quitDate")
        }
    }
    
    init() {
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.userAge = UserDefaults.standard.string(forKey: "userAge") ?? ""
        self.smokingYears = UserDefaults.standard.string(forKey: "smokingYears") ?? ""
        self.cigarettesPerDay = UserDefaults.standard.string(forKey: "cigarettesPerDay") ?? ""
        self.quitDate = UserDefaults.standard.object(forKey: "quitDate") as? Date ?? Date()
    }
}

struct UserProfileView: View {
    @StateObject private var settings = UserSettings()
    @Environment(\.presentationMode) var presentationMode
    
    // Function to get user initials
    private var userInitials: String {
        let name = settings.userName.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            return "?"
        }
        
        let components = name.components(separatedBy: " ")
        if components.count > 1, let first = components.first?.first, let last = components.last?.first {
            return String(first) + String(last)
        } else if let first = name.first {
            return String(first)
        }
        return "?"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Large profile circle with initials
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 120, height: 120)
                    
                    Text(userInitials)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Personal information section
                VStack(spacing: 20) {
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Your Name", text: $settings.userName)
                            .font(.body)
            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    // Age field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Your Age", text: $settings.userAge)
                            .font(.body)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // Improved smoking history section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Smoking History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        // Years smoking card
                        VStack(alignment: .center, spacing: 8) {
                            Text("Years")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("0", text: $settings.smokingYears)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Cigarettes per day card
                        VStack(alignment: .center, spacing: 8) {
                            Text("Daily Cigarettes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("0", text: $settings.cigarettesPerDay)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                
                // Statistics section
                if let cigarettes = Int(settings.cigarettesPerDay), let years = Int(settings.smokingYears), years > 0, cigarettes > 0 {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Overall Impact")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            // Total cigarettes
                            HStack {
                                Text("Total Cigarettes")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(cigarettes * 365 * years)")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            
                            Divider()
                            
                            // Money spent
                            HStack {
                                Text("Money Spent (est.)")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("$\(cigarettes * 365 * years * 1)")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .dismissKeyboardOnTap()
        .healthStyleNavigation(title: "Profile")
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.red)
                .fontWeight(.semibold)
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
    @State private var showMetricsInfo = false
    
    // Get appropriate emoji for the organ
    private var organEmoji: String {
        if title == "Lungs" {
            return "🫁"
        } else if title == "Brain" {
            return "🧠"
        }
        return ""
    }
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Header with title and chevron
                HStack {
                    HStack(spacing: 8) {
                        Text(organEmoji)
                            .font(.system(size: 24))
                        
                        Text(title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 12)
                
                // New layout with main content
                VStack(spacing: 20) {
                    // Risk level and 3D model in one row
                    HStack(alignment: .center, spacing: 0) {
                        Spacer(minLength: 20)
                        
                        // Risk Level as circular gauge with info button - now centered
                        VStack(alignment: .center, spacing: 8) {
                            // Risk level and info button in one line
                            HStack(alignment: .center, spacing: 4) {
                                Text("Risk Level")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    // Open info sheet
                                    showMetricsInfo = true
                                }) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.gray.opacity(0.8))
                                }
                            }
                            .padding(.leading, 5)
                            .padding(.bottom, 10)
                            
                            ZStack {
                                // Background circle
                                Circle()
                                    .stroke(color.opacity(0.2), lineWidth: 8)
                                    .frame(width: 86, height: 86)
                                
                                // Foreground circle (4/5 = 80% filled)
                                Circle()
                                    .trim(from: 0, to: 0.8)
                                    .stroke(color, lineWidth: 8)
                                    .frame(width: 86, height: 86)
                                    .rotationEffect(.degrees(-90))
                                
                                // Percentage
                                Text("80%")
                                    .font(.system(size: 21, weight: .bold))
                                    .foregroundColor(color)
                            }
                        }
                        .frame(width: 110)
                        
                        Spacer()
                        
                        // Model view pushed to the right
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.05))
                            
                            EnhancedModelPreview(modelName: modelName, cardColor: color)
                        }
                        .frame(width: 180, height: 160)
                        .padding(.trailing, 12)
                    }
                    .padding(.vertical, 5)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Key metrics in prominent boxes
                    HStack(spacing: 15) {
                        // Capacity Reduction / Volume Impact
                        VStack(alignment: .center, spacing: 6) {
                            Text(title == "Lungs" ? "Capacity Reduction" : "Volume Impact")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text(title == "Lungs" ? "30%" : "15%")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.08)))
                        
                        // Recovery Time
                        VStack(alignment: .center, spacing: 6) {
                            Text("Recovery Time")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text(title == "Lungs" ? "1-9 months" : "1-2 years")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
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
        .sheet(isPresented: $showMetricsInfo) {
            MetricsInfoView(organName: title)
        }
    }
}

struct MetricsInfoView: View {
    let organName: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Top section with title and explanation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How We Calculate Metrics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        
                        Text("These metrics are based on comprehensive medical research on smoking's effects on the \(organName.lowercased()).")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Risk Level explanation
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 18))
                            }
                            
                            Text("Risk Level")
                                .font(.headline)
                        }
                        
                        Text("Based on data from WHO and CDC studies comparing smokers to non-smokers. The 80% risk level indicates significantly higher likelihood of developing \(organName == "Lungs" ? "respiratory diseases" : "brain and cognitive disorders") compared to non-smokers.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    // Impact explanation
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: organName == "Lungs" ? "lungs.fill" : "brain")
                                    .foregroundColor(.red)
                                    .font(.system(size: 18))
                            }
                            
                            Text(organName == "Lungs" ? "Capacity Reduction" : "Volume Impact")
                                .font(.headline)
                        }
                        
                        Text(organName == "Lungs" 
                             ? "The 30% reduction in lung capacity is observed in long-term smokers after 15-20 years of smoking, based on pulmonary function tests."
                             : "The 15% reduction in brain volume, particularly in regions related to memory and cognitive function, is observed through MRI studies of long-term smokers.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    // Recovery Time explanation
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(.red)
                                    .font(.system(size: 18))
                            }
                            
                            Text("Recovery Time")
                                .font(.headline)
                        }
                        
                        Text(organName == "Lungs" 
                             ? "Recovery timeline of 1-9 months represents time needed for cilia regeneration and improved lung function after quitting. Complete recovery varies by individual and smoking history length."
                             : "1-2 years represents the time needed for brain chemistry normalization and neural pathway rewiring. Neurotransmitter levels typically stabilize within this timeframe.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitle("Metrics Explained", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(Color(UIColor.systemGroupedBackground))
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
            .id(resetTrigger)
            
            // Reset button with white style (smaller version)
            Button(action: {
                resetTrigger.toggle()
            }) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
        }
        .cornerRadius(12)
    }
    
    private func createEnhancedScene() -> SCNScene {
        let scene = SCNScene()
        print("🔍 Attempting to load model: \(modelName)")
        
        // Try to find the model file
        var modelURL: URL?
        let fileManager = FileManager.default
        
        // First try specific asset for this model - use brain-specific handling for brain model
        if modelName.lowercased() == "brain" {
            if let specificAsset = NSDataAsset(name: "Brain") {
                print("✅ Loading brain model from Brain asset")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("brain.usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ Extracted brain model to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ Failed to extract brain model: \(error)")
                }
            }
        } else {
            // For other models, use the existing code
            let assetName = modelName
            if let specificAsset = NSDataAsset(name: assetName) {
                print("✅ Loading specific asset for \(modelName): \(assetName)")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("\(modelName).usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ Extracted model from specific asset to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ Failed to extract model from specific asset: \(error)")
                }
            } else {
                print("❌ Could not find NSDataAsset named: \(assetName) for model: \(modelName)")
            }
        }
            
        // Check if model exists in the 3D Models directory if not found in assets
        if modelURL == nil, let bundle = Bundle.main.resourceURL?.appendingPathComponent("3D Models") {
            let modelFileName = modelName.lowercased() == "brain" ? "brain.usdz" : "\(modelName.lowercased()).usdz"
            let potentialModelURL = bundle.appendingPathComponent(modelFileName)
            if fileManager.fileExists(atPath: potentialModelURL.path) {
                print("✅ Found model in 3D Models directory: \(potentialModelURL.path)")
                modelURL = potentialModelURL
            } else {
                print("❌ Could not find model in 3D Models directory: \(potentialModelURL.path)")
            }
        }
        
        // Check if model exists in base directory
        if modelURL == nil, let bundle = Bundle.main.resourceURL {
            let modelFileName = modelName.lowercased() == "brain" ? "brain.usdz" : "\(modelName.lowercased()).usdz"
            let potentialModelURL = bundle.appendingPathComponent(modelFileName)
            if fileManager.fileExists(atPath: potentialModelURL.path) {
                print("✅ Found model in base directory: \(potentialModelURL.path)")
                modelURL = potentialModelURL
            } else {
                print("❌ Could not find model in base directory: \(potentialModelURL.path)")
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
                        modelNode.eulerAngles = SCNVector3(Float.pi/6 + Float.pi, Float.pi/2, -Float.pi/4 - Float.pi/6)
                        modelNode.scale = SCNVector3(scale * 1.15, scale * 1.15, scale * 1.15)
                        pivotNode.position = SCNVector3(-0.15, 0, -1.35)
                    } else if modelName.lowercased().contains("lung") {
                        // Invert lungs (flip upside down)
                        modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
                    }
                    
                    // Add rotation animation
                    let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 40)
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
        
        // If we get here, use fallback shape
        print("⚠️ Using fallback shape for model: \(modelName)")
        addFallbackShape(to: scene)
        
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
    
    private func addFallbackShape(to scene: SCNScene) {
        print("Creating fallback model for: \(modelName)")
        let modelNode = SCNNode()
        
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
            
            // Position and rotate the brain
            modelNode.eulerAngles = SCNVector3(Float.pi/6 + Float.pi, Float.pi/2, -Float.pi/4 - Float.pi/6)
            
        case "healthylung", "smokerlung":
            // Create a pair of lungs
            let isHealthy = modelName == "healthylung"
            let color = isHealthy ? 
                UIColor(red: 0.9, green: 0.6, blue: 0.6, alpha: 1.0) : 
                UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            
            // Right lung
            let rightLung = SCNCapsule(capRadius: 0.25, height: 0.7)
            rightLung.firstMaterial?.diffuse.contents = color
            let rightLungNode = SCNNode(geometry: rightLung)
            rightLungNode.position = SCNVector3(0.3, 0, 0)
            rightLungNode.eulerAngles = SCNVector3(0, 0, Float.pi/8)
            modelNode.addChildNode(rightLungNode)
            
            // Left lung
            let leftLung = SCNCapsule(capRadius: 0.25, height: 0.7)
            leftLung.firstMaterial?.diffuse.contents = color
            let leftLungNode = SCNNode(geometry: leftLung)
            leftLungNode.position = SCNVector3(-0.3, 0, 0)
            leftLungNode.eulerAngles = SCNVector3(0, 0, -Float.pi/8)
            modelNode.addChildNode(leftLungNode)
            
            // Add trachea
            let trachea = SCNCylinder(radius: 0.08, height: 0.4)
            trachea.firstMaterial?.diffuse.contents = UIColor.white
            let tracheaNode = SCNNode(geometry: trachea)
            tracheaNode.position = SCNVector3(0, 0.55, 0)
            modelNode.addChildNode(tracheaNode)
            
            // Set the lungs orientation
            modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
            
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
            let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.05)
            box.firstMaterial?.diffuse.contents = UIColor.orange
            let boxNode = SCNNode(geometry: box)
            modelNode.addChildNode(boxNode)
        }
        
        // Create a pivot node for rotation
        let pivotNode = SCNNode()
        pivotNode.position = SCNVector3(0, 0, -1.2)
        
        // Add the model to the pivot
        pivotNode.addChildNode(modelNode)
        
        // Add auto-rotation action
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 40)
        let repeatAction = SCNAction.repeatForever(rotationAction)
        pivotNode.runAction(repeatAction)
        
        // Add to scene
        scene.rootNode.addChildNode(pivotNode)
        
        print("Added fallback model for: \(modelName)")
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
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .id(resetTrigger)
            
            // Reset button with blue styling
            Button(action: {
                resetTrigger.toggle()
            }) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue.opacity(0.8))
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.9)))
                    .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
            }
            .padding(16)
        }
    }
    
    private func createEnhancedLargeScene() -> SCNScene {
        let scene = SCNScene()
        print("🔍 Attempting to load large model: \(modelName)")
        
        // Try to find the model file
        var modelURL: URL?
        let fileManager = FileManager.default
        
        // First try specific asset for this model - use brain-specific handling for brain model
        if modelName.lowercased() == "brain" {
            if let specificAsset = NSDataAsset(name: "Brain") {
                print("✅ Loading brain model from Brain asset")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("brain.usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ Extracted brain model to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ Failed to extract brain model: \(error)")
                }
            }
        } else {
            // For other models, use the existing code
            let assetName = modelName
            if let specificAsset = NSDataAsset(name: assetName) {
                print("✅ Loading specific asset for \(modelName): \(assetName)")
                
                // Create a temporary file
                let tempDir = NSTemporaryDirectory()
                let tempFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("\(modelName).usdz")
                
                do {
                    try specificAsset.data.write(to: tempFileURL)
                    print("✅ Extracted model from specific asset to temp file: \(tempFileURL.path)")
                    modelURL = tempFileURL
                } catch {
                    print("❌ Failed to extract model from specific asset: \(error)")
                }
            } else {
                print("❌ Could not find NSDataAsset named: \(assetName) for model: \(modelName)")
            }
        }
            
        // Check if model exists in the 3D Models directory if not found in assets
        if modelURL == nil, let bundle = Bundle.main.resourceURL?.appendingPathComponent("3D Models") {
            let modelFileName = modelName.lowercased() == "brain" ? "brain.usdz" : "\(modelName.lowercased()).usdz"
            let potentialModelURL = bundle.appendingPathComponent(modelFileName)
            if fileManager.fileExists(atPath: potentialModelURL.path) {
                print("✅ Found model in 3D Models directory: \(potentialModelURL.path)")
                modelURL = potentialModelURL
            } else {
                print("❌ Could not find model in 3D Models directory: \(potentialModelURL.path)")
            }
        }
        
        // Check if model exists in base directory
        if modelURL == nil, let bundle = Bundle.main.resourceURL {
            let modelFileName = modelName.lowercased() == "brain" ? "brain.usdz" : "\(modelName.lowercased()).usdz"
            let potentialModelURL = bundle.appendingPathComponent(modelFileName)
            if fileManager.fileExists(atPath: potentialModelURL.path) {
                print("✅ Found model in base directory: \(potentialModelURL.path)")
                modelURL = potentialModelURL
            } else {
                print("❌ Could not find model in base directory: \(potentialModelURL.path)")
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
                    
                    // Scale model appropriately for larger view
                    let scale: Float = 0.15
                    modelNode.scale = SCNVector3(scale, scale, scale)
                    
                    // Position model at center 
                    modelNode.position = SCNVector3(0, 0, 0)
                    pivotNode.position = SCNVector3(0, 0, -1.2)
                    
                    // Set proper initial orientation based on model type
                    if modelName.lowercased() == "brain" {
                        modelNode.eulerAngles = SCNVector3(Float.pi/6 + Float.pi, Float.pi/2, -Float.pi/4 - Float.pi/6)
                        modelNode.scale = SCNVector3(scale * 1.15, scale * 1.15, scale * 1.15)
                        pivotNode.position = SCNVector3(-0.15, 0, -1.35)
                    } else if modelName.lowercased().contains("lung") {
                        // Invert lungs (flip upside down)
                        modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
                    }
                    
                    // Add rotation animation
                    let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 40)
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
        
        // If we get here, use fallback shape
        print("⚠️ Using fallback shape for model: \(modelName)")
        addFallbackShape(to: scene)
        
        // Add enhanced lighting for better visibility
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
    
    private func addFallbackShape(to scene: SCNScene) {
        print("Creating fallback model for: \(modelName)")
        let modelNode = SCNNode()
        
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
            
            // Position and rotate the brain
            modelNode.eulerAngles = SCNVector3(Float.pi/6 + Float.pi, Float.pi/2, -Float.pi/4 - Float.pi/6)
            
        case "healthylung", "smokerlung":
            // Create a pair of lungs
            let isHealthy = modelName == "healthylung"
            let color = isHealthy ? 
                UIColor(red: 0.9, green: 0.6, blue: 0.6, alpha: 1.0) : 
                UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            
            // Right lung
            let rightLung = SCNCapsule(capRadius: 0.25, height: 0.7)
            rightLung.firstMaterial?.diffuse.contents = color
            let rightLungNode = SCNNode(geometry: rightLung)
            rightLungNode.position = SCNVector3(0.3, 0, 0)
            rightLungNode.eulerAngles = SCNVector3(0, 0, Float.pi/8)
            modelNode.addChildNode(rightLungNode)
            
            // Left lung
            let leftLung = SCNCapsule(capRadius: 0.25, height: 0.7)
            leftLung.firstMaterial?.diffuse.contents = color
            let leftLungNode = SCNNode(geometry: leftLung)
            leftLungNode.position = SCNVector3(-0.3, 0, 0)
            leftLungNode.eulerAngles = SCNVector3(0, 0, -Float.pi/8)
            modelNode.addChildNode(leftLungNode)
            
            // Add trachea
            let trachea = SCNCylinder(radius: 0.08, height: 0.4)
            trachea.firstMaterial?.diffuse.contents = UIColor.white
            let tracheaNode = SCNNode(geometry: trachea)
            tracheaNode.position = SCNVector3(0, 0.55, 0)
            modelNode.addChildNode(tracheaNode)
            
            // Set the lungs orientation
            modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
            
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
            let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.05)
            box.firstMaterial?.diffuse.contents = UIColor.orange
            let boxNode = SCNNode(geometry: box)
            modelNode.addChildNode(boxNode)
        }
        
        // Create a pivot node for rotation
        let pivotNode = SCNNode()
        pivotNode.position = SCNVector3(0, 0, -1.2)
        
        // Add the model to the pivot
        pivotNode.addChildNode(modelNode)
        
        // Add auto-rotation action
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi * 2), z: 0, duration: 40)
        let repeatAction = SCNAction.repeatForever(rotationAction)
        pivotNode.runAction(repeatAction)
        
        // Add to scene
        scene.rootNode.addChildNode(pivotNode)
        
        print("Added fallback model for: \(modelName)")
    }
}

struct ImpactInfoCard: View {
    let title: String
    let description: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Enhanced icon with background circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 46, height: 46)
                
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
        )
        .padding(.horizontal)
    }
}

// Enhanced lungs impact detail view
struct EnhancedLungsImpactDetailView: View {
    @State private var selectedSegment = 0
    @State private var showComparison = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Model preview section with segmented control and comparison
                VStack(spacing: 0) {
                    if showComparison {
                        // Comparison view title
                        Text("Healthy vs Smoker's Lungs")
                            .font(.headline)
                            .padding(.top, 16)
                        
                        // Comparison model
                        EnhancedLargeModelView(modelName: "HealthyVSSmokerLung")
                            .frame(height: 300)
                            .padding()
                    } else {
                        // Individual lung view with segment control
                        Picker("Lung Type", selection: $selectedSegment) {
                            Text("Healthy").tag(0)
                            Text("Smoker").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Model display based on selection
                        EnhancedLargeModelView(modelName: selectedSegment == 0 ? "HealthyLung" : "SmokerLung")
                            .frame(height: 300)
                            .padding()
                    }
                    
                    // Toggle button between individual and comparison view
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
                                    .fill(Color.red)
                            )
                            .padding(.horizontal)
                            .padding(.bottom, 16)
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
                
                // Recovery timeline
                CompactRecoveryTimeline(recoverySteps: lungsRecoverySteps)
                    .padding(.top)
            }
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
                        .fill(Color.blue.opacity(0.1))
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

struct CompactRecoveryTimeline: View {
    let recoverySteps: [(timeframe: String, description: String, color: Color)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recovery Timeline")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(recoverySteps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        // Timeline dot and line
                        VStack(spacing: 0) {
                            // Dot
                            Circle()
                                .fill(step.color)
                                .frame(width: 14, height: 14)
                                .background(
                                    Circle()
                                        .stroke(step.color.opacity(0.3), lineWidth: 2)
                                        .frame(width: 20, height: 20)
                                )
                            
                            // Line to next item (except for last item)
                            if index < recoverySteps.count - 1 {
                                Rectangle()
                                    .fill(step.color.opacity(0.3))
                                    .frame(width: 2, height: 40)
                            }
                        }
                        .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.timeframe)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(step.color)
                            
                            Text(step.description)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, index < recoverySteps.count - 1 ? 20 : 0)
                        }
                    }
                    .padding(.leading, 8)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
        }
    }
}

// Add this before the EnhancedLungsImpactDetailView struct
let lungsRecoverySteps = [
    (timeframe: "24-48 hours", description: "Carbon monoxide levels in blood drop to normal. Oxygen levels increase.", color: Color.green),
    (timeframe: "2-3 weeks", description: "Lung function begins to improve. Breathing becomes easier.", color: Color.green),
    (timeframe: "1-9 months", description: "Cilia in lungs regrow, improving ability to clear mucus and reduce infections.", color: Color.blue),
    (timeframe: "10 years", description: "Risk of lung cancer drops to about half that of a smoker.", color: Color.purple)
]

