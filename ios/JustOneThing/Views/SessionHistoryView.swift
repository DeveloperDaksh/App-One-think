import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Query(sort: \PomodoroSession.startTime, order: .reverse) private var sessions: [PomodoroSession]
    @Query private var dailyGoals: [DailyGoal]
    
    @State private var selectedFilter: SessionFilter = .all
    
    enum SessionFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case week = "This Week"
    }
    
    var filteredSessions: [PomodoroSession] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .all:
            return sessions
        case .today:
            return sessions.filter { calendar.isDate($0.startTime, inSameDayAs: now) }
        case .week:
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return sessions }
            return sessions.filter { $0.startTime > weekAgo }
        }
    }
    
    var todayGoal: DailyGoal? {
        let calendar = Calendar.current
        return dailyGoals.first { calendar.isDate($0.date, inSameDayAs: Date()) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                filterPicker
                
                summaryCards
                
                sessionList
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Session History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(SessionFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var summaryCards: some View {
        let completedCount = filteredSessions.filter { $0.isCompleted }.count
        let totalMinutes = filteredSessions.filter { $0.isCompleted }.reduce(0) { $0 + $1.duration }
        
        return HStack(spacing: 16) {
            SummaryCard(
                title: "Sessions",
                value: "\(completedCount)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            SummaryCard(
                title: "Minutes",
                value: "\(totalMinutes)",
                icon: "clock.fill",
                color: .blue
            )
            
            SummaryCard(
                title: "Streak",
                value: "\(todayGoal?.sessionsCompleted ?? 0)",
                icon: "flame.fill",
                color: .orange
            )
        }
    }
    
    private var sessionList: some View {
        Group {
            if filteredSessions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Sessions Yet")
                        .font(.headline)
                    
                    Text("Start a focus session to see your history here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredSessions) { session in
                            SessionRow(session: session)
                        }
                    }
                }
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct SessionRow: View {
    let session: PomodoroSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.type.capitalized)
                        .font(.headline)
                    
                    if session.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
                
                Text(session.startTime, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(session.startTime, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.duration) min")
                    .font(.headline)
                
                if session.blockedAppsAttempted > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "app.badge.fill")
                            .font(.caption2)
                        Text("\(session.blockedAppsAttempted)")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SessionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SessionHistoryView()
    }
}
