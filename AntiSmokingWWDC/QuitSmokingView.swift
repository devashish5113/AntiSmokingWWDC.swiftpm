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
    var id: UUID
    var date: Date
    var cigarettesSmoked: Int
    var meditation: Int // minutes
    var exercise: Int // minutes
    var waterGlasses: Int
    var mood: String
    var triggers: String
    var copingStrategy: String
    
    init(id: UUID = UUID(), date: Date, cigarettesSmoked: Int, meditation: Int, exercise: Int, waterGlasses: Int, mood: String, triggers: String, copingStrategy: String) {
        self.id = id
        self.date = date
        self.cigarettesSmoked = cigarettesSmoked
        self.meditation = meditation
        self.exercise = exercise
        self.waterGlasses = waterGlasses
        self.mood = mood
        self.triggers = triggers
        self.copingStrategy = copingStrategy
    }
}

struct QuitSmokingView: View {
    @StateObject private var tracker = HealthTracker()
    @State private var showingAddRecord = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    JourneyProgressView(tracker: tracker)
                        .padding(.top, 10)
                    
                    AddDataButton(showingAddRecord: $showingAddRecord)
                    
                    CustomTabView(selectedTab: $selectedTab, tracker: tracker)
                }
            }
            .dismissKeyboardOnTap()
            .healthStyleNavigation(title: "Quit Smoking")
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
        VStack(spacing: 20) {
            // Days Smoke Free Counter
            VStack(spacing: 8) {
                Text("\(tracker.daysSmokeFree)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                Text("Days Smoke Free")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
            )
            
            // Statistics Row
            HStack(spacing: 20) {
                StatisticCard(
                    title: "Weekly Average",
                    value: String(format: "%.1f", tracker.weeklySmokingAverage),
                    subtitle: "cigarettes/day",
                    color: .orange
                )
                
                StatisticCard(
                    title: "Daily Goal",
                    value: "\(tracker.recommendedDailyGoal)",
                    subtitle: "cigarettes/day",
                    color: .green
                )
            }
        }
        .padding()
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct AddDataButton: View {
    @Binding var showingAddRecord: Bool
    
    var body: some View {
        Button(action: { showingAddRecord = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("Log Today's Progress")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            )
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
        VStack(spacing: 20) {
            // Custom Segmented Control
            HStack(spacing: 0) {
                ForEach(["Progress", "Habits", "Coping"], id: \.self) { tab in
                    Button(action: {
                        withAnimation {
                            selectedTab = ["Progress", "Habits", "Coping"].firstIndex(of: tab) ?? 0
                        }
                    }) {
                        Text(tab)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(selectedTab == ["Progress", "Habits", "Coping"].firstIndex(of: tab) ? .blue : .secondary)
                    }
                }
            }
            .background(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width / 3, height: 2)
                        .offset(x: CGFloat(selectedTab) * geometry.size.width / 3)
                        .animation(.spring(), value: selectedTab)
                }, alignment: .bottom
            )
            .padding(.horizontal)
            
            // Tab Content
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
        NavigationStack {
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
            .dismissKeyboardOnTap()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecord()
                        isPresented = false
                    }
                    .fontWeight(.bold)
                }
            }
            .navigationTitle("Add Daily Record")
            .navigationBarTitleDisplayMode(.inline)
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
