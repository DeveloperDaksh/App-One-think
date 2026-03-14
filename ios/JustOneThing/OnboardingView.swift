import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthorizationManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var currentPage = 0
    @State private var breatheScale = 1.0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPage(
                    icon: "leaf.fill",
                    title: "Welcome to Just One Thing",
                    description: "Your personal mindfulness companion for building healthier digital habits.",
                    color: .green
                )
                .tag(0)
                
                OnboardingPage(
                    icon: "hand.raised.fill",
                    title: "Mindful Friction",
                    description: "When you reach for a distracting app, we'll gently pause and ask: 'Is this the one thing you want to do right now?'",
                    color: .orange
                )
                .tag(1)
                
                OnboardingPage(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Your Progress",
                    description: "Watch your focus score improve over time with detailed analytics and streak tracking.",
                    color: .blue
                )
                .tag(2)
                
                OnboardingPage(
                    icon: "trophy.fill",
                    title: "Earn Achievements",
                    description: "Level up and unlock achievements as you build consistent focus habits.",
                    color: .purple
                )
                .tag(3)
                
                OnboardingPage(
                    icon: "lock.shield.fill",
                    title: "Your Privacy Matters",
                    description: "All data stays on your device. We never collect or share your personal information.",
                    color: .green
                )
                .tag(4)
                
                authorizationPage
                    .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            VStack(spacing: 20) {
                if currentPage < 5 {
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? AppStyling.primaryGreen : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    HStack {
                        Button("Skip") {
                            withAnimation {
                                currentPage = 5
                            }
                            AppStyling.hapticLight()
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                            AppStyling.hapticLight()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(AppStyling.primaryGreen)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
    
    private var authorizationPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppStyling.primaryGreen.opacity(0.15))
                    .frame(width: 150, height: 150)
                
                Image(systemName: "hourglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(AppStyling.primaryGreen)
                    .rotationEffect(.degrees(currentPage == 5 ? 360 : 0))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: currentPage == 5)
            }
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    _ = currentPage
                }
            }
            
            VStack(spacing: 12) {
                Text("Enable Screen Time")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("We need Screen Time access to help you block distracting apps and track your focus.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    authManager.requestAuthorization()
                    AppStyling.hapticMedium()
                }) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                        Text("Enable Screen Time Access")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyling.premiumGradient)
                    .cornerRadius(16)
                    .shadow(color: AppStyling.primaryGreen.opacity(0.4), radius: 10, y: 5)
                }
                .scaleOnPress()
                
                Text("You can change this anytime in Settings")
                    .font(.caption)
                    .foregroundColor(.tertiaryLabel)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                Text("Your data never leaves your device")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 20)
        }
        .tag(5)
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    @State private var breatheScale = 1.0
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .scaleEffect(breatheScale)
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    breatheScale = 1.1
                }
            }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
        }
    }
}

struct OnboardingPage_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AuthorizationManager.shared)
    }
}
