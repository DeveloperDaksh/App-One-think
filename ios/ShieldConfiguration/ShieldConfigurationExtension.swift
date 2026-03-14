import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield appearance
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 0.8), // Soft green
            icon: UIImage(systemName: "leaf.fill"),
            title: ShieldConfiguration.Label(text: "Just One Thing", color: .label),
            subtitle: ShieldConfiguration.Label(text: "Take a breath. Is this a conscious choice?", color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Continue Anyway", color: .white),
            primaryButtonBackgroundColor: UIColor.systemGreen.withAlphaComponent(0.5), // Initially faded
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Back to Mindful", color: .systemGreen)
        )
    }
}
