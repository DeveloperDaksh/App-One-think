import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthorizationManager
    
    @State private var breatheScale = 1.0
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .shadow(color: .green.opacity(0.3), radius: 10)
                .scaleEffect(breatheScale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        breatheScale = 1.15
                    }
                }
            
            VStack(spacing: 12) {
                Text("Just One Thing")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Mindful friction for impulsive habits.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                authManager.requestAuthorization()
            }) {
                Text("Enable Screen Time Access")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            
            Text("We don't collect your data. Everything stays on your device.")
                .font(.caption2)
                .foregroundColor(.tertiaryLabel)
                .padding(.bottom, 20)
        }
        .padding()
    }
}
