import Foundation
import SwiftData

public enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "Chest"
    case back = "Back (Lats & Traps)"
    case shoulders = "Shoulders (Deltoids)"
    case quads = "Quads"
    case hamstringsAndGlutes = "Hamstrings & Glutes"
    case arms = "Biceps & Triceps"
    case core = "Core & Abs"
    case fullBody = "Full Body"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rower"
        case .shoulders: return "figure.arms.open"
        case .quads: return "figure.walk"
        case .hamstringsAndGlutes: return "figure.step.training"
        case .arms: return "figure.boxing"
        case .core: return "figure.core.training"
        case .fullBody: return "figure.cross.training"
        }
    }
}

public enum EquipmentRequired: String, Codable, CaseIterable, Identifiable {
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case cable = "Cable Stack"
    case machine = "Machine"
    case bodyweight = "Bodyweight"
    case resistanceBand = "Resistance Band"
    
    public var id: String { rawValue }
}

@Model
public final class ExerciseDefinition {
    public var id: UUID
    public var name: String
    public var muscleGroupRaw: String
    public var equipmentRaw: String
    public var setupInstructions: String
    public var executionInstructions: String
    public var formCues: [String]
    public var commonMistakes: [String]
    public var isCompound: Bool
    public var defaultRestSeconds: Int
    
    public init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        equipment: EquipmentRequired,
        setupInstructions: String,
        executionInstructions: String,
        formCues: [String],
        commonMistakes: [String],
        isCompound: Bool = true,
        defaultRestSeconds: Int = 90
    ) {
        self.id = id
        self.name = name
        self.muscleGroupRaw = muscleGroup.rawValue
        self.equipmentRaw = equipment.rawValue
        self.setupInstructions = setupInstructions
        self.executionInstructions = executionInstructions
        self.formCues = formCues
        self.commonMistakes = commonMistakes
        self.isCompound = isCompound
        self.defaultRestSeconds = defaultRestSeconds
    }
    
    public var muscleGroup: MuscleGroup {
        get { MuscleGroup(rawValue: muscleGroupRaw) ?? .chest }
        set { muscleGroupRaw = newValue.rawValue }
    }
    
    public var equipment: EquipmentRequired {
        get { EquipmentRequired(rawValue: equipmentRaw) ?? .dumbbell }
        set { equipmentRaw = newValue.rawValue }
    }
}

@Model
public final class Routine {
    public var id: UUID
    public var name: String
    public var subtitle: String
    public var targetGoalRaw: String
    public var equipmentTierRaw: String
    public var daysPerWeek: Int
    @Relationship(deleteRule: .cascade) public var days: [RoutineDay]
    
    public init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        targetGoal: FitnessGoal,
        equipmentTier: EquipmentAccess,
        daysPerWeek: Int,
        days: [RoutineDay] = []
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.targetGoalRaw = targetGoal.rawValue
        self.equipmentTierRaw = equipmentTier.rawValue
        self.daysPerWeek = daysPerWeek
        self.days = days
    }
}

@Model
public final class RoutineDay {
    public var id: UUID
    public var dayName: String
    public var orderIndex: Int
    @Relationship(deleteRule: .cascade) public var exercises: [RoutineExercise]
    public var routine: Routine?
    
    public init(
        id: UUID = UUID(),
        dayName: String,
        orderIndex: Int,
        exercises: [RoutineExercise] = []
    ) {
        self.id = id
        self.dayName = dayName
        self.orderIndex = orderIndex
        self.exercises = exercises
    }
}

@Model
public final class RoutineExercise {
    public var id: UUID
    public var orderIndex: Int
    public var exerciseName: String
    public var targetSets: Int
    public var targetReps: String
    public var targetRPE: Double
    public var restSeconds: Int
    public var day: RoutineDay?
    
    public init(
        id: UUID = UUID(),
        orderIndex: Int,
        exerciseName: String,
        targetSets: Int = 3,
        targetReps: String = "8-12",
        targetRPE: Double = 8.0,
        restSeconds: Int = 90
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.exerciseName = exerciseName
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetRPE = targetRPE
        self.restSeconds = restSeconds
    }
}

@Model
public final class WorkoutSession {
    public var id: UUID
    public var routineName: String
    public var dayName: String
    public var date: Date
    public var durationSeconds: Int
    public var isCompleted: Bool
    public var notes: String
    @Relationship(deleteRule: .cascade) public var sets: [ExerciseSetRecord]
    
    public init(
        id: UUID = UUID(),
        routineName: String,
        dayName: String,
        date: Date = Date(),
        durationSeconds: Int = 0,
        isCompleted: Bool = false,
        notes: String = "",
        sets: [ExerciseSetRecord] = []
    ) {
        self.id = id
        self.routineName = routineName
        self.dayName = dayName
        self.date = date
        self.durationSeconds = durationSeconds
        self.isCompleted = isCompleted
        self.notes = notes
        self.sets = sets
    }
    
    public var totalVolumeKg: Double {
        sets.filter { $0.isCompleted }.reduce(0) { $0 + ($1.weightKg * Double($1.reps)) }
    }
}

@Model
public final class ExerciseSetRecord {
    public var id: UUID
    public var exerciseName: String
    public var setNumber: Int
    public var weightKg: Double
    public var reps: Int
    public var rpe: Double
    public var isCompleted: Bool
    public var session: WorkoutSession?
    
    public init(
        id: UUID = UUID(),
        exerciseName: String,
        setNumber: Int,
        weightKg: Double = 0.0,
        reps: Int = 10,
        rpe: Double = 8.0,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.weightKg = weightKg
        self.reps = reps
        self.rpe = rpe
        self.isCompleted = isCompleted
    }
}
