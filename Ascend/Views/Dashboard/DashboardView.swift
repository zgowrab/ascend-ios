import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @Query private var profiles: [UserProfile]
    @Query(sort: \Routine.name) private var routines: [Routine]
    @Query(sort: \DailyDisciplineEntry.date, order: .reverse) private var disciplineEntries: [DailyDisciplineEntry]
    @Query private var supplements: [SupplementItem]
    @Query(sort: \DailyMealLog.date, order: .reverse) private var todayMeals: [DailyMealLog]
    @Query(sort: \SavedFavoriteMeal.useCount, order: .reverse) private var savedStaples: [SavedFavoriteMeal]
    
    private var profile: UserProfile? { profiles.first }
    
    private var todayEntry: DailyDisciplineEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return disciplineEntries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    private var totalProteinConsumedToday: Double {
        let today = Calendar.current.startOfDay(for: Date())
        return todayMeals
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.proteinGrams }
    }
    
    private var totalCaloriesConsumedToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return todayMeals
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.calories }
    }
    
    @State private var showingEditProfileSheet = false
    @State private var showingSmartScanSheet = false
    @State private var quickLogToast: String?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Discipline Score Ring
                    headerScoreSection
                    
                    // Mindset & Focus Quote
                    mindsetSection
                    
                    // The Daily 5 Non-Negotiables Checklist
                    daily5ChecklistSection
                    
                    // Next Workout Directive
                    nextWorkoutDirectiveSection
                    
                    // Quick Macro Progress
                    macroProgressSection
                    
                    // Today's Supplement Protocol
                    supplementProtocolSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .ascendBackground()
            .navigationTitle("Ascend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let profile = profile {
                        Button {
                            showingEditProfileSheet = true
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "slider.horizontal.3")
                                Text("Edit Profile")
                            }
                            .font(.caption.bold())
                            .foregroundStyle(AscendTheme.bgPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AscendTheme.emerald)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditProfileSheet) {
                if let profile = profile {
                    OnboardingFlowView(profile: profile, isEditing: true)
                }
            }
            .sheet(isPresented: $showingSmartScanSheet) {
                SmartMealScannerView()
            }
            .overlay(alignment: .top) {
                if let toast = quickLogToast {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AscendTheme.emerald)
                        Text(toast)
                            .font(.caption.bold())
                            .foregroundStyle(AscendTheme.textPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(AscendTheme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
                }
            }
        }
        .onAppear {
            ensureTodayDisciplineEntry()
        }
    }
    
    // MARK: - Header & Score Ring
    private var headerScoreSection: some View {
        GlassCard(cornerRadius: 22, padding: 18) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DAILY DISCIPLINE")
                        .font(.caption.bold())
                        .foregroundStyle(AscendTheme.emerald)
                        .tracking(1)
                    
                    Text("Rise, \(profile?.name ?? "Athlete")")
                        .font(.title2.bold())
                        .foregroundStyle(AscendTheme.textPrimary)
                    
                    Text("Commitment to standard creates transformation.")
                        .font(.caption)
                        .foregroundStyle(AscendTheme.textSecondary)
                }
                
                Spacer()
                
                // Score Gauge Ring
                let score = todayEntry?.completionPercentage ?? 0.0
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 8)
                        .frame(width: 72, height: 72)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(score))
                        .stroke(
                            AscendTheme.primaryGradient,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 72, height: 72)
                        .animation(.snappy, value: score)
                    
                    VStack(spacing: 0) {
                        Text("\(Int(score * 100))%")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(AscendTheme.textPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Mindset & Focus
    private var mindsetSection: some View {
        let quote = MindsetQuote.todayQuote
        return GlassCard(cornerRadius: 16, padding: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.title3)
                    .foregroundStyle(AscendTheme.emerald)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quote.quote)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(AscendTheme.textPrimary)
                    
                    Text("— \(quote.author) (\(quote.theme))")
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.textSecondary)
                }
                Spacer()
            }
        }
    }
    
    // MARK: - The Daily 5
    private var daily5ChecklistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("The Daily 5 Non-Negotiables", systemImage: "checklist")
                    .font(.headline)
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Spacer()
                
                if let entry = todayEntry {
                    Text("\(entry.completedCount)/5 Hit")
                        .font(.caption.bold())
                        .foregroundStyle(entry.isPerfectDay ? AscendTheme.emerald : AscendTheme.textSecondary)
                }
            }
            
            if let entry = todayEntry {
                VStack(spacing: 8) {
                    dailyItemRow(
                        title: "Physical Training Completed",
                        subtitle: "Dedicated workout or structured active recovery",
                        icon: "figure.strengthtraining.traditional",
                        color: AscendTheme.emerald,
                        isDone: entry.workoutCompleted
                    ) {
                        entry.workoutCompleted.toggle()
                        try? modelContext.save()
                    }
                    
                    dailyItemRow(
                        title: "Protein Threshold Hit",
                        subtitle: "Target: \(profile?.dailyProteinGrams ?? 160)g (Logged: \(Int(totalProteinConsumedToday))g)",
                        icon: "fork.knife",
                        color: AscendTheme.cyan,
                        isDone: entry.proteinHit || (totalProteinConsumedToday >= Double(profile?.dailyProteinGrams ?? 160))
                    ) {
                        entry.proteinHit.toggle()
                        try? modelContext.save()
                    }
                    
                    dailyItemRow(
                        title: "Supplements Protocol Taken",
                        subtitle: "Creatine, Vitamins & Goal Stack",
                        icon: "pills.fill",
                        color: AscendTheme.amber,
                        isDone: entry.supplementsTaken
                    ) {
                        entry.supplementsTaken.toggle()
                        try? modelContext.save()
                    }
                    
                    dailyItemRow(
                        title: "Hydration Standard Met",
                        subtitle: "Target: \(String(format: "%.1f", profile?.dailyWaterTargetLiters ?? 3.5)) Liters fresh water",
                        icon: "drop.fill",
                        color: AscendTheme.cyan,
                        isDone: entry.hydrationHit
                    ) {
                        entry.hydrationHit.toggle()
                        try? modelContext.save()
                    }
                    
                    dailyItemRow(
                        title: "Sleep & Recovery Standard",
                        subtitle: "7-8+ Hours restorative sleep",
                        icon: "moon.stars.fill",
                        color: AscendTheme.purple,
                        isDone: entry.sleepHit
                    ) {
                        entry.sleepHit.toggle()
                        try? modelContext.save()
                    }
                }
            }
        }
    }
    
    private func dailyItemRow(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        isDone: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(isDone ? AscendTheme.bgPrimary : color)
                    .frame(width: 36, height: 36)
                    .background(isDone ? color : AscendTheme.bgElevated)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(isDone ? AscendTheme.textSecondary : AscendTheme.textPrimary)
                        .strikethrough(isDone, color: AscendTheme.textMuted)
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(AscendTheme.textMuted)
                }
                
                Spacer()
                
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isDone ? color : AscendTheme.textMuted)
            }
            .padding(12)
            .background(AscendTheme.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    // MARK: - Next Workout Directive
    private var nextWorkoutDirectiveSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Today's Workout Session", systemImage: "flame.fill")
                .font(.headline)
                .foregroundStyle(AscendTheme.flame)
            
            if let primaryRoutine = routines.first, let firstDay = primaryRoutine.days.first {
                GlassCard(cornerRadius: 18, padding: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(primaryRoutine.name)
                                    .font(.caption.bold())
                                    .foregroundStyle(AscendTheme.emerald)
                                    .textCase(.uppercase)
                                
                                Text(firstDay.dayName)
                                    .font(.headline)
                                    .foregroundStyle(AscendTheme.textPrimary)
                            }
                            Spacer()
                            Text("\(firstDay.exercises.count) Exercises")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AscendTheme.bgElevated)
                                .clipShape(Capsule())
                                .foregroundStyle(AscendTheme.textSecondary)
                        }
                        
                        // Exercise preview badges
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(firstDay.exercises.prefix(4)) { ex in
                                    Text(ex.exerciseName)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.06))
                                        .clipShape(Capsule())
                                        .foregroundStyle(AscendTheme.textSecondary)
                                }
                            }
                        }
                        
                        Button {
                            appState.startWorkout(routine: primaryRoutine, day: firstDay)
                            appState.selectedTab = 1 // Switch to workouts tab
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Guided Session")
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(AscendTheme.bgPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(AscendTheme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            } else {
                Text("No routines found. Tap Workouts to generate your cycle.")
                    .font(.caption)
                    .foregroundStyle(AscendTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Macro Progress
    private var macroProgressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Today's Nutrition Fuel", systemImage: "chart.pie.fill")
                    .font(.headline)
                    .foregroundStyle(AscendTheme.cyan)
                
                Spacer()
                
                Button {
                    showingSmartScanSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "camera.viewfinder")
                        Text("Scan")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(AscendTheme.emerald)
                }
                .padding(.trailing, 8)
                
                Button("Portions") {
                    appState.selectedTab = 2 // Go to nutrition tab
                }
                .font(.caption.bold())
                .foregroundStyle(AscendTheme.cyan)
            }
            
            GlassCard(cornerRadius: 18, padding: 16) {
                VStack(spacing: 14) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Calories")
                                .font(.caption)
                                .foregroundStyle(AscendTheme.textSecondary)
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("\(totalCaloriesConsumedToday)")
                                    .font(.title2.bold())
                                    .monospacedDigit()
                                    .foregroundStyle(AscendTheme.textPrimary)
                                Text("/ \(profile?.dailyCalorieTarget ?? 2400)")
                                    .font(.caption)
                                    .foregroundStyle(AscendTheme.textMuted)
                            }
                            
                            ProgressView(
                                value: Double(totalCaloriesConsumedToday),
                                total: Double(profile?.dailyCalorieTarget ?? 2400)
                            )
                            .tint(AscendTheme.emerald)
                        }
                        
                        Divider().frame(height: 45)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Protein Target")
                                .font(.caption)
                                .foregroundStyle(AscendTheme.textSecondary)
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("\(Int(totalProteinConsumedToday))g")
                                    .font(.title2.bold())
                                    .monospacedDigit()
                                    .foregroundStyle(AscendTheme.cyan)
                                Text("/ \(profile?.dailyProteinGrams ?? 165)g")
                                    .font(.caption)
                                    .foregroundStyle(AscendTheme.textMuted)
                            }
                            
                            ProgressView(
                                value: totalProteinConsumedToday,
                                total: Double(profile?.dailyProteinGrams ?? 165)
                            )
                            .tint(AscendTheme.cyan)
                        }
                    }
                    
                    // 1-Tap Quick Staples Bar
                    if !savedStaples.isEmpty {
                        Divider().padding(.vertical, 2)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("1-TAP QUICK STAPLES")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(AscendTheme.amber)
                                    .tracking(1)
                                Spacer()
                                Text("Tap to log")
                                    .font(.system(size: 10))
                                    .foregroundStyle(AscendTheme.textMuted)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(savedStaples.prefix(6)) { staple in
                                        Button {
                                            logStapleFromDashboard(staple)
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: staple.icon)
                                                    .font(.caption2)
                                                    .foregroundStyle(AscendTheme.emerald)
                                                Text(staple.name)
                                                    .font(.caption2.bold())
                                                    .foregroundStyle(AscendTheme.textPrimary)
                                                Text("+\(staple.calories)")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundStyle(AscendTheme.emerald)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background(AscendTheme.emerald.opacity(0.15))
                                                    .clipShape(Capsule())
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(AscendTheme.bgSecondary)
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule()
                                                    .stroke(AscendTheme.cardBorder, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func logStapleFromDashboard(_ staple: SavedFavoriteMeal) {
        let log = DailyMealLog(
            mealSlot: staple.mealSlot,
            foodName: staple.name,
            servings: 1.0,
            proteinGrams: staple.proteinGrams,
            carbsGrams: staple.carbsGrams,
            fatsGrams: staple.fatsGrams,
            calories: staple.calories,
            isSmartScanned: false,
            portionNotes: staple.servingDescription
        )
        modelContext.insert(log)
        staple.useCount += 1
        staple.lastLoggedAt = Date()
        try? modelContext.save()
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.snappy) {
            quickLogToast = "Logged \(staple.name) (+\(staple.calories) kcal)"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                if quickLogToast == "Logged \(staple.name) (+\(staple.calories) kcal)" {
                    quickLogToast = nil
                }
            }
        }
    }
    
    // MARK: - Supplement Protocol
    private var supplementProtocolSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Essential Supplement Protocol", systemImage: "pills.fill")
                .font(.headline)
                .foregroundStyle(AscendTheme.amber)
            
            VStack(spacing: 8) {
                ForEach(supplements.prefix(3)) { supp in
                    HStack {
                        Image(systemName: supp.timing.icon)
                            .font(.caption)
                            .foregroundStyle(AscendTheme.amber)
                            .frame(width: 28, height: 28)
                            .background(AscendTheme.bgElevated)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(supp.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(AscendTheme.textPrimary)
                            Text("\(supp.dosage) • \(supp.timing.rawValue)")
                                .font(.caption2)
                                .foregroundStyle(AscendTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            supp.isTakenToday.toggle()
                            supp.lastTakenDate = Date()
                            try? modelContext.save()
                        } label: {
                            Image(systemName: supp.isTakenToday ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(supp.isTakenToday ? AscendTheme.emerald : AscendTheme.textMuted)
                        }
                    }
                    .padding(10)
                    .background(AscendTheme.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private func ensureTodayDisciplineEntry() {
        let today = Calendar.current.startOfDay(for: Date())
        if !disciplineEntries.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            let entry = DailyDisciplineEntry(
                date: today,
                workoutCompleted: false,
                proteinHit: false,
                supplementsTaken: false,
                hydrationHit: false,
                sleepHit: false
            )
            modelContext.insert(entry)
            try? modelContext.save()
        }
    }
}
