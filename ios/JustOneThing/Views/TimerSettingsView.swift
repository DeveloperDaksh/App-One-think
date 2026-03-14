import SwiftUI
import SwiftData

struct TimerSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timerSettings: [TimerSettings]
    
    @State private var workDuration: Double = 25
    @State private var shortBreakDuration: Double = 5
    @State private var longBreakDuration: Double = 15
    @State private var sessionsBeforeLongBreak: Double = 4
    @State private var autoStartBreaks: Bool = true
    @State private var autoStartWork: Bool = false
    @State private var soundEnabled: Bool = true
    @State private var vibrationEnabled: Bool = true
    
    private var settings: TimerSettings? {
        timerSettings.first
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Focus Session") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Focus Duration")
                            Spacer()
                            Text("\(Int(workDuration)) min")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $workDuration, in: 5...60, step: 5) {
                            Text("Focus Duration")
                        }
                        .tint(AppStyling.primaryGreen)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Sessions Before Long Break")
                            Spacer()
                            Text("\(Int(sessionsBeforeLongBreak))")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $sessionsBeforeLongBreak, in: 2...8, step: 1) {
                            Text("Sessions")
                        }
                        .tint(AppStyling.primaryGreen)
                    }
                }
                
                Section("Breaks") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Short Break")
                            Spacer()
                            Text("\(Int(shortBreakDuration)) min")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $shortBreakDuration, in: 1...15, step: 1) {
                            Text("Short Break")
                        }
                        .tint(.blue)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Long Break")
                            Spacer()
                            Text("\(Int(longBreakDuration)) min")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $longBreakDuration, in: 10...30, step: 5) {
                            Text("Long Break")
                        }
                        .tint(.purple)
                    }
                }
                
                Section("Automation") {
                    Toggle("Auto-start Breaks", isOn: $autoStartBreaks)
                        .tint(AppStyling.primaryGreen)
                    
                    Toggle("Auto-start Focus", isOn: $autoStartWork)
                        .tint(AppStyling.primaryGreen)
                }
                
                Section("Notifications") {
                    Toggle("Sound", isOn: $soundEnabled)
                        .tint(AppStyling.primaryGreen)
                    
                    Toggle("Vibration", isOn: $vibrationEnabled)
                        .tint(AppStyling.primaryGreen)
                }
                
                Section {
                    Button("Reset to Defaults") {
                        resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Timer Settings")
            .onAppear {
                loadSettings()
            }
            .onChange(of: workDuration) { _, _ in saveSettings() }
            .onChange(of: shortBreakDuration) { _, _ in saveSettings() }
            .onChange(of: longBreakDuration) { _, _ in saveSettings() }
            .onChange(of: sessionsBeforeLongBreak) { _, _ in saveSettings() }
            .onChange(of: autoStartBreaks) { _, _ in saveSettings() }
            .onChange(of: autoStartWork) { _, _ in saveSettings() }
            .onChange(of: soundEnabled) { _, _ in saveSettings() }
            .onChange(of: vibrationEnabled) { _, _ in saveSettings() }
        }
    }
    
    private func loadSettings() {
        guard let settings = settings else { return }
        workDuration = Double(settings.workDuration)
        shortBreakDuration = Double(settings.shortBreakDuration)
        longBreakDuration = Double(settings.longBreakDuration)
        sessionsBeforeLongBreak = Double(settings.sessionsBeforeLongBreak)
        autoStartBreaks = settings.autoStartBreaks
        autoStartWork = settings.autoStartWork
        soundEnabled = settings.soundEnabled
        vibrationEnabled = settings.vibrationEnabled
    }
    
    private func saveSettings() {
        guard let settings = settings else { return }
        
        settings.workDuration = Int(workDuration)
        settings.shortBreakDuration = Int(shortBreakDuration)
        settings.longBreakDuration = Int(longBreakDuration)
        settings.sessionsBeforeLongBreak = Int(sessionsBeforeLongBreak)
        settings.autoStartBreaks = autoStartBreaks
        settings.autoStartWork = autoStartWork
        settings.soundEnabled = soundEnabled
        settings.vibrationEnabled = vibrationEnabled
        
        try? modelContext.save()
        AppStyling.hapticLight()
    }
    
    private func resetToDefaults() {
        let defaults = TimerSettings.default
        workDuration = Double(defaults.workDuration)
        shortBreakDuration = Double(defaults.shortBreakDuration)
        longBreakDuration = Double(defaults.longBreakDuration)
        sessionsBeforeLongBreak = Double(defaults.sessionsBeforeLongBreak)
        autoStartBreaks = defaults.autoStartBreaks
        autoStartWork = defaults.autoStartWork
        soundEnabled = defaults.soundEnabled
        vibrationEnabled = defaults.vibrationEnabled
        
        saveSettings()
        AppStyling.hapticSuccess()
    }
}

struct TimerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TimerSettingsView()
    }
}
