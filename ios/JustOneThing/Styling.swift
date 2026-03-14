import SwiftUI

struct AppStyling {
    static let cornerRadius: CGFloat = 24
    static let primaryGreen = Color(red: 0.34, green: 0.62, blue: 0.41)
    static let backgroundGreen = Color(red: 0.95, green: 0.98, blue: 0.96)
    
    static let premiumGradient = LinearGradient(
        colors: [Color(red: 0.34, green: 0.62, blue: 0.41), Color(red: 0.18, green: 0.80, blue: 0.44)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let successGradient = LinearGradient(
        colors: [Color(red: 0.13, green: 0.77, blue: 0.44), Color(red: 0.0, green: 0.65, blue: 0.38)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warningGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.60, blue: 0.0), Color(red: 0.95, green: 0.45, blue: 0.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassBackground = Color.white.opacity(0.25)
    static let glassBorder = Color.white.opacity(0.5)
    
    static func hapticLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func hapticMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func hapticHeavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func hapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    static func hapticWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    static func hapticHeartbeat() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
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
    
    func glassCard() -> some View {
        self
            .background(.ultraThinMaterial)
            .background(AppStyling.glassBackground)
            .cornerRadius(AppStyling.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyling.cornerRadius)
                    .stroke(AppStyling.glassBorder, lineWidth: 1)
            )
    }
    
    func premiumCard() -> some View {
        self
            .background(AppStyling.cardGradient)
            .cornerRadius(AppStyling.cornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    func scaleOnPress() -> some View {
        self.buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct AnimatedCheckmark: View {
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(AppStyling.successGradient)
            .scaleEffect(isAnimating ? 1.2 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnimating)
            .onAppear {
                isAnimating = true
                AppStyling.hapticSuccess()
            }
    }
}

struct AnimatedXmark: View {
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .foregroundStyle(AppStyling.warningGradient)
            .scaleEffect(isAnimating ? 1.2 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnimating)
            .onAppear {
                isAnimating = true
                AppStyling.hapticWarning()
            }
    }
}
