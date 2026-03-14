import SwiftUI
import SwiftData
import Charts

struct MainDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var blockedApps: [BlockedApp]
    @Query(sort: \UsageEvent.timestamp, order: .reverse) private var events: [UsageEvent]
    @Query private var userStats: [UserStats]
    @Query private var achievements: [Achievement]
    @Query private var focusModes: [FocusMode]
    
    @State private var pickerIsPresented = false
    @State private var selection = FamilyActivitySelection()
    @State private var selectedTab = 0
    
    private var stats: UserStats {
        if let existing = userStats.first {
            return existing
        }
        let newStats = UserStats()
        modelContext.insert(newStats)
        return newStats
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            dashboardTab
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            pomodoroTab
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
                .tag(1)
            
            goalsTab
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
                .tag(2)
            
            historyTab
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .tag(3)
            
            achievementsTab
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Achievements")
                }
                .tag(4)
            
            settingsTab
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(5)
        }
        .tint(AppStyling.primaryGreen)
        .familyActivityPicker(isPresented: $pickerIsPresented, selection: $selection)
        .onChange(of: selection) { newSelection in
            saveSelection(newSelection)
        }
    }
    
    private var dashboardTab: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    StatsHeaderView(stats: stats, streak: stats.currentStreak)
                    
                    LevelProgressView(stats: stats)
                    
                    QuickActionsView(pickerIsPresented: $pickerIsPresented)
                    
                    RecentActivitySection(events: Array(events.prefix(5)))
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        AppStyling.hapticLight()
                    } label: {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(AppStyling.primaryGreen)
                    }
                }
            }
        }
    }
    
    private var pomodoroTab: some View {
        PomodoroTimerView()
    }
    
    private var goalsTab: some View {
        GoalsView()
    }
    
    private var historyTab: some View {
        SessionHistoryView()
    }
    
    private var analyticsTab: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    WeeklyChartView(events: events)
                    TimeOfDayChartView(events: events)
                    InsightsCardView(stats: stats, events: events)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Analytics")
        }
    }
    
    private var achievementsTab: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    AchievementProgressCard(achievements: achievements, stats: stats)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(achievements) { achievement in
                            AchievementCard(achievement: achievement, stats: stats)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Achievements")
        }
    }
    
    private var settingsTab: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        TimerSettingsView()
                    } label: {
                        Label("Timer Settings", systemImage: "timer")
                    }
                    
                    NavigationLink {
                        GoalsView()
                    } label: {
                        Label("Goals", systemImage: "target")
                    }
                }
                
                Section("Focus Modes") {
                    ForEach(focusModes) { mode in
                        FocusModeRow(mode: mode)
                    }
                    Button {
                        AppStyling.hapticLight()
                    } label: {
                        Label("Add Focus Mode", systemImage: "plus.circle.fill")
                    }
                }
                
                Section("Blocked Apps") {
                    ForEach(blockedApps) { app in
                        HStack {
                            Image(systemName: "app.fill")
                                .foregroundColor(.secondary)
                            Text(app.displayName)
                        }
                    }
                    .onDelete(perform: deleteApps)
                }
                
                Section("Siri Shortcuts") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Use Siri to control focus:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Group {
                            Text("• \"Start focus session in Just One Thing\"")
                            Text("• \"Stop focus session\"")
                            Text("• \"How am I doing in Just One Thing\"")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func saveSelection(_ selection: FamilyActivitySelection) {
        AppStyling.hapticMedium()
    }
    
    private func deleteApps(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(blockedApps[index])
            }
        }
    }
}

struct StatsHeaderView: View {
    let stats: UserStats
    let streak: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Impulse Control")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("\(stats.successRate)%")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyling.premiumGradient)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streak)")
                            .font(.title2.bold())
                    }
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.15))
                .cornerRadius(12)
            }
            
            Divider()
            
            HStack {
                StatItem(value: "\(stats.totalSuccesses)", label: "Focus Wins", icon: "checkmark.circle.fill", color: .green)
                Spacer()
                StatItem(value: "\(stats.totalChoices)", label: "Choices", icon: "hand.raised.fill", color: .orange)
                Spacer()
                StatItem(value: formatTimeSaved(stats.totalTimeSavedMinutes), label: "Saved", icon: "clock.fill", color: .blue)
            }
        }
        .padding()
        .premiumCard()
    }
    
    private func formatTimeSaved(_ minutes: Int) -> String {
        if minutes >= 60 {
            return "\(minutes / 60)h"
        }
        return "\(minutes)m"
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.headline.bold())
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LevelProgressView: View {
    let stats: UserStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(AppStyling.premiumGradient)
                        Text("Level \(stats.level)")
                            .font(.headline.bold())
                    }
                    Text(stats.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(stats.experiencePoints) / \(stats.level * 100) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppStyling.premiumGradient)
                        .frame(width: geometry.size.width * stats.levelProgress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .premiumCard()
    }
}

struct QuickActionsView: View {
    @Binding var pickerIsPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button {
                AppStyling.hapticMedium()
                pickerIsPresented = true
            } label: {
                HStack {
                    Image(systemName: "app.badge.fill")
                        .foregroundColor(AppStyling.primaryGreen)
                    Text("Manage Blocked Apps")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            NavigationLink {
                StatsDetailView()
            } label: {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                    Text("View Analytics")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
}

struct RecentActivitySection: View {
    let events: [UsageEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
            
            if events.isEmpty {
                EmptyStateView(
                    icon: "clock.badge.checkmark",
                    title: "No Activity Yet",
                    message: "Start using focus mode to see your progress here"
                )
                .frame(height: 150)
            } else {
                ForEach(events) { event in
                    ActivityRow(event: event)
                }
            }
        }
        .padding()
        .premiumCard()
    }
}

struct ActivityRow: View {
    let event: UsageEvent
    
    var body: some View {
        HStack {
            Image(systemName: event.outcome == "SUCCESS" ? "checkmark.circle.fill" : "hand.raised.fill")
                .foregroundColor(event.outcome == "SUCCESS" ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.appBundleId)
                    .font(.subheadline)
                Text(event.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(event.outcome == "SUCCESS" ? "Focused" : "Chose")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(event.outcome == "SUCCESS" ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct WeeklyChartView: View {
    let events: [UsageEvent]
    
    var weeklyData: [(day: String, success: Int, choice: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        var data: [(day: String, success: Int, choice: Int)] = []
        
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayIndex = calendar.component(.weekday, from: date) - 1
            let dayName = dayNames[dayIndex]
            
            let dayEvents = events.filter { event in
                calendar.isDate(event.timestamp, inSameDayAs: date)
            }
            
            let successes = dayEvents.filter { $0.outcome == "SUCCESS" }.count
            let choices = dayEvents.filter { $0.outcome == "CHOICE" }.count
            
            data.append((dayName, successes, choices))
        }
        
        return data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
            
            Chart(weeklyData, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Count", item.success)
                )
                .foregroundStyle(AppStyling.primaryGreen.gradient)
                
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Count", item.choice)
                )
                .foregroundStyle(Color.orange.gradient)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            
            HStack {
                LegendItem(color: AppStyling.primaryGreen, label: "Focused")
                Spacer()
                LegendItem(color: .orange, label: "Chose to use")
            }
            .font(.caption)
        }
        .padding()
        .premiumCard()
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

struct TimeOfDayChartView: View {
    let events: [UsageEvent]
    
    var hourlyData: [(hour: Int, count: Int)] {
        var counts = Array(repeating: 0, count: 24)
        
        for event in events {
            let hour = Calendar.current.component(.hour, from: event.timestamp)
            counts[hour] += 1
        }
        
        return (0..<24).map { (hour: $0, count: counts[$0]) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus by Hour")
                .font(.headline)
            
            Chart(hourlyData, id: \.hour) { item in
                LineMark(
                    x: .value("Hour", item.hour),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(AppStyling.primaryGreen.gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Hour", item.hour),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(AppStyling.primaryGreen.opacity(0.2).gradient)
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks(values: [0, 6, 12, 18, 24]) { value in
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            Text("\(hour)")
                        }
                    }
                }
            }
        }
        .padding()
        .premiumCard()
    }
}

struct InsightsCardView: View {
    let stats: UserStats
    let events: [UsageEvent]
    
    var insight: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayEvents = events.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        
        if todayEvents.isEmpty {
            return "Start your day with focus! Open an app to begin tracking."
        }
        
        let todaySuccesses = todayEvents.filter { $0.outcome == "SUCCESS" }.count
        let totalToday = todayEvents.count
        let rate = totalToday > 0 ? Int((Double(todaySuccesses) / Double(totalToday)) * 100) : 0
        
        if rate >= 80 {
            return "You're on fire today! \(rate)% focus rate. Keep it up!"
        } else if rate >= 50 {
            return "Good progress! \(rate)% focus rate today. Push for higher!"
        } else {
            return "Today is tough. Remember: every moment of focus counts!"
        }
    }
    
    var timeSavedThisWeek: Int {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        let weekEvents = events.filter { $0.timestamp > weekAgo && $0.outcome == "SUCCESS" }
        return weekEvents.count * 5
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.headline)
            
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text(insight)
                    .font(.subheadline)
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Time Saved This Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(timeSavedThisWeek) min")
                        .font(.title2.bold())
                        .foregroundStyle(AppStyling.premiumGradient)
                }
                Spacer()
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.title)
                    .foregroundColor(AppStyling.primaryGreen)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding()
        .premiumCard()
    }
}

struct AchievementProgressCard: View {
    let achievements: [Achievement]
    let stats: UserStats
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                Spacer()
                Text("\(unlockedCount)/\(achievements.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppStyling.premiumGradient)
                        .frame(width: geometry.size.width * (Double(unlockedCount) / Double(max(achievements.count, 1))), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .premiumCard()
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let stats: UserStats
    
    var progress: Double {
        switch achievement.type {
        case "streak":
            return min(Double(stats.currentStreak) / Double(achievement.requirement), 1.0)
        case "success":
            return min(Double(stats.totalSuccesses) / Double(achievement.requirement), 1.0)
        case "rate":
            return min(Double(stats.successRate) / Double(achievement.requirement), 1.0)
        default:
            return 0
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? AppStyling.primaryGreen.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? AppStyling.primaryGreen : .gray)
            }
            
            Text(achievement.name)
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if !achievement.isUnlocked {
                ProgressView(value: progress)
                    .tint(AppStyling.primaryGreen)
            } else {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppStyling.primaryGreen)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(achievement.isUnlocked ? Color.white : Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.isUnlocked ? AppStyling.primaryGreen : Color.clear, lineWidth: 2)
        )
    }
}

struct FocusModeRow: View {
    let mode: FocusMode
    
    var body: some View {
        HStack {
            Image(systemName: mode.iconName)
                .foregroundColor(mode.color)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(mode.name)
                    .font(.body)
                if let start = mode.scheduledStartTime, let end = mode.scheduledEndTime {
                    Text("\(start.formatted(date: .omitted, time: .shortened)) - \(end.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(mode.isActive))
                .labelsHidden()
                .tint(AppStyling.primaryGreen)
        }
    }
}
