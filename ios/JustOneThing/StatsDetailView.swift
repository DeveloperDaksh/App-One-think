import SwiftUI
import SwiftData
import Charts

struct StatsDetailView: View {
    @Query(sort: \UsageEvent.timestamp, order: .reverse) private var events: [UsageEvent]
    @Query private var userStats: [UserStats]
    
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var stats: UserStats? {
        userStats.first
    }
    
    var filteredEvents: [UsageEvent] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .week:
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return events }
            return events.filter { $0.timestamp > weekAgo }
        case .month:
            guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return events }
            return events.filter { $0.timestamp > monthAgo }
        case .year:
            guard let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return events }
            return events.filter { $0.timestamp > yearAgo }
        }
    }
    
    var successCount: Int {
        filteredEvents.filter { $0.outcome == "SUCCESS" }.count
    }
    
    var choiceCount: Int {
        filteredEvents.filter { $0.outcome == "CHOICE" }.count
    }
    
    var successRate: Int {
        let total = successCount + choiceCount
        guard total > 0 else { return 0 }
        return Int((Double(successCount) / Double(total)) * 100)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                timeRangePicker
                
                summaryCard
                
                outcomeChart
                
                dailyBreakdown
                
                if !events.isEmpty {
                    appBreakdown
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var summaryCard: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Success Rate")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(successRate)%")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyling.premiumGradient)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(successRate) / 100)
                        .stroke(AppStyling.premiumGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(successRate)")
                        .font(.headline.bold())
                }
            }
            
            Divider()
            
            HStack {
                StatBox(title: "Focus Wins", value: "\(successCount)", icon: "checkmark.circle.fill", color: .green)
                Spacer()
                StatBox(title: "Choices", value: "\(choiceCount)", icon: "hand.raised.fill", color: .orange)
                Spacer()
                StatBox(title: "Total", value: "\(filteredEvents.count)", icon: "sum", color: .blue)
            }
        }
        .padding()
        .premiumCard()
    }
    
    private var outcomeChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Focus vs Choice")
                .font(.headline)
            
            Chart {
                BarMark(
                    x: .value("Outcome", "Focus"),
                    y: .value("Count", successCount)
                )
                .foregroundStyle(AppStyling.primaryGreen.gradient)
                .cornerRadius(8)
                
                BarMark(
                    x: .value("Outcome", "Choice"),
                    y: .value("Count", choiceCount)
                )
                .foregroundStyle(Color.orange.gradient)
                .cornerRadius(8)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .premiumCard()
    }
    
    private var dailyBreakdown: some View {
        let dailyData = generateDailyData()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Daily Breakdown")
                .font(.headline)
            
            Chart(dailyData, id: \.day) { item in
                LineMark(
                    x: .value("Day", item.day),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(AppStyling.primaryGreen.gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Day", item.day),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(AppStyling.primaryGreen.opacity(0.2).gradient)
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 150)
        }
        .padding()
        .premiumCard()
    }
    
    private var appBreakdown: some View {
        let appCounts = Dictionary(grouping: filteredEvents, by: { $0.appBundleId })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(5)
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Most Attempted Apps")
                .font(.headline)
            
            ForEach(Array(appCounts), id: \.key) { app, count in
                HStack {
                    Image(systemName: "app.fill")
                        .foregroundColor(.secondary)
                    
                    Text(app)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.subheadline.bold())
                        .foregroundColor(AppStyling.primaryGreen)
                }
                .padding(.vertical, 4)
                
                if app != appCounts.last?.key {
                    Divider()
                }
            }
        }
        .padding()
        .premiumCard()
    }
    
    private func generateDailyData() -> [(day: String, count: Int)] {
        let calendar = Calendar.current
        let dayNames = ["S", "M", "T", "W", "T", "F", "S"]
        var data: [(day: String, count: Int)] = []
        
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let dayIndex = calendar.component(.weekday, from: date) - 1
            
            let dayEvents = filteredEvents.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            data.append((dayNames[dayIndex], dayEvents.count))
        }
        
        return data
    }
}

struct StatBox: View {
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
    }
}

struct StatsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatsDetailView()
        }
    }
}
