import DeviceActivity
import ManagedSettings
import Foundation

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // This is called when a monitored app is opened.
        // We apple the shield here.
        applyShield()
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Remove the shield when the activity interval ends.
        removeShield()
    }
    
    private func applyShield() {
        // In a real implementation, we'd get the selection from shared defaults
        // store.shield.applications = ...
        print("Applying shield...")
    }
    
    private func removeShield() {
        store.shield.applications = nil
    }
}
