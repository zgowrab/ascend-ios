import SwiftUI
import SwiftData

public struct ActiveWorkoutPlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @Query private var exerciseDefinitions: [ExerciseDefinition]
    
    @State private var elapsedSeconds: Int = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var selectedExerciseIndex: Int = 0
    @State private var selectedGuideExercise: ExerciseDefinition?
    @State private var showingFinishConfirmation = false
    @State private var showingCelebrationSheet = false
    @State private var showingFormPreview: Bool = false
    
    public init() {}
    
    private var session: WorkoutSession? {
        appState.activeSession
    }
    
    private var distinctExerciseNames: [String] {
        guard let sets = session?.sets else { return [] }
        var names: [String] = []
        for set in sets {
            if !names.contains(set.exerciseName) {
                names.append(set.exerciseName)
            }
        }
        return names
    }
    
    private var currentExerciseName: String {
        guard !distinctExerciseNames.isEmpty, selectedExerciseIndex < distinctExerciseNames.count else { return "" }
        return distinctExerciseNames[selectedExerciseIndex]
    }
    
    private var currentSets: [ExerciseSetRecord] {
        guard let sets = session?.sets else { return [] }
        return sets
            .filter { $0.exerciseName == currentExerciseName }
            .sorted(by: { $0.setNumber < $1.setNumber })
    }
    
    private var matchingDefinition: ExerciseDefinition? {
        exerciseDefinitions.first { $0.name.lowercased() == currentExerciseName.lowercased() }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AscendTheme.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Session Header Bar
                    sessionHeaderBar
                    
                    // Exercise Carousel Tab Bar
                    exerciseSelectorBar
                    
                    // Main Exercise Workspace
                    GeometryReader { geo in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 20) {
                                // Exercise Info & Guide Card
                                exerciseHeaderCard
                                
                                // Sets Table
                                setsTableCard
                                
                                // Rest Timer Card if active
                                if appState.isRestTimerActive {
                                    RestTimerView(
                                        totalSeconds: Bindable(appState).restTimerTotalSeconds,
                                        remainingSeconds: Bindable(appState).restTimerRemainingSeconds,
                                        isRunning: Bindable(appState).isRestTimerRunning,
                                        onComplete: {
                                            appState.dismissRestTimer()
                                        },
                                        onDismiss: {
                                            appState.dismissRestTimer()
                                        }
                                    )
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                                
                                // Bottom Action: Finish Workout
                                finishButton
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(width: geo.size.width)
                        }
                        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                    }
                }
            }
            .navigationTitle(session?.dayName ?? "Active Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Discard") {
                        appState.isWorkoutInProgress = false
                        appState.activeSession = nil
                    }
                    .font(.subheadline)
                    .foregroundStyle(AscendTheme.flame)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Finish") {
                        showingFinishConfirmation = true
                    }
                    .font(.headline.bold())
                    .foregroundStyle(AscendTheme.emerald)
                }
            }
            .sheet(item: $selectedGuideExercise) { ex in
                ExerciseDetailView(exercise: ex)
            }
            .sheet(isPresented: $showingCelebrationSheet) {
                celebrationSummarySheet
            }
            .alert("Finish Workout Session?", isPresented: $showingFinishConfirmation) {
                Button("Keep Training", role: .cancel) {}
                Button("Complete & Log", role: .none) {
                    completeSession()
                }
            } message: {
                Text("Your completed sets and training volume will be permanently recorded in your discipline log.")
            }
        }
        .onReceive(timer) { _ in
            if appState.isWorkoutInProgress {
                elapsedSeconds += 1
                appState.activeSession?.durationSeconds = elapsedSeconds
            }
        }
    }
    
    // MARK: - Subviews
    private var sessionHeaderBar: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(AscendTheme.emerald)
                    .frame(width: 8, height: 8)
                
                Text(formatElapsed(elapsedSeconds))
                    .font(.system(.subheadline, design: .rounded).bold())
                    .monospacedDigit()
                    .foregroundStyle(AscendTheme.textPrimary)
            }
            
            Spacer()
            
            let totalVolume = session?.totalVolumeKg ?? 0
            Text(String(format: "Total: %.0f kg", totalVolume))
                .font(.caption.bold())
                .foregroundStyle(AscendTheme.cyan)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AscendTheme.bgElevated)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(AscendTheme.bgSecondary)
    }
    
    private var exerciseSelectorBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(distinctExerciseNames.enumerated()), id: \.offset) { index, name in
                    Button {
                        withAnimation(.snappy) {
                            selectedExerciseIndex = index
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("\(index + 1)")
                                .font(.caption2.bold())
                                .frame(width: 18, height: 18)
                                .background(selectedExerciseIndex == index ? AscendTheme.bgPrimary : AscendTheme.textMuted)
                                .foregroundStyle(selectedExerciseIndex == index ? AscendTheme.emerald : Color.white)
                                .clipShape(Circle())
                            
                            Text(name)
                                .font(.caption.bold())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedExerciseIndex == index ? AscendTheme.emerald : AscendTheme.bgElevated)
                        .foregroundStyle(selectedExerciseIndex == index ? AscendTheme.bgPrimary : AscendTheme.textSecondary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(AscendTheme.bgPrimary)
    }
    
    private var exerciseHeaderCard: some View {
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("EXERCISE \(selectedExerciseIndex + 1) OF \(distinctExerciseNames.count)")
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.emerald)
                            .tracking(1)
                        
                        Text(currentExerciseName)
                            .font(.title3.bold())
                            .foregroundStyle(AscendTheme.textPrimary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Detail Form Guide
                    Button {
                        if let def = matchingDefinition {
                            selectedGuideExercise = def
                        }
                    } label: {
                        Label("Guide", systemImage: "info.circle.fill")
                            .font(.caption.bold())
                            .foregroundStyle(AscendTheme.emerald)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AscendTheme.emerald.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                
                if let def = matchingDefinition {
                    let profile = MuscleActivationProfile.profile(for: def.name, muscleGroup: def.muscleGroup)
                    
                    HStack(spacing: 8) {
                        // Toggle for inline real photo demonstration
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showingFormPreview.toggle()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: showingFormPreview ? "chevron.up.circle.fill" : "photo.fill")
                                Text(showingFormPreview ? "Hide Form" : "Show Form")
                            }
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.textPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AscendTheme.bgElevated)
                            .clipShape(Capsule())
                        }
                        
                        // Primary Target Muscle Badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(AscendTheme.emerald)
                                .frame(width: 6, height: 6)
                            Text(profile.primaryMuscles.first ?? def.muscleGroup.rawValue)
                                .font(.caption2.bold())
                                .foregroundStyle(AscendTheme.emerald)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AscendTheme.emerald.opacity(0.12))
                        .clipShape(Capsule())
                        
                        Spacer()
                    }
                    
                    // Inline Collapsible Real Human Gym Form Preview
                    if showingFormPreview {
                        ExerciseDemonstrationView(
                            exerciseName: def.name,
                            muscleGroup: def.muscleGroup,
                            height: 200
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var setsTableCard: some View {
        VStack(spacing: 10) {
            // Table Header
            HStack {
                Text("SET")
                    .frame(width: 40, alignment: .leading)
                Text("PREV")
                    .frame(width: 60, alignment: .center)
                Text("KG")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("REPS")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("DONE")
                    .frame(width: 48, alignment: .trailing)
            }
            .font(.caption.bold())
            .foregroundStyle(AscendTheme.textMuted)
            .padding(.horizontal, 14)
            
            // Set Rows
            VStack(spacing: 8) {
                ForEach(currentSets) { set in
                    setRowView(for: set)
                }
            }
            
            // Add Set Button
            Button {
                addSetToCurrentExercise()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Set")
                }
                .font(.subheadline.bold())
                .foregroundStyle(AscendTheme.emerald)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(AscendTheme.emerald.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 4)
        }
        .glassCardStyle(cornerRadius: 18, padding: 14)
    }
    
    @ViewBuilder
    private func setRowView(for set: ExerciseSetRecord) -> some View {
        @Bindable var bindableSet = set
        
        HStack(spacing: 10) {
            // Set Number
            Text("\(set.setNumber)")
                .font(.headline.bold())
                .foregroundStyle(set.isCompleted ? AscendTheme.textMuted : AscendTheme.textPrimary)
                .frame(width: 40, alignment: .leading)
            
            // Previous placeholder
            Text("—")
                .font(.caption)
                .foregroundStyle(AscendTheme.textMuted)
                .frame(width: 60, alignment: .center)
            
            // Weight Input
            HStack(spacing: 4) {
                TextField("0", value: $bindableSet.weightKg, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.subheadline.bold())
                    .monospacedDigit()
                    .frame(height: 36)
                    .background(AscendTheme.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(AscendTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            
            // Reps Input
            HStack(spacing: 4) {
                TextField("10", value: $bindableSet.reps, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.subheadline.bold())
                    .monospacedDigit()
                    .frame(height: 36)
                    .background(AscendTheme.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(AscendTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            
            // Completion Checkbox Button
            Button {
                withAnimation(.snappy) {
                    bindableSet.isCompleted.toggle()
                    if bindableSet.isCompleted {
                        let restDuration = matchingDefinition?.defaultRestSeconds ?? 90
                        appState.triggerRestTimer(seconds: restDuration)
                    }
                }
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.isCompleted ? AscendTheme.emerald : AscendTheme.textMuted)
                    .frame(width: 48, height: 36)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(set.isCompleted ? AscendTheme.emerald.opacity(0.08) : AscendTheme.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var finishButton: some View {
        Button {
            showingFinishConfirmation = true
        } label: {
            HStack {
                Image(systemName: "flag.checkered")
                Text("Complete Workout Session")
            }
            .font(.headline.bold())
            .foregroundStyle(AscendTheme.bgPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AscendTheme.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top, 8)
    }
    
    // MARK: - Celebration Modal
    private var celebrationSummarySheet: some View {
        ZStack {
            AscendTheme.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AscendTheme.amber)
                    .padding(.top, 30)
                
                VStack(spacing: 6) {
                    Text("SESSION CONQUERED")
                        .font(.caption.bold())
                        .foregroundStyle(AscendTheme.emerald)
                        .tracking(1)
                    
                    Text("Standard Upheld.")
                        .font(.largeTitle.bold())
                        .foregroundStyle(AscendTheme.textPrimary)
                    
                    Text("Discipline is the bridge between goals and accomplishment.")
                        .font(.subheadline)
                        .foregroundStyle(AscendTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                HStack(spacing: 16) {
                    VStack {
                        Text("Duration")
                            .font(.caption)
                            .foregroundStyle(AscendTheme.textSecondary)
                        Text(formatElapsed(elapsedSeconds))
                            .font(.title3.bold())
                            .foregroundStyle(AscendTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassCardStyle(cornerRadius: 16)
                    
                    VStack {
                        Text("Volume Moved")
                            .font(.caption)
                            .foregroundStyle(AscendTheme.textSecondary)
                        Text(String(format: "%.0f kg", session?.totalVolumeKg ?? 0))
                            .font(.title3.bold())
                            .foregroundStyle(AscendTheme.cyan)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassCardStyle(cornerRadius: 16)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button {
                    showingCelebrationSheet = false
                    appState.finishWorkout()
                } label: {
                    Text("Return to Command Center")
                        .font(.headline.bold())
                        .foregroundStyle(AscendTheme.bgPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(AscendTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Logic
    private func addSetToCurrentExercise() {
        guard let session = session else { return }
        let nextSetNum = (currentSets.map { $0.setNumber }.max() ?? 0) + 1
        let lastWeight = currentSets.last?.weightKg ?? 0.0
        let lastReps = currentSets.last?.reps ?? 10
        
        let newSet = ExerciseSetRecord(
            exerciseName: currentExerciseName,
            setNumber: nextSetNum,
            weightKg: lastWeight,
            reps: lastReps,
            rpe: 8.0,
            isCompleted: false
        )
        newSet.session = session
        session.sets.append(newSet)
        try? modelContext.save()
    }
    
    private func completeSession() {
        guard let session = session else { return }
        session.isCompleted = true
        session.durationSeconds = elapsedSeconds
        
        // Mark physical training completed in today's discipline entry
        let today = Calendar.current.startOfDay(for: Date())
        let fetchDescriptor = FetchDescriptor<DailyDisciplineEntry>()
        if let entries = try? modelContext.fetch(fetchDescriptor) {
            if let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                entry.workoutCompleted = true
            }
        }
        
        try? modelContext.save()
        showingCelebrationSheet = true
    }
    
    private func formatElapsed(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
