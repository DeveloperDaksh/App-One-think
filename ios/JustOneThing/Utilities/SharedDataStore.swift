import Foundation
import SwiftData

@MainActor
class SharedDataStore: ObservableObject {
    static let shared = SharedDataStore()
    
    @Published var isLoading = false
    
    private init() {}
    
    let appGroup = "group.com.yourapp.justonething"
    private var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }
    
    func recordEvent(appBundleId: String, outcome: String, intent: String?) {
        let event: [String: Any] = [
            "timestamp": Date(),
            "app": appBundleId,
            "outcome": outcome,
            "intent": intent as Any
        ]
        
        var history = defaults?.array(forKey: "pending_events") as? [[String: Any]] ?? []
        history.append(event)
        defaults?.set(history, forKey: "pending_events")
        
        print("Event recorded: \(outcome) for \(appBundleId)")
    }
    
    func initializeDefaultFocusModes(context: ModelContext) {
        let descriptor = FetchDescriptor<FocusMode>()
        let existingModes = (try? context.fetch(descriptor)) ?? []
        
        guard existingModes.isEmpty else { return }
        
        let defaultModes = [
            FocusMode(name: "Work", iconName: "briefcase.fill", colorHex: "#4A90D9", scheduledStartTime: createTime(hour: 9, minute: 0), scheduledEndTime: createTime(hour: 17, minute: 0), daysOfWeek: [2, 3, 4, 5, 6]),
            FocusMode(name: "Study", iconName: "book.fill", colorHex: "#9B59B6", scheduledStartTime: createTime(hour: 18, minute: 0), scheduledEndTime: createTime(hour: 22, minute: 0), daysOfWeek: [1, 2, 3, 4, 5, 6, 7]),
            FocusMode(name: "Sleep", iconName: "moon.fill", colorHex: "#2C3E50", scheduledStartTime: createTime(hour: 22, minute: 0), scheduledEndTime: createTime(hour: 7, minute: 0), daysOfWeek: [1, 2, 3, 4, 5, 6, 7]),
            FocusMode(name: "Deep Work", iconName: "brain.head.profile", colorHex: "#E74C3C", scheduledStartTime: nil, scheduledEndTime: nil, daysOfWeek: [])
        ]
        
        for mode in defaultModes {
            context.insert(mode)
        }
        
        try? context.save()
    }
    
    func initializeAchievements(context: ModelContext) {
        let descriptor = FetchDescriptor<Achievement>()
        let existingAchievements = (try? context.fetch(descriptor)) ?? []
        
        guard existingAchievements.isEmpty else { return }
        
        let achievements = Achievement.createDefaultAchievements()
        
        for achievement in achievements {
            context.insert(achievement)
        }
        
        try? context.save()
    }
    
    func initializeUserStats(context: ModelContext) {
        let descriptor = FetchDescriptor<UserStats>()
        let existingStats = (try? context.fetch(descriptor)) ?? []
        
        guard existingStats.isEmpty else { return }
        
        let stats = UserStats()
        context.insert(stats)
        try? context.save()
    }
    
    private func createTime(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func checkAchievements(stats: UserStats, achievements: [Achievement], context: ModelContext) {
        for achievement in achievements where !achievement.isUnlocked {
            var shouldUnlock = false
            
            switch achievement.type {
            case "streak":
                shouldUnlock = stats.currentStreak >= achievement.requirement
            case "success":
                shouldUnlock = stats.totalSuccesses >= achievement.requirement
            case "rate":
                shouldUnlock = stats.successRate >= achievement.requirement
            default:
                break
            }
            
            if shouldUnlock {
                achievement.isUnlocked = true
                achievement.unlockedAt = Date()
                AppStyling.hapticSuccess()
            }
        }
        
        try? context.save()
    }
    
    func initializeTimerSettings(context: ModelContext) {
        let descriptor = FetchDescriptor<TimerSettings>()
        let existingSettings = (try? context.fetch(descriptor)) ?? []
        
        guard existingSettings.isEmpty else { return }
        
        let settings = TimerSettings.default
        context.insert(settings)
        try? context.save()
    }
    
    func initializeDailyGoal(context: ModelContext) {
        let descriptor = FetchDescriptor<DailyGoal>()
        let calendar = Calendar.current
        let existingGoals = (try? context.fetch(descriptor)) ?? []
        let today = calendar.startOfDay(for: Date())
        
        let todayGoal = existingGoals.first { calendar.isDate($0.date, inSameDayAs: today) }
        
        if todayGoal == nil {
            let newGoal = DailyGoal()
            context.insert(newGoal)
            try? context.save()
        }
    }
}
