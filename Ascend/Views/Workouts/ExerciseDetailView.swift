import SwiftUI

public struct ExerciseDetailView: View {
    let exercise: ExerciseDefinition
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedVisualTab: Int = 0 // 0 = Kinematic Motion, 1 = Muscle Map
    
    public init(exercise: ExerciseDefinition) {
        self.exercise = exercise
    }
    
    public var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header Card
                        headerCard
                        
                        // Visual Presentation Mode Switcher
                        Picker("Visual Mode", selection: $selectedVisualTab) {
                            Text("Motion Animation").tag(0)
                            Text("Target Muscle Map").tag(1)
                        }
                        .pickerStyle(.segmented)
                        
                        // Dynamic Visual Presentation Area
                        if selectedVisualTab == 0 {
                            ExerciseKinematicAnimationView(
                                exerciseName: exercise.name,
                                muscleGroup: exercise.muscleGroup,
                                height: 230
                            )
                        } else {
                            TargetMuscleMapVisualizer(
                                exerciseName: exercise.name,
                                muscleGroup: exercise.muscleGroup
                            )
                        }
                        
                        // Setup Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Step 1: Setup & Posture", systemImage: "figure.stand")
                                .font(.headline)
                                .foregroundStyle(AscendTheme.emerald)
                            
                            Text(exercise.setupInstructions)
                                .font(.subheadline)
                                .foregroundStyle(AscendTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .glassCardStyle(cornerRadius: 16)
                        
                        // Execution Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Step 2: Execution & Movement", systemImage: "arrow.triangle.2.circlepath")
                                .font(.headline)
                                .foregroundStyle(AscendTheme.cyan)
                            
                            Text(exercise.executionInstructions)
                                .font(.subheadline)
                                .foregroundStyle(AscendTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .glassCardStyle(cornerRadius: 16)
                        
                        // Key Form Cues
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Key Form Cues", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundStyle(AscendTheme.amber)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(exercise.formCues, id: \.self) { cue in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(AscendTheme.emerald)
                                            .font(.subheadline)
                                        Text(cue)
                                            .font(.subheadline)
                                            .foregroundStyle(AscendTheme.textPrimary)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .glassCardStyle(cornerRadius: 16)
                        
                        // Common Mistakes to Avoid
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Mistakes to Avoid", systemImage: "exclamationmark.triangle.fill")
                                .font(.headline)
                                .foregroundStyle(AscendTheme.flame)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(exercise.commonMistakes, id: \.self) { mistake in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(AscendTheme.flame)
                                            .font(.subheadline)
                                        Text(mistake)
                                            .font(.subheadline)
                                            .foregroundStyle(AscendTheme.textSecondary)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .glassCardStyle(cornerRadius: 16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(width: geo.size.width)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
            .ascendBackground()
            .navigationTitle("Exercise Technique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(AscendTheme.emerald)
                }
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.muscleGroup.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AscendTheme.emerald.opacity(0.18))
                    .foregroundStyle(AscendTheme.emerald)
                    .clipShape(Capsule())
                
                Text(exercise.equipment.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AscendTheme.cyan.opacity(0.18))
                    .foregroundStyle(AscendTheme.cyan)
                    .clipShape(Capsule())
                
                Spacer()
                
                Label("\(exercise.defaultRestSeconds)s Rest", systemImage: "timer")
                    .font(.caption2.bold())
                    .foregroundStyle(AscendTheme.textSecondary)
            }
            
            Text(exercise.name)
                .font(.title2.bold())
                .foregroundStyle(AscendTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .glassCardStyle(cornerRadius: 20)
    }
}

