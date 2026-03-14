import SwiftUI

struct StatsDetailView: View {
    @Query private var events: [UsageEvent]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Success vs Choice Chart (Simplified)
                HStack(alignment: .bottom, spacing: 10) {
                    BarView(label: "Success", count: events.filter { $0.outcome == "SUCCESS" }.count, color: .green)
                    BarView(label: "Choice", count: events.filter { $0.outcome == "CHOICE" }.count, color: .orange)
                }
                .frame(height: 200)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(24)
                
                // Intent Breakdown
                VStack(alignment: .leading, spacing: 15) {
                    Text("Top Intentions")
                        .font(.headline)
                    
                    let intentCounts = Dictionary(grouping: events.compactMap { $0.intent }, by: { $0 }).mapValues { $0.count }
                    
                    ForEach(intentCounts.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                        HStack {
                            Text(key)
                            Spacer()
                            Text("\(value)")
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Detailed Stats")
    }
}

struct BarView: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.caption)
            Rectangle()
                .fill(color)
                .frame(width: 60, height: CGFloat(min(count * 10, 150)))
                .cornerRadius(8)
            Text(label)
                .font(.footnote)
        }
    }
}
