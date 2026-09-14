import SwiftUI

public struct ExerciseDetailView: View {
    let exercise: ExerciseDefinition
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedVisualTab: Int = 0 // 0 = Kinematic Motion, 1 = Muscle Map
    @State private var audioCoach = WorkoutAudioCoachService.shared
    
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
                        
                        // Voice Coach Audio Bar
                        audioCoachBar
                        
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
                            HStack {
                                Label("Key Form Cues", systemImage: "sparkles")
                                    .font(.headline)
                                    .foregroundStyle(AscendTheme.amber)
                                
                                Spacer()
                                
                                Button {
                                    audioCoach.speakFormCues(name: exercise.name, cues: exercise.formCues)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "speaker.wave.2.fill")
                                        Text("Listen")
                                    }
                                    .font(.caption2.bold())
                                    .foregroundStyle(AscendTheme.amber)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AscendTheme.amber.opacity(0.15))
                                    .clipShape(Capsule())
                                }
                            }
                            
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
                        audioCoach.stopSpeaking()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(AscendTheme.emerald)
                }
            }
            .onDisappear {
                audioCoach.stopSpeaking()
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
    
    // MARK: - Audio Coach Bar
    private var audioCoachBar: some View {
        GlassCard(cornerRadius: 16, padding: 12) {
            HStack(spacing: 12) {
                // Coach Avatar / Icon
                ZStack {
                    Circle()
                        .fill(audioCoach.isSpeaking ? AscendTheme.emerald.opacity(0.25) : AscendTheme.bgElevated)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: audioCoach.isSpeaking ? "waveform" : "speaker.wave.2.fill")
                        .font(.body.bold())
                        .foregroundStyle(audioCoach.isSpeaking ? AscendTheme.emerald : AscendTheme.cyan)
                        .symbolEffect(.variableColor.iterative, isActive: audioCoach.isSpeaking)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(audioCoach.isSpeaking ? "COACH IS SPEAKING" : "VOICE TECHNIQUE COACH")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(audioCoach.isSpeaking ? AscendTheme.emerald : AscendTheme.cyan)
                        .tracking(1)
                    
                    Text(audioCoach.isSpeaking ? "Listening to step-by-step guidance..." : "Tap to hear audio form walkthrough")
                        .font(.caption2)
                        .foregroundStyle(AscendTheme.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if audioCoach.isSpeaking {
                    Button {
                        audioCoach.stopSpeaking()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.caption.bold())
                            .foregroundStyle(AscendTheme.flame)
                            .padding(8)
                            .background(AscendTheme.flame.opacity(0.15))
                            .clipShape(Circle())
                    }
                } else {
                    Button {
                        audioCoach.speakExerciseOverview(
                            name: exercise.name,
                            muscleGroup: exercise.muscleGroup.rawValue,
                            setup: exercise.setupInstructions,
                            execution: exercise.executionInstructions
                        )
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                            Text("Play")
                        }
                        .font(.caption.bold())
                        .foregroundStyle(AscendTheme.bgPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AscendTheme.emerald)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
