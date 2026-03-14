import SwiftUI
import SwiftData

struct MainDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var blockedApps: [BlockedApp]
    @Query(sort: \UsageEvent.timestamp, order: .reverse) private var events: [UsageEvent]
    
    @State private var pickerIsPresented = false
    @State private var selection = FamilyActivitySelection()
    
    var body: some View {
        NavigationView {
            VStack {
                // Summary Card
                StatsHeaderView(events: events)
                
                List {
                    Section(header: Text("Blocked Apps")) {
                        ForEach(blockedApps) { app in
                            Text(app.displayName)
                        }
                        .onDelete(perform: deleteApps)
                        
                        Button("Select Apps to Block") {
                            pickerIsPresented = true
                        }
                        .foregroundColor(.green)
                    }
                    
                    Section(header: Text("Recent Activity")) {
                        ForEach(events.prefix(5)) { event in
                            HStack {
                                Text(event.appBundleId)
                                    .font(.caption)
                                Spacer()
                                Text(event.outcome)
                                    .foregroundColor(event.outcome == "SUCCESS" ? .green : .orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .familyActivityPicker(isPresented: $pickerIsPresented, selection: $selection)
            .onChange(of: selection) { newSelection in
                saveSelection(newSelection)
            }
        }
    }
    
    private func saveSelection(_ selection: FamilyActivitySelection) {
        // Logic to sync selection with BlockedApp models
        // In a real app, we'd map tokens to bundle IDs
    }
    
    private func deleteApps(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(blockedApps[index])
            }
        }
    }
}

struct StatsHeaderView: View {
    let events: [UsageEvent]
    
    var successRate: Int {
        guard !events.isEmpty else { return 0 }
        let successes = events.filter { $0.outcome == "SUCCESS" }.count
        return Int((Double(successes) / Double(events.count)) * 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Impulse Control Rate")
                .font(.caption)
                .uppercaseSmallCaps()
            
            HStack {
                Text("\(successRate)%")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                Spacer()
                Image(systemName: successRate > 70 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                    .font(.title)
                    .foregroundColor(successRate > 70 ? .green : .orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .padding()
    }
}
