import SwiftUI
import SwiftData

struct PomodoroTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timerSettings: [TimerSettings]
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var userStats: [UserStats]
    @Query private var dailyGoals: [DailyGoal]
    
    @State private var timer: Timer?
    @State private var remainingSeconds: Int = 0
    @State private var isRunning = false
    @State private var currentSessionType: SessionType = .work
    @State private var completedSessions = 0
    @State private var showChallenge = false
    @State private var challengeType: UnlockChallengeType = .wait30
    @State private var challengeSecondsRemaining = 0
    @State private var isInChallenge = false
    @State private var typedPhrase = ""
    @State private var correctPhrase = "focus"
    @State private var mathAnswer = 0
    @State private var mathProblem = (Int.random(in: 10...50), Int.random(in: 1...10))
    @State private var userMathAnswer = ""
    @State private var showMathError = false
    
    enum SessionType: String {
        case work = "Focus"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"
    }
    
    private var settings: TimerSettings {
        timerSettings.first ?? TimerSettings.default
    }
    
    private var stats: UserStats? {
        userStats.first
    }
    
    private var todayGoal: DailyGoal? {
        let calendar = Calendar.current
        return dailyGoals.first { calendar.isDate($0.date, inSameDayAs: Date()) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    sessionTypePicker
                    
                    timerDisplay
                    
                    if isRunning || remainingSeconds > 0 {
                        progressRing
                    }
                    
                    controlButtons
                    
                    sessionStats
                    
                    Spacer()
                }
                .padding()
                
                if showChallenge {
                    challengeOverlay
                }
            }
            .navigationTitle("Focus Timer")
            .onAppear {
                resetTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: sessionGradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .opacity(0.9)
    }
    
    private var sessionGradientColors: [Color] {
        switch currentSessionType {
        case .work:
            return [AppStyling.primaryGreen, Color(red: 0.18, green: 0.80, blue: 0.44)]
        case .shortBreak:
            return [Color.blue, Color(red: 0.4, green: 0.6, blue: 1.0)]
        case .longBreak:
            return [Color.purple, Color(red: 0.6, green: 0.4, blue: 0.8)]
        }
    }
    
    private var sessionTypePicker: some View {
        HStack(spacing: 12) {
            ForEach([SessionType.work, .shortBreak, .longBreak], id: \.self) { type in
                Button {
                    if !isRunning {
                        currentSessionType = type
                        resetTimer()
                        AppStyling.hapticLight()
                    }
                } label: {
                    Text(type.rawValue)
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(currentSessionType == type ? Color.white.opacity(0.3) : Color.clear)
                        .cornerRadius(20)
                }
                .disabled(isRunning)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.2))
        .cornerRadius(24)
    }
    
    private var timerDisplay: some View {
        Text(formatTime(remainingSeconds))
            .font(.system(size: 72, weight: .thin, design: .rounded))
            .foregroundColor(.white)
            .monospacedDigit()
    }
    
    private var progressRing: some View {
        let totalSeconds = currentSessionDuration
        let progress = Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
        
        return ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 8)
                .frame(width: 250, height: 250)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 30) {
            if isRunning {
                Button {
                    pauseTimer()
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Circle())
                }
            } else {
                Button {
                    startTimer()
                } label: {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            
            Button {
                resetTimer()
                AppStyling.hapticLight()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
    }
    
    private var sessionStats: some View {
        VStack(spacing: 16) {
            HStack {
                StatBox(title: "Today", value: "\(todayGoal?.sessionsCompleted ?? 0)", subtitle: "/ \(todayGoal?.sessionsTarget ?? 4) sessions")
                Spacer()
                StatBox(title: "Minutes", value: "\(todayGoal?.focusMinutesAchieved ?? 0)", subtitle: "/ \(todayGoal?.focusMinutesTarget ?? 120)m")
                Spacer()
                StatBox(title: "Streak", value: "\(stats?.currentStreak ?? 0)", subtitle: "days")
            }
            .foregroundColor(.white)
            
            if let goal = todayGoal {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Goal Progress")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    ProgressView(value: goal.focusProgress)
                        .tint(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
    }
    
    private var challengeOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: challengeType.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text(challengeType.displayName)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                if challengeType == .wait30 || challengeType == .wait60 || challengeType == .wait120 {
                    Text("\(challengeSecondsRemaining)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .monospacedDigit()
                } else if challengeType == .typePhrase {
                    VStack(spacing: 16) {
                        Text("Type: \"\(correctPhrase)\"")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Type here...", text: $typedPhrase)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .onSubmit {
                                checkTypeChallenge()
                            }
                        
                        Button("Submit") {
                            checkTypeChallenge()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding()
                } else if challengeType == .mathProblem {
                    VStack(spacing: 16) {
                        Text("\(mathProblem.0) + \(mathProblem.1) = ?")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        TextField("Answer", text: $userMathAnswer)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .padding(.horizontal)
                            .onSubmit {
                                checkMathChallenge()
                            }
                        
                        if showMathError {
                            Text("Try again!")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Button("Submit") {
                            checkMathChallenge()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding()
                }
                
                Button("Skip Challenge") {
                    showChallenge = false
                    isInChallenge = false
                    AppStyling.hapticWarning()
                }
                .foregroundColor(.secondary)
            }
            .padding(30)
            .background(Color(.systemBackground))
            .cornerRadius(24)
        }
    }
    
    private var currentSessionDuration: Int {
        switch currentSessionType {
        case .work:
            return settings.workDuration * 60
        case .shortBreak:
            return settings.shortBreakDuration * 60
        case .longBreak:
            return settings.longBreakDuration * 60
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    private func startTimer() {
        isRunning = true
        AppStyling.hapticMedium()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                completeSession()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        AppStyling.hapticLight()
    }
    
    private func resetTimer() {
        isRunning = false
        timer?.invalidate()
        remainingSeconds = currentSessionDuration
    }
    
    private func completeSession() {
        timer?.invalidate()
        isRunning = false
        AppStyling.hapticSuccess()
        
        if currentSessionType == .work {
            let session = PomodoroSession(duration: settings.workDuration, type: "work")
            session.complete()
            modelContext.insert(session)
            
            completedSessions += 1
            
            if let stats = stats {
                stats.addSuccess()
                stats.updateStreak()
            }
            
            if let goal = todayGoal {
                goal.sessionsCompleted += 1
                goal.focusMinutesAchieved += settings.workDuration
            }
            
            try? modelContext.save()
            
            showChallenge = true
            presentRandomChallenge()
        } else {
            currentSessionType = .work
            remainingSeconds = settings.workDuration * 60
        }
    }
    
    private func presentRandomChallenge() {
        let challenges: [UnlockChallengeType] = [.wait30, .wait60, .wait120, .typePhrase, .mathProblem]
        challengeType = challenges.randomElement() ?? .wait30
        
        if challengeType.waitSeconds > 0 {
            challengeSecondsRemaining = challengeType.waitSeconds
            startChallengeTimer()
        } else if challengeType == .typePhrase {
            correctPhrase = ["focus", "mindful", "present", "calm", "peace"].randomElement() ?? "focus"
            typedPhrase = ""
        } else if challengeType == .mathProblem {
            mathProblem = (Int.random(in: 10...50), Int.random(in: 1...10))
            mathAnswer = mathProblem.0 + mathProblem.1
            userMathAnswer = ""
            showMathError = false
        }
        
        isInChallenge = true
    }
    
    private func startChallengeTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if challengeSecondsRemaining > 0 {
                challengeSecondsRemaining -= 1
            } else {
                completeChallenge()
            }
        }
    }
    
    private func completeChallenge() {
        timer?.invalidate()
        showChallenge = false
        isInChallenge = false
        
        if completedSessions >= settings.sessionsBeforeLongBreak {
            currentSessionType = .longBreak
            remainingSeconds = settings.longBreakDuration * 60
            completedSessions = 0
        } else {
            currentSessionType = .shortBreak
            remainingSeconds = settings.shortBreakDuration * 60
        }
        
        AppStyling.hapticSuccess()
    }
    
    private func checkTypeChallenge() {
        if typedPhrase.lowercased() == correctPhrase.lowercased() {
            completeChallenge()
        } else {
            AppStyling.hapticWarning()
            typedPhrase = ""
        }
    }
    
    private func checkMathChallenge() {
        if let answer = Int(userMathAnswer), answer == mathAnswer {
            completeChallenge()
        } else {
            showMathError = true
            AppStyling.hapticWarning()
            userMathAnswer = ""
            mathProblem = (Int.random(in: 10...50), Int.random(in: 1...10))
            mathAnswer = mathProblem.0 + mathProblem.1
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(subtitle)
                .font(.caption2)
            Text(title)
                .font(.caption2)
                .opacity(0.8)
        }
    }
}

struct PomodoroTimerView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroTimerView()
    }
}
