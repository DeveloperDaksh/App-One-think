import Foundation
import SwiftData

/// Shared storage utility to bridge the App and its Extensions.
/// This requires a Shared App Group in Xcode.
class SharedDataStore {
    static let shared = SharedDataStore()
    
    // The App Group ID defined in Apple Developer Portal
    let appGroup = "group.com.yourapp.justonething"
    
    // Simple way to share basic settings via UserDefaults
    private let defaults: UserDefaults?
    
    init() {
        self.defaults = UserDefaults(suiteName: appGroup)
    }
    
    func recordEvent(appBundleId: String, outcome: String, intent: String?) {
        // In a full implementation, we'd use a shared SwiftData container.
        // For now, we'll log it for the app to pick up later.
        let event = [
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
}
