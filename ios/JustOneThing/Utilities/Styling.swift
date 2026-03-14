import SwiftUI

struct AppStyling {
    static let cornerRadius: CGFloat = 24
    static let primaryGreen = Color(red: 0.34, green: 0.62, blue: 0.41)
    static let backgroundGreen = Color(red: 0.95, green: 0.98, blue: 0.96)
    
    static func hapticHeartbeat() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        // Wait a bit and second beat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let secondGenerator = UIImpactFeedbackGenerator(style: .light)
            secondGenerator.impactOccurred()
        }
    }
}

extension View {
    func zenShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
