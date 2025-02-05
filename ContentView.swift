import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🚭 Smoke-Free Life")
                    .font(.custom("Helvetica Neue", size: 34))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Discover the truth about smoking, experience its effects in AR, and take a step toward a healthier future.")
                    .font(.custom("Helvetica Neue", size: 17))
                    .multilineTextAlignment(.center)
                    .padding()
                
                NavigationLink(destination: ContentView()) {
                    Text("Get Started")
                        .font(.custom("Helvetica Neue", size: 22))
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
