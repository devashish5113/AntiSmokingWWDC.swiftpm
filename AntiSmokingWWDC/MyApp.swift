import SwiftUI

// Entry Point
@main
struct SmokeFreeApp: App {
    @State private var showOnboarding = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showOnboarding) {
                    WelcomeView(isPresented: $showOnboarding)
                }
        }
    }
}
