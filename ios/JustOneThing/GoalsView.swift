import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dailyGoals: [DailyGoal]
    @Query private var weeklyGoals: [WeeklyGoal]
    @Query private var userStats: [UserStats]
    
    @State private var showEditDaily = false
    @State private var showEditWeekly = false
    
    @State private var dailyFocusTarget: Int = 120
    @State private var dailySessionsTarget: Int = 4
    @State private var weeklyFocusTarget: Int = 600
    @State private var weeklySessionsTarget: Int = 20
    
    private var todayGoal: DailyGoal? {
        let calendar = Calendar.current
        return dailyGoals.first { calendar.isDate($0.date, inSameDayAs: Date()) }
    }
    
    private var currentWeekGoal: WeeklyGoal? {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return weeklyGoals.first { calendar.isDate($0.weekStartDate, inSameDayAs: weekStart) }
    }
    
    private var stats: UserStats? {
        userStats.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    dailyGoalCard
                    
                    weeklyGoalCard
                    
                    streakCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditDaily = true
                    }
                }
            }
            .sheet(isPresented: $showEditDaily) {
                EditDailyGoalSheet(
                    focusTarget: $dailyFocusTarget,
                    sessionsTarget: $dailySessionsTarget,
                    onSave: saveDailyGoal
                )
            }
            .sheet(isPresented: $showEditWeekly) {
                EditWeeklyGoalSheet(
                    focusTarget: $weeklyFocusTarget,
                    sessionsTarget: $weeklySessionsTarget,
                    onSave: saveWeeklyGoal
                )
            }
            .onAppear {
                loadGoals()
            }
        }
    }
    
    private var dailyGoalCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.yellow)
                Text("Daily Goal")
                    .font(.headline)
                Spacer()
                Button("Edit") {
                    showEditDaily = true
                }
                .font(.subheadline)
            }
            
            if let goal = todayGoal {
                GoalProgressRow(
                    title: "Focus Time",
                    current: goal.focusMinutesAchieved,
                    target: goal.focusMinutesTarget,
                    unit: "min",
                    color: AppStyling.primaryGreen
                )
                
                GoalProgressRow(
                    title: "Sessions",
                    current: goal.sessionsCompleted,
                    target: goal.sessionsTarget,
                    unit: "",
                    color: .blue
                )
            } else {
                Text("No goal set for today")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .premiumCard()
    }
    
    private var weeklyGoalCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text("Weekly Goal")
                    .font(.headline)
                Spacer()
                Button("Edit") {
                    showEditWeekly = true
                }
                .font(.subheadline)
            }
            
            if let goal = currentWeekGoal {
                GoalProgressRow(
                    title: "Focus Time",
                    current: goal.focusMinutesAchieved,
                    target: goal.focusMinutesTarget,
                    unit: "min",
                    color: .purple
                )
                
                GoalProgressRow(
                    title: "Sessions",
                    current: goal.sessionsCompleted,
                    target: goal.sessionsTarget,
                    unit: "",
                    color: .orange
                )
                
                if let stats = stats {
                    GoalProgressRow(
                        title: "Streak",
                        current: stats.currentStreak,
                        target: min(stats.currentStreak + 3, 7),
                        unit: "days",
                        color: .red
                    )
                }
            } else {
                Text("No goal set for this week")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .premiumCard()
    }
    
    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Streak")
                    .font(.headline)
                Spacer()
            }
            
            if let stats = stats {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current Streak")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(stats.currentStreak) days")
                            .font(.title.bold())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Longest Streak")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(stats.longestStreak) days")
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .premiumCard()
    }
    
    private func loadGoals() {
        if let goal = todayGoal {
            dailyFocusTarget = goal.focusMinutesTarget
            dailySessionsTarget = goal.sessionsTarget
        }
        
        if let goal = currentWeekGoal {
            weeklyFocusTarget = goal.focusMinutesTarget
            weeklySessionsTarget = goal.sessionsTarget
        }
    }
    
    private func saveDailyGoal() {
        if let goal = todayGoal {
            goal.focusMinutesTarget = dailyFocusTarget
            goal.sessionsTarget = dailySessionsTarget
        } else {
            let newGoal = DailyGoal(focusMinutesTarget: dailyFocusTarget, sessionsTarget: dailySessionsTarget)
            modelContext.insert(newGoal)
        }
        try? modelContext.save()
        AppStyling.hapticSuccess()
    }
    
    private func saveWeeklyGoal() {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        
        if let goal = currentWeekGoal {
            goal.focusMinutesTarget = weeklyFocusTarget
            goal.sessionsTarget = weeklySessionsTarget
        } else {
            let newGoal = WeeklyGoal(focusMinutesTarget: weeklyFocusTarget, sessionsTarget: weeklySessionsTarget)
            modelContext.insert(newGoal)
        }
        try? modelContext.save()
        AppStyling.hapticSuccess()
    }
}

struct GoalProgressRow: View {
    let title: String
    let current: Int
    let target: Int
    let unit: String
    let color: Color
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(current)\(unit.isEmpty ? "" : " " + unit) / \(target)\(unit.isEmpty ? "" : " " + unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.gradient)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct EditDailyGoalSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var focusTarget: Int
    @Binding var sessionsTarget: Int
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Daily Targets") {
                    Stepper("Focus Time: \(focusTarget) min", value: $focusTarget, in: 15...480, step: 15)
                    Stepper("Sessions: \(sessionsTarget)", value: $sessionsTarget, in: 1...20)
                }
                
                Section("Presets") {
                    Button("Light (60 min, 2 sessions)") {
                        focusTarget = 60
                        sessionsTarget = 2
                    }
                    Button("Medium (120 min, 4 sessions)") {
                        focusTarget = 120
                        sessionsTarget = 4
                    }
                    Button("Intense (240 min, 8 sessions)") {
                        focusTarget = 240
                        sessionsTarget = 8
                    }
                }
            }
            .navigationTitle("Daily Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditWeeklyGoalSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var focusTarget: Int
    @Binding var sessionsTarget: Int
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Weekly Targets") {
                    Stepper("Focus Time: \(focusTarget) min", value: $focusTarget, in: 60...1200, step: 60)
                    Stepper("Sessions: \(sessionsTarget)", value: $sessionsTarget, in: 5...50)
                }
                
                Section("Presets") {
                    Button("Light (300 min, 10 sessions)") {
                        focusTarget = 300
                        sessionsTarget = 10
                    }
                    Button("Medium (600 min, 20 sessions)") {
                        focusTarget = 600
                        sessionsTarget = 20
                    }
                    Button("Intense (1200 min, 40 sessions)") {
                        focusTarget = 1200
                        sessionsTarget = 40
                    }
                }
            }
            .navigationTitle("Weekly Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
    }
}
