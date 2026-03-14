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
    var outcome: String // "SUCCESS" or "CHOICE"
    var intent: String?
    
    init(appBundleId: String, outcome: String, intent: String? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.appBundleId = appBundleId
        self.outcome = outcome
        self.intent = intent
    }
}
