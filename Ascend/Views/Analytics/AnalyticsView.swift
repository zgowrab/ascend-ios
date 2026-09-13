import SwiftUI
import SwiftData
import Charts

public struct AnalyticsView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse) private var workoutSessions: [WorkoutSession]
    @Query(sort: \DailyDisciplineEntry.date, order: .reverse) private var disciplineEntries: [DailyDisciplineEntry]
    @Query private var profiles: [UserProfile]
    
    private var profile: UserProfile? { profiles.first }
    
    public init() {}
    
    // Last 7 days discipline
    private var last7DaysEntries: [DailyDisciplineEntry] {
        Array(disciplineEntries.prefix(7).reversed())
    }
    
    // Total Volume of completed workouts
    private var totalCareerVolumeKg: Double {
        workoutSessions.filter { $0.isCompleted }.reduce(0) { $0 + $1.totalVolumeKg }
    }
    
    private var currentDisciplineStreak: Int {
        var streak = 0
        let sorted = disciplineEntries.sorted(by: { $0.date > $1.date })
        for entry in sorted {
            if entry.completedCount >= 3 {
                streak += 1
            } else {
                break
            }
        }
        return max(1, streak)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Career Stats Row
                    careerStatsRow
                    
                    // Discipline Score Chart (Swift Charts)
                    disciplineChartCard
                    
                    // Workout Volume Chart (Swift Charts)
                    workoutVolumeChartCard
                    
                    // Milestones & Betterment Badges
                    milestonesSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .ascendBackground()
            .navigationTitle("Analytics & Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Career Stats Row
    private var careerStatsRow: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Current Streak",
                value: "\(currentDisciplineStreak) Days",
                subtitle: "Non-negotiables upheld",
                icon: "flame.fill",
                color: AscendTheme.flame
            )
            
            statCard(
                title: "Workouts",
                value: "\(workoutSessions.filter { $0.isCompleted }.count)",
                subtitle: "Completed sessions",
                icon: "dumbbell.fill",
                color: AscendTheme.emerald
            )
            
            statCard(
                title: "Volume",
                value: String(format: "%.0fk", totalCareerVolumeKg / 1000.0),
                subtitle: "kg lifted",
                icon: "chart.line.uptrend.xyaxis",
                color: AscendTheme.cyan
            )
        }
    }
    
    private func statCard(
        title: String,
        value: String,
        subtitle: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(.title3, design: .rounded).bold())
                .foregroundStyle(AscendTheme.textPrimary)
            
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(AscendTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassCardStyle(cornerRadius: 16)
    }
    
    // MARK: - Discipline Chart
    private var disciplineChartCard: some View {
        GlassCard(cornerRadius: 20, padding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CONSISTENCY HEATMAP")
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.emerald)
                            .tracking(1)
                        
                        Text("Daily Discipline Standards")
                            .font(.headline)
                            .foregroundStyle(AscendTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("Last 7 Days")
                        .font(.caption)
                        .foregroundStyle(AscendTheme.textSecondary)
                }
                
                if last7DaysEntries.isEmpty {
                    Text("Log your Daily 5 to see your consistency trajectory.")
                        .font(.caption)
                        .foregroundStyle(AscendTheme.textMuted)
                        .frame(height: 140)
                } else {
                    Chart(last7DaysEntries) { entry in
                        BarMark(
                            x: .value("Day", formatDateShort(entry.date)),
                            y: .value("Score %", entry.completionPercentage * 100.0)
                        )
                        .foregroundStyle(
                            entry.isPerfectDay ? AscendTheme.emerald : AscendTheme.cyan
                        )
                        .cornerRadius(6)
                        
                        RuleMark(y: .value("Standard", 80))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(AscendTheme.amber.opacity(0.8))
                            .annotation(position: .top, alignment: .trailing) {
                                Text("80% Mastery")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(AscendTheme.amber)
                            }
                    }
                    .frame(height: 160)
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .foregroundStyle(AscendTheme.textSecondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: [0, 50, 100]) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color.white.opacity(0.08))
                            AxisValueLabel {
                                if let intVal = value.as(Int.self) {
                                    Text("\(intVal)%")
                                        .font(.caption2)
                                        .foregroundStyle(AscendTheme.textMuted)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Workout Volume Chart
    private var workoutVolumeChartCard: some View {
        GlassCard(cornerRadius: 20, padding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PROGRESSIVE OVERLOAD")
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.cyan)
                            .tracking(1)
                        
                        Text("Training Volume per Session")
                            .font(.headline)
                            .foregroundStyle(AscendTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Label("Kilograms", systemImage: "scalemass.fill")
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.cyan)
                }
                
                let completed = workoutSessions.filter { $0.isCompleted }
                if completed.isEmpty {
                    Text("Complete workout sessions to unlock progressive overload trendlines.")
                        .font(.caption)
                        .foregroundStyle(AscendTheme.textMuted)
                        .frame(height: 140)
                } else {
                    Chart(completed.prefix(10).reversed()) { session in
                        LineMark(
                            x: .value("Date", formatDateShort(session.date)),
                            y: .value("Volume", session.totalVolumeKg)
                        )
                        .foregroundStyle(AscendTheme.primaryGradient)
                        .symbol(.circle)
                        .symbolSize(30)
                        
                        AreaMark(
                            x: .value("Date", formatDateShort(session.date)),
                            y: .value("Volume", session.totalVolumeKg)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AscendTheme.emerald.opacity(0.3), AscendTheme.cyan.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .frame(height: 160)
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .foregroundStyle(AscendTheme.textSecondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color.white.opacity(0.08))
                            AxisValueLabel()
                                .foregroundStyle(AscendTheme.textMuted)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Milestones
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Betterment Milestones", systemImage: "medal.fill")
                .font(.headline)
                .foregroundStyle(AscendTheme.amber)
            
            VStack(spacing: 8) {
                milestoneBadge(
                    title: "First Steps of Ascension",
                    desc: "Completed onboarding and generated customized directive.",
                    isUnlocked: profile?.isOnboarded ?? false
                )
                
                milestoneBadge(
                    title: "Iron Discipline",
                    desc: "Logged first complete guided workout session.",
                    isUnlocked: workoutSessions.contains(where: { $0.isCompleted })
                )
                
                milestoneBadge(
                    title: "7-Day Habit Formation",
                    desc: "Maintained a 7-day streak on The Daily 5.",
                    isUnlocked: currentDisciplineStreak >= 7
                )
            }
        }
    }
    
    private func milestoneBadge(title: String, desc: String, isUnlocked: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                .font(.title2)
                .foregroundStyle(isUnlocked ? AscendTheme.amber : AscendTheme.textMuted)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(isUnlocked ? AscendTheme.textPrimary : AscendTheme.textMuted)
                Text(desc)
                    .font(.caption2)
                    .foregroundStyle(AscendTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(AscendTheme.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}
