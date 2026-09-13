import SwiftUI
import SwiftData

@MainActor
@Observable
public final class AppState {
    public var selectedTab: Int = 0
    public var activeSession: WorkoutSession?
    public var isWorkoutInProgress: Bool = false
    
    // Rest Timer State
    public var isRestTimerActive: Bool = false
    public var restTimerTotalSeconds: Int = 90
    public var restTimerRemainingSeconds: Int = 90
    public var isRestTimerRunning: Bool = false
    
    // Selected Exercise for detail inspection
    public var inspectExercise: ExerciseDefinition?
    
    public init() {}
    
    public func startWorkout(routine: Routine, day: RoutineDay) {
        let session = WorkoutSession(
            routineName: routine.name,
            dayName: day.dayName,
            date: Date(),
            durationSeconds: 0,
            isCompleted: false,
            notes: ""
        )
        
        // Pre-create planned sets for each exercise in day
        var createdSets: [ExerciseSetRecord] = []
        for exercise in day.exercises.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            for setNum in 1...exercise.targetSets {
                let setRecord = ExerciseSetRecord(
                    exerciseName: exercise.exerciseName,
                    setNumber: setNum,
                    weightKg: 0.0,
                    reps: Int(exercise.targetReps.split(separator: "-").first ?? "10") ?? 10,
                    rpe: exercise.targetRPE,
                    isCompleted: false
                )
                setRecord.session = session
                createdSets.append(setRecord)
            }
        }
        session.sets = createdSets
        self.activeSession = session
        self.isWorkoutInProgress = true
    }
    
    public func triggerRestTimer(seconds: Int = 90) {
        self.restTimerTotalSeconds = seconds
        self.restTimerRemainingSeconds = seconds
        self.isRestTimerRunning = true
        self.isRestTimerActive = true
    }
    
    public func dismissRestTimer() {
        self.isRestTimerActive = false
        self.isRestTimerRunning = false
    }
    
    public func finishWorkout() {
        if let session = activeSession {
            session.isCompleted = true
        }
        self.isWorkoutInProgress = false
        self.activeSession = nil
        dismissRestTimer()
    }
}
