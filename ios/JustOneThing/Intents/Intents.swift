import AppIntents
import SwiftUI

struct StartFocusSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Focus Session"
    static var description = IntentDescription("Starts a new focus session with the Pomodoro timer")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Duration", default: 25)
    var duration: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("Start a \(\.$duration) minute focus session")
    }
    
    func perform() async throws -> some IntentResult {
        AppStyling.hapticMedium()
        
        NotificationCenter.default.post(
            name: .startFocusSession,
            object: nil,
            userInfo: ["duration": duration]
        )
        
        return .result()
    }
}

struct StopFocusSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Focus Session"
    static var description = IntentDescription("Stops the current focus session")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult {
        AppStyling.hapticLight()
        
        NotificationCenter.default.post(
            name: .stopFocusSession,
            object: nil
        )
        
        return .result()
    }
}

struct GetFocusStatsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Focus Stats"
    static var description = IntentDescription("Returns your current focus statistics")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Time Range", default: .today)
    var timeRange: StatsTimeRange
    
    enum StatsTimeRange: String, AppEnum {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        
        static var typeDisplayRepresentation: TypeDisplayRepresentation = "Time Range"
        
        static var caseDisplayRepresentations: [StatsTimeRange: DisplayRepresentation] = [
            .today: "Today",
            .week: "This Week",
            .month: "This Month"
        ]
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let stats = UserDefaults.standard
        
        let successRate = stats.integer(forKey: "successRate")
        let currentStreak = stats.integer(forKey: "currentStreak")
        let totalSessions = stats.integer(forKey: "totalSessions")
        
        let message: String
        switch timeRange {
        case .today:
            message = "Today: \(currentStreak) day streak, \(totalSessions) sessions, \(successRate)% success rate"
        case .week:
            message = "This week: \(currentStreak) day streak, \(totalSessions) sessions, \(successRate)% success rate"
        case .month:
            message = "This month: \(currentStreak) day streak, \(totalSessions) sessions, \(successRate)% success rate"
        }
        
        return .result(value: message)
    }
}

struct StartFocusModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Focus Mode"
    static var description = IntentDescription("Activates a specific focus mode")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Mode")
    var modeName: FocusModeEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("Start \(\.$modeName) focus mode")
    }
    
    func perform() async throws -> some IntentResult {
        AppStyling.hapticMedium()
        
        NotificationCenter.default.post(
            name: .startFocusMode,
            object: nil,
            userInfo: ["mode": modeName.id]
        )
        
        return .result()
    }
}

struct FocusModeEntity: AppEntity {
    var id: String
    var name: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Focus Mode"
    
    static var defaultQuery = FocusModeQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct FocusModeQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [FocusModeEntity] {
        return [
            FocusModeEntity(id: "work", name: "Work"),
            FocusModeEntity(id: "study", name: "Study"),
            FocusModeEntity(id: "sleep", name: "Sleep"),
            FocusModeEntity(id: "deepwork", name: "Deep Work")
        ]
    }
    
    func suggestedEntities() async throws -> [FocusModeEntity] {
        return [
            FocusModeEntity(id: "work", name: "Work"),
            FocusModeEntity(id: "study", name: "Study"),
            FocusModeEntity(id: "sleep", name: "Sleep"),
            FocusModeEntity(id: "deepwork", name: "Deep Work")
        ]
    }
    
    func defaultResult() async -> FocusModeEntity? {
        return FocusModeEntity(id: "work", name: "Work")
    }
}

extension Notification.Name {
    static let startFocusSession = Notification.Name("startFocusSession")
    static let stopFocusSession = Notification.Name("stopFocusSession")
    static let startFocusMode = Notification.Name("startFocusMode")
}

struct JustOneThingShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFocusSessionIntent(),
            phrases: [
                "Start focus session in \(.applicationName)",
                "Start Pomodoro in \(.applicationName)",
                "Begin focusing with \(.applicationName)",
                "Focus time in \(.applicationName)"
            ],
            shortTitle: "Start Focus",
            systemImageName: "play.circle.fill"
        )
        
        AppShortcut(
            intent: StopFocusSessionIntent(),
            phrases: [
                "Stop focus session in \(.applicationName)",
                "End focus in \(.applicationName)",
                "Stop Pomodoro in \(.applicationName)"
            ],
            shortTitle: "Stop Focus",
            systemImageName: "stop.circle.fill"
        )
        
        AppShortcut(
            intent: GetFocusStatsIntent(),
            phrases: [
                "How am I doing in \(.applicationName)",
                "Show my focus stats in \(.applicationName)",
                "Get my focus statistics from \(.applicationName)"
            ],
            shortTitle: "Get Stats",
            systemImageName: "chart.bar.fill"
        )
        
        AppShortcut(
            intent: StartFocusModeIntent(),
            phrases: [
                "Start work mode in \(.applicationName)",
                "Enable study mode in \(.applicationName)",
                "Activate sleep mode in \(.applicationName)"
            ],
            shortTitle: "Start Focus Mode",
            systemImageName: "moon.fill"
        )
    }
}
