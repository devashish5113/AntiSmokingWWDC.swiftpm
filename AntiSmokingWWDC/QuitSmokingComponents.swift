// Add these structures to the QuitSmokingComponents.swift file

import SwiftUI

// Daily Stats Components
struct DailyStatsView: View {
    @ObservedObject var tracker: HealthTracker
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(tracker.healthRecords.prefix(7)) { record in
                DailyStatCard(record: record)
            }
        }
        .padding()
    }
}

struct DailyStatCard: View {
    let record: HealthData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(record.date.formatted(.dateTime.month().day()))
                    .font(.custom("Helvetica Neue", size: 16))
                    .fontWeight(.bold)
                Text(record.mood)
                    .font(.custom("Helvetica Neue", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                StatColumn(value: record.cigarettesSmoked, label: "🚬")
                StatColumn(value: record.meditation, label: "🧘‍♂️")
                StatColumn(value: record.exercise, label: "🏃‍♂️")
                StatColumn(value: record.waterGlasses, label: "💧")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatColumn: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.custom("Helvetica Neue", size: 16))
                .fontWeight(.bold)
            Text(label)
                .font(.custom("Helvetica Neue", size: 14))
        }
    }
}

// Healthy Habits Components
struct HealthyHabitsGuide: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(healthyHabits) { habit in
                HabitCard(habit: habit)
            }
        }
        .padding()
    }
}

struct Habit: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let targetPerDay: String
}

let healthyHabits = [
    Habit(title: "Meditation", 
          description: "Reduces stress and anxiety, improves focus",
          icon: "🧘‍♂️",
          targetPerDay: "15-20 minutes"),
    Habit(title: "Exercise",
          description: "Boosts mood and reduces cravings",
          icon: "🏃‍♂️",
          targetPerDay: "30 minutes"),
    Habit(title: "Water Intake",
          description: "Helps flush toxins and reduce cravings",
          icon: "💧",
          targetPerDay: "8 glasses"),
    Habit(title: "Deep Breathing",
          description: "Immediate stress relief when craving hits",
          icon: "🫁",
          targetPerDay: "5-10 times")
]

struct HabitCard: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(habit.icon)
                    .font(.system(size: 30))
                Text(habit.title)
                    .font(.custom("Helvetica Neue", size: 18))
                    .fontWeight(.bold)
            }
            
            Text(habit.description)
                .font(.custom("Helvetica Neue", size: 14))
                .foregroundColor(.gray)
            
            Text("Daily Target: \(habit.targetPerDay)")
                .font(.custom("Helvetica Neue", size: 14))
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// Coping Strategies Components
struct CopingStrategiesView: View {
    let strategies = [
        "Delay": "Wait 5 minutes when a craving hits. The urge often passes.",
        "Distract": "Call a friend, go for a walk, or play a game.",
        "Deep Breathe": "Take 10 slow, deep breaths when stressed.",
        "Drink Water": "Sometimes thirst is mistaken for a craving.",
        "Do Exercise": "Even a short walk can reduce cravings."
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(Array(strategies.keys.sorted()), id: \.self) { strategy in
                VStack(alignment: .leading, spacing: 8) {
                    Text(strategy)
                        .font(.custom("Helvetica Neue", size: 18))
                        .fontWeight(.bold)
                    Text(strategies[strategy] ?? "")
                        .font(.custom("Helvetica Neue", size: 14))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
    }
} 
