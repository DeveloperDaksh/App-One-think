import SwiftUI
import FamilyControls

@main
struct JustOneThingApp: App {
    @StateObject var authManager = AuthorizationManager.shared
    
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
    }
}

/// Manages the FamilyControls authorization state.
class AuthorizationManager: ObservableObject {
    static let shared = AuthorizationManager()
    
    @Published var isAuthorized: Bool = false
    
    private let center = AuthorizationCenter.shared
    
    init() {
        // In a real app, we'd check current status
        updateStatus()
    }
    
    func requestAuthorization() {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                DispatchQueue.main.async {
                    self.isAuthorized = true
                }
            } catch {
                print("Failed to authorize: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateStatus() {
        // Simple check for MVP
        // In production, use center.authorizationStatus
    }
}
