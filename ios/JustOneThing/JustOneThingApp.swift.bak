import SwiftUI
import SwiftData
import FamilyControls

@main
struct JustOneThingApp: App {
    @StateObject var authManager = AuthorizationManager.shared
    @Environment(\.modelContext) private var modelContext
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BlockedApp.self,
            UsageEvent.self,
            UserStats.self,
            Achievement.self,
            FocusMode.self,
            DailyChallenge.self,
            PomodoroSession.self,
            TimerSettings.self,
            DailyGoal.self,
            WeeklyGoal.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        initializeData()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthorized {
                MainDashboardView()
                    .environmentObject(authManager)
            } else {
                OnboardingView()
                    .environmentObject(authManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func initializeData() {
        Task { @MainActor in
            let context = sharedModelContainer.mainContext
            
            SharedDataStore.shared.initializeUserStats(context: context)
            SharedDataStore.shared.initializeDefaultFocusModes(context: context)
            SharedDataStore.shared.initializeAchievements(context: context)
            SharedDataStore.shared.initializeTimerSettings(context: context)
            SharedDataStore.shared.initializeDailyGoal(context: context)
        }
    }
}

class AuthorizationManager: ObservableObject {
    static let shared = AuthorizationManager()
    
    @Published var isAuthorized: Bool = false
    
    private let center = AuthorizationCenter.shared
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                DispatchQueue.main.async {
                    self.isAuthorized = true
                    AppStyling.hapticSuccess()
                }
            } catch {
                print("Failed to authorize: \(error.localizedDescription)")
                AppStyling.hapticWarning()
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        Task {
            let status = center.authorizationStatus
            DispatchQueue.main.async {
                switch status {
                case .approved:
                    self.isAuthorized = true
                default:
                    self.isAuthorized = false
                }
            }
        }
    }
}
