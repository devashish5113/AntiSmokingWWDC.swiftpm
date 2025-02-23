//
//  File.swift
//  AntiSmokingWWDC
//
//  Created by Batch - 1 on 05/02/25.
//

import SwiftUI

class HealthTracker: ObservableObject {
    @Published var healthRecords: [HealthData] = [] {
        didSet {
            saveRecords()
        }
    }
    
    init() {
        loadRecords()
    }
    
    var weeklySmokingAverage: Double {
        let recentRecords = healthRecords.prefix(7)
        return Double(recentRecords.reduce(0) { $0 + $1.cigarettesSmoked }) / Double(max(recentRecords.count, 1))
    }
    
    var recommendedDailyGoal: Int {
        let current = Int(ceil(weeklySmokingAverage))
        return max(0, current - 1) // Decrease by 1 from current average, minimum 0
    }
    
    var daysSmokeFree: Int {
        healthRecords.prefix(while: { $0.cigarettesSmoked == 0 }).count
    }
    
    // Persistence
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(healthRecords) {
            UserDefaults.standard.set(encoded, forKey: "HealthRecords")
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "HealthRecords"),
           let decoded = try? JSONDecoder().decode([HealthData].self, from: data) {
            healthRecords = decoded
        }
    }
}

struct HealthData: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var cigarettesSmoked: Int
    var meditation: Int // minutes
    var exercise: Int // minutes
    var waterGlasses: Int
    var mood: String
    var triggers: String
    var copingStrategy: String
}

struct QuitSmokingView: View {
    @StateObject private var tracker = HealthTracker()
    @State private var showingAddRecord = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Journey Progress
                    JourneyProgressView(tracker: tracker)
                        .padding(.top)
                    
                    // Add Data Button
                    AddDataButton(showingAddRecord: $showingAddRecord)
                    
                    // Tab View
                    CustomTabView(selectedTab: $selectedTab, tracker: tracker)
                }
            }
            .navigationTitle("Quit Smoking Journey")
            .sheet(isPresented: $showingAddRecord) {
                AddHealthRecordView(tracker: tracker, isPresented: $showingAddRecord)
            }
        }
    }
}

struct StatisticView: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.custom("Helvetica Neue", size: 14))
                .foregroundColor(.gray)
            Text(value)
                .font(.custom("Helvetica Neue", size: 24))
                .fontWeight(.bold)
            Text(subtitle)
                .font(.custom("Helvetica Neue", size: 12))
                .foregroundColor(.gray)
        }
    }
}

struct JourneyProgressView: View {
    @ObservedObject var tracker: HealthTracker
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Your Progress")
                .font(.custom("Helvetica Neue", size: 24))
                .fontWeight(.bold)
            
            HStack(spacing: 30) {
                StatisticView(title: "Weekly Average",
                            value: String(format: "%.1f", tracker.weeklySmokingAverage),
                            subtitle: "cigarettes/day")
                
                StatisticView(title: "Daily Goal",
                            value: "\(tracker.recommendedDailyGoal)",
                            subtitle: "cigarettes/day")
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct AddDataButton: View {
    @Binding var showingAddRecord: Bool
    
    var body: some View {
        Button(action: { showingAddRecord = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Log Today's Progress")
            }
            .font(.custom("Helvetica Neue", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Helvetica Neue", size: 14))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(isSelected ? Color.blue : Color.clear)
                .foregroundColor(isSelected ? .white : .blue)
                .cornerRadius(20)
        }
    }
}

struct TabContentView: View {
    let selectedTab: Int
    @ObservedObject var tracker: HealthTracker
    
    var body: some View {
        switch selectedTab {
        case 0:
            DailyStatsView(tracker: tracker)
        case 1:
            HealthyHabitsGuide()
        case 2:
            CopingStrategiesView()
        default:
            EmptyView()
        }
    }
}

struct CustomTabView: View {
    @Binding var selectedTab: Int
    @ObservedObject var tracker: HealthTracker
    
    var body: some View {
        VStack {
            HStack {
                TabButton(title: "Progress", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Habits", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "Coping", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal)
            
            TabContentView(selectedTab: selectedTab, tracker: tracker)
        }
    }
}

struct AddHealthRecordView: View {
    @ObservedObject var tracker: HealthTracker
    @Binding var isPresented: Bool
    
    @State private var cigarettesSmoked = ""
    @State private var meditationMinutes = ""
    @State private var exerciseMinutes = ""
    @State private var waterGlasses = ""
    @State private var selectedMood = "Neutral"
    @State private var trigger = ""
    @State private var copingStrategy = ""
    
    let moods = ["Great", "Good", "Neutral", "Stressed", "Anxious"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Health Metrics")) {
                    HStack {
                        Image(systemName: "smoke.fill")
                        TextField("Cigarettes smoked", text: $cigarettesSmoked)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Image(systemName: "brain.head.profile")
                        TextField("Meditation (minutes)", text: $meditationMinutes)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Image(systemName: "figure.run")
                        TextField("Exercise (minutes)", text: $exerciseMinutes)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Image(systemName: "drop.fill")
                        TextField("Glasses of water", text: $waterGlasses)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section(header: Text("Wellbeing")) {
                    Picker("Mood", selection: $selectedMood) {
                        ForEach(moods, id: \.self) { mood in
                            Text(mood).tag(mood)
                        }
                    }
                    
                    TextField("What triggered cravings? (if any)", text: $trigger)
                    TextField("Coping strategies used", text: $copingStrategy)
                }
            }
            .navigationTitle("Add Daily Record")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Save") {
                    saveRecord()
                    isPresented = false
                }
            )
        }
    }
    
    private func saveRecord() {
        let record = HealthData(
            date: Date(),
            cigarettesSmoked: Int(cigarettesSmoked) ?? 0,
            meditation: Int(meditationMinutes) ?? 0,
            exercise: Int(exerciseMinutes) ?? 0,
            waterGlasses: Int(waterGlasses) ?? 0,
            mood: selectedMood,
            triggers: trigger,
            copingStrategy: copingStrategy
        )
        
        tracker.healthRecords.insert(record, at: 0)
    }
}
