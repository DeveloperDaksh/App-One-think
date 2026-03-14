import SwiftUI
import ManagedSettings

struct CustomShieldView: View {
    @State private var interventionState: InterventionState = .breathing
    @State private var breathCount = 0
    @State private var holdProgress: Double = 0
    @State private var timer: Timer? = nil
    
    enum InterventionState {
        case breathing, steadyHand, journaling, intentSelection
    }
    
    var body: some View {
        VStack(spacing: 40) {
            switch interventionState {
            case .breathing:
                BreathingView(count: breathCount)
                    .onAppear { startBreathing() }
                
            case .steadyHand:
                SteadyHandView {
                    withAnimation { interventionState = .journaling }
                }
                
            case .journaling:
                JournalPromptView(text: $journalText) {
                    withAnimation { interventionState = .intentSelection }
                }
                
            case .intentSelection:
                IntentSelectionView(selectedIntent: $selectedIntent)
            }
            
            ActionButtons(state: interventionState, selectedIntent: selectedIntent)
        }
    }
    
    private func startBreathing() {
        Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { timer in
            breathCount += 1
            if breathCount >= 2 {
                timer.invalidate()
                withAnimation { interventionState = .physicalFriction }
            }
        }
    }
                
                Button(action: {
                    // Logic to go back and record success
                    goBack()
                }) {
                    Text("Read Instead")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(32)
        .shadow(radius: 20)
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                withAnimation {
                    showIntents = true
                }
            }
        }
    }
    
    private func dismissShield() {
        // Logic to communicate with ManagedSettingsStore and record event
    }
    
    private func goBack() {
        // Open the 'Alternative App' or go to Home
    }
}
