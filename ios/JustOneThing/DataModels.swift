import Foundation
import SwiftData

@Model
final class BlockedApp {
    @Attribute(.unique) var bundleId: String
    var displayName: String
    var createdAt: Date
    
    init(bundleId: String, displayName: String) {
        self.bundleId = bundleId
        self.displayName = displayName
        self.createdAt = Date()
    }
}

@Model
final class UsageEvent {
    var id: UUID
    var timestamp: Date
    var appBundleId: String
    var appName: String
    var outcome: String
    var intent: String?
    var focusModeId: String?
    
    init(appBundleId: String, appName: String = "", outcome: String, intent: String? = nil, focusModeId: String? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.appBundleId = appBundleId
        self.appName = appName
        self.outcome = outcome
        self.intent = intent
        self.focusModeId = focusModeId
    }
}

@Model
final class UserStats {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalSuccesses: Int = 0
    var totalChoices: Int = 0
    var totalTimeSavedMinutes: Int = 0
    var lastActiveDate: Date?
    var level: Int = 1
    var experiencePoints: Int = 0
    
    var successRate: Int {
        let total = totalSuccesses + totalChoices
        guard total > 0 else { return 0 }
        return Int((Double(totalSuccesses) / Double(total)) * 100)
    }
    
    var levelProgress: Double {
        let xpForNextLevel = level * 100
        return Double(experiencePoints) / Double(xpForNextLevel)
    }
    
    var title: String {
        switch level {
        case 1: return "Beginner"
        case 2...4: return "Apprentice"
        case 5...9: return "Practitioner"
        case 10...19: return "Expert"
        case 20...29: return "Master"
        default: return "Grandmaster"
        }
    }
    
    func addSuccess() {
        totalSuccesses += 1
        experiencePoints += 10
        checkLevelUp()
    }
    
    func addChoice() {
        totalChoices += 1
        experiencePoints += 5
        checkLevelUp()
    }
    
    private func checkLevelUp() {
        let xpRequired = level * 100
        while experiencePoints >= xpRequired {
            experiencePoints -= xpRequired
            level += 1
            AppStyling.hapticSuccess()
        }
    }
    
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastActive = lastActiveDate {
            let lastActiveDay = calendar.startOfDay(for: lastActive)
            let daysDiff = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0
            
            if daysDiff == 1 {
                currentStreak += 1
            } else if daysDiff > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastActiveDate = Date()
    }
}

@Model
final class Achievement {
    var id: String
    var name: String
    var description: String
    var iconName: String
    var isUnlocked: Bool
    var unlockedAt: Date?
    var requirement: Int
    var type: String
    
    init(id: String, name: String, description: String, iconName: String, requirement: Int, type: String) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.isUnlocked = false
        self.unlockedAt = nil
        self.requirement = requirement
        self.type = type
    }
    
    static func createDefaultAchievements() -> [Achievement] {
        [
            Achievement(id: "streak_3", name: "Getting Started", description: "Maintain a 3-day streak", iconName: "flame", requirement: 3, type: "streak"),
            Achievement(id: "streak_7", name: "Week Warrior", description: "Maintain a 7-day streak", iconName: "flame.fill", requirement: 7, type: "streak"),
            Achievement(id: "streak_30", name: "Monthly Master", description: "Maintain a 30-day streak", iconName: "crown.fill", requirement: 30, type: "streak"),
            Achievement(id: "success_10", name: "First Win", description: "Achieve 10 focus successes", iconName: "star", requirement: 10, type: "success"),
            Achievement(id: "success_50", name: "Consistent", description: "Achieve 50 focus successes", iconName: "star.fill", requirement: 50, type: "success"),
            Achievement(id: "success_100", name: "Unstoppable", description: "Achieve 100 focus successes", iconName: "sparkles", requirement: 100, type: "success"),
            Achievement(id: "rate_70", name: "70% Club", description: "Reach 70% success rate", iconName: "chart.pie.fill", requirement: 70, type: "rate"),
            Achievement(id: "rate_90", name: "Zen Master", description: "Reach 90% success rate", iconName: "brain.head.profile", requirement: 90, type: "rate")
        ]
    }
}

@Model
final class FocusMode {
    var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var isActive: Bool
    var scheduledStartTime: Date?
    var scheduledEndTime: Date?
    var daysOfWeek: [Int]
    var createdAt: Date
    
    init(name: String, iconName: String, colorHex: String, scheduledStartTime: Date? = nil, scheduledEndTime: Date? = nil, daysOfWeek: [Int] = []) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isActive = false
        self.scheduledStartTime = scheduledStartTime
        self.scheduledEndTime = scheduledEndTime
        self.daysOfWeek = daysOfWeek
        self.createdAt = Date()
    }
    
    var color: Color {
        Color(hex: colorHex) ?? AppStyling.primaryGreen
    }
}

@Model
final class DailyChallenge {
    var id: UUID
    var date: Date
    var type: String
    var target: Int
    var progress: Int
    var isCompleted: Bool
    var reward: Int
    
    init(type: String, target: Int, reward: Int) {
        self.id = UUID()
        self.date = Date()
        self.type = type
        self.target = target
        self.progress = 0
        self.isCompleted = false
        self.reward = reward
    }
    
    var progressPercentage: Double {
        guard target > 0 else { return 0 }
        return min(Double(progress) / Double(target), 1.0)
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

@Model
final class PomodoroSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var duration: Int
    var type: String
    var isCompleted: Bool
    var focusModeId: String?
    var blockedAppsAttempted: Int
    
    init(duration: Int, type: String) {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = nil
        self.duration = duration
        self.type = type
        self.isCompleted = false
        self.focusModeId = nil
        self.blockedAppsAttempted = 0
    }
    
    func complete() {
        self.endTime = Date()
        self.isCompleted = true
    }
}

@Model
final class TimerSettings {
    var workDuration: Int = 25
    var shortBreakDuration: Int = 5
    var longBreakDuration: Int = 15
    var sessionsBeforeLongBreak: Int = 4
    var autoStartBreaks: Bool = true
    var autoStartWork: Bool = false
    var soundEnabled: Bool = true
    var vibrationEnabled: Bool = true
    
    static let `default` = TimerSettings()
}

@Model
final class DailyGoal {
    var id: UUID
    var date: Date
    var focusMinutesTarget: Int
    var sessionsTarget: Int
    var successRateTarget: Int
    var focusMinutesAchieved: Int
    var sessionsCompleted: Int
    
    init(focusMinutesTarget: Int = 120, sessionsTarget: Int = 4, successRateTarget: Int = 70) {
        self.id = UUID()
        self.date = Date()
        self.focusMinutesTarget = focusMinutesTarget
        self.sessionsTarget = sessionsTarget
        self.successRateTarget = successRateTarget
        self.focusMinutesAchieved = 0
        self.sessionsCompleted = 0
    }
    
    var focusProgress: Double {
        guard focusMinutesTarget > 0 else { return 0 }
        return min(Double(focusMinutesAchieved) / Double(focusMinutesTarget), 1.0)
    }
    
    var sessionsProgress: Double {
        guard sessionsTarget > 0 else { return 0 }
        return min(Double(sessionsCompleted) / Double(sessionsTarget), 1.0)
    }
}

@Model
final class WeeklyGoal {
    var id: UUID
    var weekStartDate: Date
    var focusMinutesTarget: Int
    var sessionsTarget: Int
    var streakTarget: Int
    var focusMinutesAchieved: Int
    var sessionsCompleted: Int
    
    init(focusMinutesTarget: Int = 600, sessionsTarget: Int = 20, streakTarget: Int = 7) {
        self.id = UUID()
        self.weekStartDate = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        self.focusMinutesTarget = focusMinutesTarget
        self.sessionsTarget = sessionsTarget
        self.streakTarget = streakTarget
        self.focusMinutesAchieved = 0
        self.sessionsCompleted = 0
    }
    
    var progress: Double {
        guard focusMinutesTarget > 0 else { return 0 }
        return min(Double(focusMinutesAchieved) / Double(focusMinutesTarget), 1.0)
    }
}

enum UnlockChallengeType: String, CaseIterable {
    case wait30 = "wait_30"
    case wait60 = "wait_60"
    case wait120 = "wait_120"
    case typePhrase = "type_phrase"
    case mathProblem = "math"
    
    var displayName: String {
        switch self {
        case .wait30: return "Wait 30 seconds"
        case .wait60: return "Wait 1 minute"
        case .wait120: return "Wait 2 minutes"
        case .typePhrase: return "Type a phrase"
        case .mathProblem: return "Solve a math problem"
        }
    }
    
    var iconName: String {
        switch self {
        case .wait30, .wait60, .wait120: return "clock.fill"
        case .typePhrase: return "keyboard.fill"
        case .mathProblem: return "plusminus.circle.fill"
        }
    }
    
    var waitSeconds: Int {
        switch self {
        case .wait30: return 30
        case .wait60: return 60
        case .wait120: return 120
        default: return 0
        }
    }
}
