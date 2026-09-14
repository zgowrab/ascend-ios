import SwiftUI
import SwiftData

public struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @Query(sort: \Routine.name) private var routines: [Routine]
    @Query(sort: \ExerciseDefinition.name) private var exercises: [ExerciseDefinition]
    
    @State private var viewMode: Int = 0 // 0 = Current Program, 1 = Exercise Library
    @State private var selectedMuscleFilter: MuscleGroup? = nil
    @State private var searchText: String = ""
    @State private var inspectedExercise: ExerciseDefinition?
    
    public init() {}
    
    private var filteredExercises: [ExerciseDefinition] {
        exercises.filter { ex in
            let matchesMuscle = selectedMuscleFilter == nil || ex.muscleGroup == selectedMuscleFilter
            let matchesSearch = searchText.isEmpty || ex.name.localizedCaseInsensitiveContains(searchText)
            return matchesMuscle && matchesSearch
        }
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // In-Progress Banner if active
                if appState.isWorkoutInProgress {
                    activeSessionBanner
                }
                
                // Mode Picker
                Picker("View", selection: $viewMode) {
                    Text("My Training Cycle").tag(0)
                    Text("Exercise Library").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                if viewMode == 0 {
                    routineCycleView
                } else {
                    exerciseLibraryView
                }
            }
            .ascendBackground()
            .navigationTitle("Workouts & Guides")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $inspectedExercise) { ex in
                ExerciseDetailView(exercise: ex)
            }
        }
    }
    
    // MARK: - Active Banner
    private var activeSessionBanner: some View {
        Button {
            // Already in session
        } label: {
            HStack {
                Circle()
                    .fill(AscendTheme.emerald)
                    .frame(width: 10, height: 10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("SESSION IN PROGRESS")
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.emerald)
                    Text(appState.activeSession?.dayName ?? "Workout")
                        .font(.subheadline.bold())
                        .foregroundStyle(AscendTheme.textPrimary)
                }
                
                Spacer()
                
                Text("Resume")
                    .font(.caption.bold())
                    .foregroundStyle(AscendTheme.bgPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AscendTheme.emerald)
                    .clipShape(Capsule())
            }
            .padding(14)
            .background(AscendTheme.bgElevated)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(AscendTheme.emerald.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Routine Cycle View
    private var routineCycleView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                if let routine = routines.first {
                    // Routine Info Card
                    GlassCard(cornerRadius: 20, padding: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(routine.daysPerWeek) DAYS / WEEK")
                                    .font(.caption2.bold())
                                    .foregroundStyle(AscendTheme.emerald)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AscendTheme.emerald.opacity(0.15))
                                    .clipShape(Capsule())
                                
                                Text(routine.equipmentTierRaw)
                                    .font(.caption2.bold())
                                    .foregroundStyle(AscendTheme.cyan)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AscendTheme.cyan.opacity(0.15))
                                    .clipShape(Capsule())
                                
                                Spacer()
                            }
                            
                            Text(routine.name)
                                .font(.title3.bold())
                                .foregroundStyle(AscendTheme.textPrimary)
                            
                            Text(routine.subtitle)
                                .font(.caption)
                                .foregroundStyle(AscendTheme.textSecondary)
                        }
                    }
                    
                    // Days List
                    VStack(spacing: 16) {
                        ForEach(routine.days.sorted(by: { $0.orderIndex < $1.orderIndex })) { day in
                            dayCard(for: day, in: routine)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Routine Found",
                        systemImage: "dumbbell",
                        description: Text("Complete onboarding to generate your training cycle.")
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
    }
    
    private func dayCard(for day: RoutineDay, in routine: Routine) -> some View {
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DAY \(day.orderIndex)")
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.emerald)
                        
                        Text(day.dayName)
                            .font(.headline)
                            .foregroundStyle(AscendTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Button {
                        appState.startWorkout(routine: routine, day: day)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                        .font(.caption.bold())
                        .foregroundStyle(AscendTheme.bgPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AscendTheme.primaryGradient)
                        .clipShape(Capsule())
                    }
                }
                
                Divider().background(Color.white.opacity(0.08))
                
                // Exercise rows
                VStack(spacing: 8) {
                    ForEach(day.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { ex in
                        HStack {
                            Text("\(ex.orderIndex).")
                                .font(.caption.bold())
                                .foregroundStyle(AscendTheme.textMuted)
                                .frame(width: 20, alignment: .leading)
                            
                            Text(ex.exerciseName)
                                .font(.subheadline)
                                .foregroundStyle(AscendTheme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(ex.targetSets) × \(ex.targetReps)")
                                .font(.caption.bold())
                                .monospacedDigit()
                                .foregroundStyle(AscendTheme.cyan)
                            
                            if let def = exercises.first(where: { $0.name == ex.exerciseName }) {
                                Button {
                                    inspectedExercise = def
                                } label: {
                                    Image(systemName: "info.circle")
                                        .font(.caption)
                                        .foregroundStyle(AscendTheme.textSecondary)
                                }
                                .padding(.leading, 6)
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
        }
    }
    
    // MARK: - Exercise Library View
    private var exerciseLibraryView: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AscendTheme.textMuted)
                TextField("Search exercises...", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(AscendTheme.textPrimary)
            }
            .padding(10)
            .background(AscendTheme.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            
            // Muscle Group Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        selectedMuscleFilter = nil
                    } label: {
                        Text("All")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedMuscleFilter == nil ? AscendTheme.emerald : AscendTheme.bgElevated)
                            .foregroundStyle(selectedMuscleFilter == nil ? AscendTheme.bgPrimary : AscendTheme.textSecondary)
                            .clipShape(Capsule())
                    }
                    
                    ForEach(MuscleGroup.allCases) { muscle in
                        Button {
                            selectedMuscleFilter = (selectedMuscleFilter == muscle ? nil : muscle)
                        } label: {
                            Text(muscle.rawValue)
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedMuscleFilter == muscle ? AscendTheme.emerald : AscendTheme.bgElevated)
                                .foregroundStyle(selectedMuscleFilter == muscle ? AscendTheme.bgPrimary : AscendTheme.textSecondary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            
            // Exercise Cards List
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(filteredExercises) { ex in
                        Button {
                            inspectedExercise = ex
                        } label: {
                            HStack {
                                Image(systemName: ex.muscleGroup.icon)
                                    .font(.title3)
                                    .foregroundStyle(AscendTheme.emerald)
                                    .frame(width: 40, height: 40)
                                    .background(AscendTheme.bgElevated)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ex.name)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(AscendTheme.textPrimary)
                                    
                                    HStack(spacing: 6) {
                                        Text(ex.muscleGroup.rawValue)
                                            .font(.caption2)
                                            .foregroundStyle(AscendTheme.textSecondary)
                                        Text("•")
                                            .foregroundStyle(AscendTheme.textMuted)
                                        Text(ex.equipment.rawValue)
                                            .font(.caption2)
                                            .foregroundStyle(AscendTheme.cyan)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(AscendTheme.textMuted)
                            }
                            .padding(14)
                            .background(AscendTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
    }
}
