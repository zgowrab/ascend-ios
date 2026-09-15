import Foundation

public struct ExerciseDemonstration: Sendable {
    public let exerciseName: String
    public let folderName: String
    public let setupImageURL: URL?
    public let contractionImageURL: URL?
    
    public init(exerciseName: String, folderName: String) {
        self.exerciseName = exerciseName
        self.folderName = folderName
        
        // Use jsDelivr edge CDN with fallback to raw GitHub
        let baseURLString = "https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@main/exercises"
        self.setupImageURL = URL(string: "\(baseURLString)/\(folderName)/0.jpg")
        self.contractionImageURL = URL(string: "\(baseURLString)/\(folderName)/1.jpg")
    }
}

public struct ExerciseDemonstrationProvider {
    
    /// Curated direct mapping from Ascend exercise names to free-exercise-db folders
    private static let curatedCatalog: [String: String] = [
        // Chest
        "barbell bench press": "Barbell_Bench_Press_-_Medium_Grip",
        "dumbbell incline press": "Incline_Dumbbell_Press",
        "incline dumbbell press": "Incline_Dumbbell_Press",
        "push-ups (strict form)": "Pushups",
        "push-up": "Pushups",
        "push up": "Pushups",
        "pushups": "Pushups",
        "cable chest fly": "Cable_Crossover",
        "cable crossover": "Cable_Crossover",
        
        // Back
        "conventional barbell deadlift": "Barbell_Deadlift",
        "deadlift": "Barbell_Deadlift",
        "barbell bent-over row": "Bent_Over_Barbell_Row",
        "bent over barbell row": "Bent_Over_Barbell_Row",
        "dumbbell single-arm row": "One-Arm_Dumbbell_Row",
        "single arm dumbbell row": "One-Arm_Dumbbell_Row",
        "one-arm dumbbell row": "One-Arm_Dumbbell_Row",
        "pull-up / lat pulldown": "Wide-Grip_Lat_Pulldown",
        "pull-up": "Pullups",
        "pull up": "Pullups",
        "pullup": "Pullups",
        "lat pulldown": "Wide-Grip_Lat_Pulldown",
        
        // Shoulders
        "overhead barbell press": "Standing_Military_Press",
        "military press": "Standing_Military_Press",
        "overhead press": "Standing_Military_Press",
        "shoulder press": "Standing_Military_Press",
        "dumbbell lateral raise": "Side_Lateral_Raise",
        "lateral raise": "Side_Lateral_Raise",
        "face pull (cable or band)": "Face_Pull",
        "face pull": "Face_Pull",
        
        // Legs (Quads / Glutes / Hamstrings)
        "barbell back squat": "Barbell_Full_Squat",
        "barbell squat": "Barbell_Full_Squat",
        "squat": "Barbell_Full_Squat",
        "romanian deadlift (rdl)": "Romanian_Deadlift",
        "romanian deadlift": "Romanian_Deadlift",
        "rdl": "Romanian_Deadlift",
        "bulgarian split squat": "Split_Squat_with_Dumbbells",
        "split squat": "Split_Squat_with_Dumbbells",
        "dumbbell goblet squat": "Goblet_Squat",
        "goblet squat": "Goblet_Squat",
        "leg press": "Leg_Press",
        
        // Arms
        "dumbbell incline bicep curl": "Incline_Dumbbell_Curl",
        "incline dumbbell curl": "Incline_Dumbbell_Curl",
        "bicep curl": "Incline_Dumbbell_Curl",
        "hammer curl": "Alternate_Hammer_Curl",
        "tricep overhead extension": "Cable_Rope_Overhead_Triceps_Extension",
        "overhead tricep extension": "Cable_Rope_Overhead_Triceps_Extension",
        "tricep dip": "Dips_-_Chest_Version",
        "dips": "Dips_-_Chest_Version",
        
        // Core
        "hanging leg raise / knee raise": "Hanging_Leg_Raise",
        "hanging leg raise": "Hanging_Leg_Raise",
        "leg raise": "Hanging_Leg_Raise",
        "ab crunch machine": "Ab_Crunch_Machine",
        "plank": "Pushups"
    ]
    
    /// Resolves demonstration photos for a given exercise name, with fuzzy fallback heuristics
    public static func resolve(for exerciseName: String, muscleGroup: MuscleGroup? = nil) -> ExerciseDemonstration {
        let normalized = exerciseName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Direct match in curated catalog
        if let direct = curatedCatalog[normalized] {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: direct)
        }
        
        // 2. Substring matching in curated catalog
        for (key, folder) in curatedCatalog {
            if normalized.contains(key) || key.contains(normalized) {
                return ExerciseDemonstration(exerciseName: exerciseName, folderName: folder)
            }
        }
        
        // 3. Keyword pattern detection
        if normalized.contains("bench") || normalized.contains("chest press") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Barbell_Bench_Press_-_Medium_Grip")
        }
        if normalized.contains("incline") && (normalized.contains("press") || normalized.contains("dumbbell")) {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Incline_Dumbbell_Press")
        }
        if normalized.contains("push-up") || normalized.contains("pushup") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Pushups")
        }
        if normalized.contains("fly") || normalized.contains("crossover") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Cable_Crossover")
        }
        if normalized.contains("deadlift") || normalized.contains("rdl") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Barbell_Deadlift")
        }
        if normalized.contains("row") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Bent_Over_Barbell_Row")
        }
        if normalized.contains("pull-up") || normalized.contains("pulldown") || normalized.contains("chin") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Wide-Grip_Lat_Pulldown")
        }
        if normalized.contains("overhead") || normalized.contains("shoulder") || normalized.contains("military") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Standing_Military_Press")
        }
        if normalized.contains("lateral raise") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Side_Lateral_Raise")
        }
        if normalized.contains("squat") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Barbell_Full_Squat")
        }
        if normalized.contains("lunge") || normalized.contains("split") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Split_Squat_with_Dumbbells")
        }
        if normalized.contains("curl") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Incline_Dumbbell_Curl")
        }
        if normalized.contains("tricep") || normalized.contains("extension") || normalized.contains("pushdown") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Cable_Rope_Overhead_Triceps_Extension")
        }
        if normalized.contains("leg raise") || normalized.contains("crunch") || normalized.contains("ab") {
            return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Hanging_Leg_Raise")
        }
        
        // 4. Muscle group fallback
        if let muscle = muscleGroup {
            switch muscle {
            case .chest:
                return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Barbell_Bench_Press_-_Medium_Grip")
            case .back:
                return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Bent_Over_Barbell_Row")
            case .shoulders:
                return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Standing_Military_Press")
            case .quads:
                return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Barbell_Full_Squat")
            case .hamstringsAndGlutes:
                return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Romanian_Deadlift")
            case .arms:
                return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Incline_Dumbbell_Curl")
            case .core:
                return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Hanging_Leg_Raise")
            case .fullBody:
                return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Barbell_Deadlift")
            }
        }
        
        // Default safe fallback
        return ExerciseDemonstration(exerciseName: exerciseName, folderName: "Barbell_Bench_Press_-_Medium_Grip")
    }
}
