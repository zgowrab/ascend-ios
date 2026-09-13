import Foundation
import SwiftData

public struct RoutineGenerator {
    
    // MARK: - Exercise Catalog Seeding
    public static func defaultExerciseCatalog() -> [ExerciseDefinition] {
        return [
            // CHEST
            ExerciseDefinition(
                name: "Barbell Bench Press",
                muscleGroup: .chest,
                equipment: .barbell,
                setupInstructions: "Lie flat on the bench. Eyes directly under the bar. Plant feet flat on the floor. Grip the bar slightly wider than shoulder-width. Retract scapulae (shoulder blades together and down).",
                executionInstructions: "Unrack with straight arms. Inhale and lower bar with control to mid-chest (nipple line), tucking elbows at roughly 45-75 degrees. Touch lightly, then drive bar up explosively while pushing feet into the floor.",
                formCues: ["Pull shoulder blades into back pockets", "Leg drive through heels", "Bar touches mid-chest, not neck", "Squeeze chest at the top"],
                commonMistakes: ["Flaring elbows out at 90 degrees", "Bouncing bar off sternum", "Lifting hips off the bench"],
                isCompound: true,
                defaultRestSeconds: 120
            ),
            ExerciseDefinition(
                name: "Dumbbell Incline Press",
                muscleGroup: .chest,
                equipment: .dumbbell,
                setupInstructions: "Set bench angle to 30 degrees. Sit with dumbbells resting on thighs. Kick dumbbells up to shoulder level as you lean back. Arch upper back slightly.",
                executionInstructions: "Press dumbbells up in a slight arc towards the midline without clanking them together. Lower slowly over 3 seconds until elbows break 90 degrees and you feel a deep clavicular chest stretch.",
                formCues: ["30-degree incline, not too steep", "Control the 3-second descent", "Keep wrists stacked directly over elbows"],
                commonMistakes: ["Setting bench angle too high (overworks anterior delts)", "Short-ranging the bottom stretch"],
                isCompound: true,
                defaultRestSeconds: 90
            ),
            ExerciseDefinition(
                name: "Push-ups (Strict Form)",
                muscleGroup: .chest,
                equipment: .bodyweight,
                setupInstructions: "Hands just outside shoulder width on floor. Fingers slightly turned out. Body in a rigid plank from head to heels. Squeeze glutes and brace core.",
                executionInstructions: "Lower chest towards floor until chest is 1 inch off the ground. Keep elbows at a 45-degree angle to torso. Push ground away through entire palm.",
                formCues: ["Rigid plank, no sagging lower back", "Elbows trace an arrow shape (not a 'T')", "Full lockout at top"],
                commonMistakes: ["Hips sagging towards the floor", "Craning neck forward to fake depth"],
                isCompound: true,
                defaultRestSeconds: 60
            ),
            ExerciseDefinition(
                name: "Cable Chest Fly",
                muscleGroup: .chest,
                equipment: .cable,
                setupInstructions: "Set pulleys at chest height. Take handles, take one step forward into a staggered stance. Maintain slight bend in elbows.",
                executionInstructions: "Bring hands together in front of chest in a hugging motion. Pause and flex pecs hard for 1 second. Open arms back smoothly feeling the chest stretch.",
                formCues: ["Imagine hugging a large barrel", "Hold peak contraction for 1 second", "Keep chest proud"],
                commonMistakes: ["Bending and straightening elbows like a press", "Using excessive momentum"],
                isCompound: false,
                defaultRestSeconds: 60
            ),
            
            // BACK
            ExerciseDefinition(
                name: "Conventional Barbell Deadlift",
                muscleGroup: .back,
                equipment: .barbell,
                setupInstructions: "Feet hip-width apart under bar; bar over mid-foot. Hinge at hips and grip bar outside legs. Pull chest up, flatten back, wedge hips into bar, pull slack out of bar.",
                executionInstructions: "Drive the floor away with legs. Keep bar dragging along shins and thighs. Stand tall, locking hips and knees simultaneously. Reverse motion under control.",
                formCues: ["Pull the slack out before lifting", "Push floor away like a leg press", "Bar stays glued to legs", "Neutral spine throughout"],
                commonMistakes: ["Rounding the lumbar spine", "Jerking the bar off the floor", "Hyperextending lower back at lockout"],
                isCompound: true,
                defaultRestSeconds: 150
            ),
            ExerciseDefinition(
                name: "Barbell Bent-Over Row",
                muscleGroup: .back,
                equipment: .barbell,
                setupInstructions: "Stand with feet shoulder-width. Hinge at hips to a 45-degree torso angle with flat back. Grip bar slightly wider than shoulder width.",
                executionInstructions: "Pull elbows back towards hips, bringing bar to lower ribcage/belly button. Squeeze lats and rhomboids for a brief pause. Lower with control without letting shoulders round.",
                formCues: ["Pull with elbows, not hands", "Brace core hard to support lower back", "Keep torso motionless"],
                commonMistakes: ["Standing up too tall and turning it into a shrug", "Bouncing torso up and down"],
                isCompound: true,
                defaultRestSeconds: 90
            ),
            ExerciseDefinition(
                name: "Dumbbell Single-Arm Row",
                muscleGroup: .back,
                equipment: .dumbbell,
                setupInstructions: "Place one knee and hand on a flat bench. Keep back flat and spine neutral. Hold dumbbell in free hand hanging straight down.",
                executionInstructions: "Pull dumbbell back towards your hip pocket, keeping elbow close to torso. Feel the lat cramp at the top. Lower slowly under full stretch.",
                formCues: ["Pull dumbbell to hip pocket, not armpit", "Do not rotate torso at the top", "Feel full lat stretch at bottom"],
                commonMistakes: ["Yanking with torso rotation", "Dropping the weight rapidly"],
                isCompound: true,
                defaultRestSeconds: 60
            ),
            ExerciseDefinition(
                name: "Pull-Up / Lat Pulldown",
                muscleGroup: .back,
                equipment: .bodyweight,
                setupInstructions: "Hang from pull-up bar with overhand grip just outside shoulders. Depress scapulae (pull shoulders away from ears) to engage lats.",
                executionInstructions: "Drive elbows down towards hips until chin clears bar or bar touches upper chest. Pause briefly, then lower slowly over 3 seconds to a dead hang.",
                formCues: ["Drive elbows down, not back", "Chest up to the bar", "Control the negative"],
                commonMistakes: ["Kicking or kipping with legs", "Cutting range of motion halfway"],
                isCompound: true,
                defaultRestSeconds: 90
            ),
            
            // SHOULDERS
            ExerciseDefinition(
                name: "Overhead Barbell Press",
                muscleGroup: .shoulders,
                equipment: .barbell,
                setupInstructions: "Stand with feet shoulder-width. Bar resting on anterior deltoids and clavicles. Forearms vertical. Squeeze glutes and core rock-solid.",
                executionInstructions: "Pull head back slightly to clear chin, press bar straight up over mid-foot. Push head forward through 'the window' at top lockout.",
                formCues: ["Glutes squeezed tight to protect lower back", "Vertical forearm bar path", "Lock elbows overhead"],
                commonMistakes: ["Leaning back excessively to turn it into an incline bench", "Pressing bar forward in a curve"],
                isCompound: true,
                defaultRestSeconds: 120
            ),
            ExerciseDefinition(
                name: "Dumbbell Lateral Raise",
                muscleGroup: .shoulders,
                equipment: .dumbbell,
                setupInstructions: "Stand with dumbbells at sides, slight hinge at hips (10 degrees forward). Slight bend in elbows (not locked, not 90 degrees).",
                executionInstructions: "Raise arms out to sides in the scapular plane (slightly in front of body) until parallel to floor. Lead with elbows. Lower slowly.",
                formCues: ["Lead with elbows and knuckles", "Raise in the scapular plane (30 deg forward)", "Do not shrug with traps"],
                commonMistakes: ["Using body swing to throw heavy dumbbells", "Shrugging neck up"],
                isCompound: false,
                defaultRestSeconds: 60
            ),
            ExerciseDefinition(
                name: "Face Pull (Cable or Band)",
                muscleGroup: .shoulders,
                equipment: .cable,
                setupInstructions: "Attach rope to cable at eye height. Hold rope with thumbs facing backwards. Step back with arms extended.",
                executionInstructions: "Pull rope directly towards forehead while pulling rope ends apart. Rotate hands back so thumbs finish behind ears (external rotation).",
                formCues: ["Double biceps pose at the finish", "Squeeze rear delts and mid traps", "Great for posture and shoulder health"],
                commonMistakes: ["Pulling down to chest instead of face", "Collapsing elbows low"],
                isCompound: false,
                defaultRestSeconds: 60
            ),
            
            // LEGS (QUADS & GLUTES)
            ExerciseDefinition(
                name: "Barbell Back Squat",
                muscleGroup: .quads,
                equipment: .barbell,
                setupInstructions: "Bar across upper traps (high bar) or rear delts (low bar). Feet slightly wider than shoulder width, toes angled 15-30 degrees out. Take big diaphragmatic breath into abdomen.",
                executionInstructions: "Break at hips and knees simultaneously. Push knees out tracking over toes. Descend until hip crease is below top of knee (parallel or deeper). Drive through mid-foot to stand.",
                formCues: ["Breathe and brace core 360 degrees", "Knees track over toes", "Chest stays proud", "Drive hips up uniformly with chest"],
                commonMistakes: ["Knees caving inward (valgus)", "Chest collapsing forward (good morning squat)", "Cutting depth high"],
                isCompound: true,
                defaultRestSeconds: 150
            ),
            ExerciseDefinition(
                name: "Dumbbell Goblet Squat",
                muscleGroup: .quads,
                equipment: .dumbbell,
                setupInstructions: "Hold one dumbbell vertically against chest with both palms supporting the top bell. Feet shoulder-width apart.",
                executionInstructions: "Squat down keeping torso upright. Allow elbows to track inside knees at bottom. Stand up driving through whole foot.",
                formCues: ["Keep dumbbell glued to sternum", "Sit between your hips", "Elbows inside knees at depth"],
                commonMistakes: ["Leaning forward away from weight", "Rising on toes"],
                isCompound: true,
                defaultRestSeconds: 75
            ),
            ExerciseDefinition(
                name: "Bulgarian Split Squat",
                muscleGroup: .quads,
                equipment: .dumbbell,
                setupInstructions: "Stand 2-3 feet in front of bench. Place top of rear foot on bench. Hold dumbbells at sides. Torso upright or slight 15-degree forward lean for glute emphasis.",
                executionInstructions: "Lower hips down until front thigh is parallel to ground and back knee is 1-2 inches above floor. Drive through front heel to return to top.",
                formCues: ["80% of weight is on the front leg", "Front knee stays stable", "Unilateral leg builder"],
                commonMistakes: ["Front foot placed too close or far from bench", "Allowing front knee to wobble"],
                isCompound: true,
                defaultRestSeconds: 75
            ),
            ExerciseDefinition(
                name: "Romanian Deadlift (RDL)",
                muscleGroup: .hamstringsAndGlutes,
                equipment: .dumbbell,
                setupInstructions: "Stand tall holding dumbbells in front of thighs. Soft bend in knees (fix knee angle). Squeeze lats.",
                executionInstructions: "Push hips backwards towards the back wall as if closing a door with glutes. Slide dumbbells down shins until deep hamstring stretch is felt (around mid-shin). Drive hips forward to stand.",
                formCues: ["Hip hinge: hips travel back, not down", "Spine stays strictly flat", "Knees do not bend further during descent"],
                commonMistakes: ["Squatting down instead of hinging", "Rounding lower back at bottom"],
                isCompound: true,
                defaultRestSeconds: 90
            ),
            
            // ARMS
            ExerciseDefinition(
                name: "Dumbbell Incline Bicep Curl",
                muscleGroup: .arms,
                equipment: .dumbbell,
                setupInstructions: "Sit on bench at 45-60 degree incline. Hold dumbbells hanging straight down behind torso with arms fully extended.",
                executionInstructions: "Curl dumbbells up while supinating wrists (palms facing up). Keep elbows pinned back. Squeeze biceps hard at top, lower slowly over 3 seconds.",
                formCues: ["Elbows stay behind torso for long head stretch", "Supinate wrist as you curl", "Controlled 3-second negative"],
                commonMistakes: ["Swinging elbows forward to cheat", "Using momentum"],
                isCompound: false,
                defaultRestSeconds: 60
            ),
            ExerciseDefinition(
                name: "Tricep Overhead Extension",
                muscleGroup: .arms,
                equipment: .dumbbell,
                setupInstructions: "Sit or stand tall. Hold one dumbbell with both hands overhead in diamond grip. Lock ribs down.",
                executionInstructions: "Lower dumbbell behind head by bending at elbows only. Keep upper arms close to ears. Extend elbows back to lockout.",
                formCues: ["Elbows pointed forward, not flared out", "Feel deep triceps stretch at bottom", "Full contraction at top"],
                commonMistakes: ["Arching lower back heavily", "Flaring elbows wide"],
                isCompound: false,
                defaultRestSeconds: 60
            ),
            
            // CORE
            ExerciseDefinition(
                name: "Hanging Leg Raise / Knee Raise",
                muscleGroup: .core,
                equipment: .bodyweight,
                setupInstructions: "Hang from pull-up bar with overhand grip. Depress shoulders. Keep legs together.",
                executionInstructions: "Contract lower abs and tilt pelvis up to raise knees (or straight legs) towards chest. Pause 1 second at top, lower slowly with zero swing.",
                formCues: ["Tilt pelvis upward, don't just swing hip flexors", "Control the descent to eliminate swing", "Exhale fully at the top"],
                commonMistakes: ["Swinging body back and forth", "Relying purely on hip flexors"],
                isCompound: false,
                defaultRestSeconds: 60
            )
        ]
    }
    
    // MARK: - Routine Generation
    public static func generatePersonalizedRoutine(for profile: UserProfile) -> Routine {
        let equipment = profile.equipment
        let daysCount = profile.trainingDaysPerWeek
        let goal = profile.goal
        
        switch (equipment, daysCount) {
        case (.commercialGym, 4):
            return build4DayUpperLowerCommercial(goal: goal)
        case (.commercialGym, 5):
            return build5DayPPLUpperLowerCommercial(goal: goal)
        case (.commercialGym, 6):
            return build6DayPPLCommercial(goal: goal)
        case (.commercialGym, _):
            return build3DayFullBodyCommercial(goal: goal)
            
        case (.homeGym, 4):
            return build4DayHomeGym(goal: goal)
        case (.homeGym, _):
            return build3DayHomeGym(goal: goal)
            
        case (.dumbbellsOnly, 4):
            return build4DayDumbbellSplit(goal: goal)
        case (.dumbbellsOnly, _):
            return build3DayDumbbellFullBody(goal: goal)
            
        case (.bodyweight, _):
            return buildBodyweightCalisthenicsRoutine(days: daysCount, goal: goal)
            
        case (.resistanceBands, _):
            return buildBandsRoutine(days: daysCount, goal: goal)
        }
    }
    
    // MARK: - Pre-configured Splitting
    private static func build4DayUpperLowerCommercial(goal: FitnessGoal) -> Routine {
        let day1 = RoutineDay(dayName: "Day 1: Upper Power & Hypertrophy", orderIndex: 1, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Barbell Bench Press", targetSets: 4, targetReps: "6-8", targetRPE: 8.5, restSeconds: 120),
            RoutineExercise(orderIndex: 2, exerciseName: "Barbell Bent-Over Row", targetSets: 4, targetReps: "8-10", targetRPE: 8.0, restSeconds: 90),
            RoutineExercise(orderIndex: 3, exerciseName: "Overhead Barbell Press", targetSets: 3, targetReps: "8-10", targetRPE: 8.0, restSeconds: 90),
            RoutineExercise(orderIndex: 4, exerciseName: "Pull-Up / Lat Pulldown", targetSets: 3, targetReps: "8-12", targetRPE: 8.5, restSeconds: 90),
            RoutineExercise(orderIndex: 5, exerciseName: "Dumbbell Lateral Raise", targetSets: 3, targetReps: "12-15", targetRPE: 9.0, restSeconds: 60),
            RoutineExercise(orderIndex: 6, exerciseName: "Tricep Overhead Extension", targetSets: 3, targetReps: "10-12", targetRPE: 8.5, restSeconds: 60)
        ])
        
        let day2 = RoutineDay(dayName: "Day 2: Lower Power & Quads", orderIndex: 2, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Barbell Back Squat", targetSets: 4, targetReps: "6-8", targetRPE: 8.5, restSeconds: 150),
            RoutineExercise(orderIndex: 2, exerciseName: "Romanian Deadlift (RDL)", targetSets: 3, targetReps: "8-10", targetRPE: 8.0, restSeconds: 120),
            RoutineExercise(orderIndex: 3, exerciseName: "Bulgarian Split Squat", targetSets: 3, targetReps: "10-12", targetRPE: 8.5, restSeconds: 90),
            RoutineExercise(orderIndex: 4, exerciseName: "Hanging Leg Raise / Knee Raise", targetSets: 3, targetReps: "12-15", targetRPE: 8.5, restSeconds: 60)
        ])
        
        let day3 = RoutineDay(dayName: "Day 3: Upper Hypertrophy & Volume", orderIndex: 3, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Dumbbell Incline Press", targetSets: 4, targetReps: "8-12", targetRPE: 8.5, restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Dumbbell Single-Arm Row", targetSets: 4, targetReps: "10-12", targetRPE: 8.0, restSeconds: 75),
            RoutineExercise(orderIndex: 3, exerciseName: "Cable Chest Fly", targetSets: 3, targetReps: "12-15", targetRPE: 9.0, restSeconds: 60),
            RoutineExercise(orderIndex: 4, exerciseName: "Face Pull (Cable or Band)", targetSets: 4, targetReps: "15-20", targetRPE: 8.5, restSeconds: 60),
            RoutineExercise(orderIndex: 5, exerciseName: "Dumbbell Incline Bicep Curl", targetSets: 3, targetReps: "10-12", targetRPE: 8.5, restSeconds: 60)
        ])
        
        let day4 = RoutineDay(dayName: "Day 4: Lower Posterior & Posterior Chain", orderIndex: 4, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Conventional Barbell Deadlift", targetSets: 3, targetReps: "5-6", targetRPE: 8.5, restSeconds: 180),
            RoutineExercise(orderIndex: 2, exerciseName: "Dumbbell Goblet Squat", targetSets: 3, targetReps: "12-15", targetRPE: 8.0, restSeconds: 75),
            RoutineExercise(orderIndex: 3, exerciseName: "Bulgarian Split Squat", targetSets: 3, targetReps: "10-12", targetRPE: 8.5, restSeconds: 90),
            RoutineExercise(orderIndex: 4, exerciseName: "Hanging Leg Raise / Knee Raise", targetSets: 3, targetReps: "12-15", targetRPE: 8.0, restSeconds: 60)
        ])
        
        return Routine(
            name: "Upper / Lower Ascend Cycle",
            subtitle: "4-Day Hypertrophy & Strength with optimal frequency and recovery",
            targetGoal: goal,
            equipmentTier: .commercialGym,
            daysPerWeek: 4,
            days: [day1, day2, day3, day4]
        )
    }
    
    private static func build5DayPPLUpperLowerCommercial(goal: FitnessGoal) -> Routine {
        let p1 = RoutineDay(dayName: "Day 1: Push (Chest, Delts, Triceps)", orderIndex: 1, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Barbell Bench Press", targetSets: 4, targetReps: "6-8", restSeconds: 120),
            RoutineExercise(orderIndex: 2, exerciseName: "Dumbbell Incline Press", targetSets: 3, targetReps: "8-12", restSeconds: 90),
            RoutineExercise(orderIndex: 3, exerciseName: "Overhead Barbell Press", targetSets: 3, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 4, exerciseName: "Dumbbell Lateral Raise", targetSets: 4, targetReps: "12-15", restSeconds: 60),
            RoutineExercise(orderIndex: 5, exerciseName: "Tricep Overhead Extension", targetSets: 3, targetReps: "10-12", restSeconds: 60)
        ])
        let p2 = RoutineDay(dayName: "Day 2: Pull (Back, Rear Delts, Biceps)", orderIndex: 2, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Barbell Bent-Over Row", targetSets: 4, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Pull-Up / Lat Pulldown", targetSets: 4, targetReps: "8-12", restSeconds: 90),
            RoutineExercise(orderIndex: 3, exerciseName: "Dumbbell Single-Arm Row", targetSets: 3, targetReps: "10-12", restSeconds: 60),
            RoutineExercise(orderIndex: 4, exerciseName: "Face Pull (Cable or Band)", targetSets: 4, targetReps: "15-20", restSeconds: 60),
            RoutineExercise(orderIndex: 5, exerciseName: "Dumbbell Incline Bicep Curl", targetSets: 3, targetReps: "10-12", restSeconds: 60)
        ])
        let p3 = RoutineDay(dayName: "Day 3: Legs (Quads, Glutes, Abs)", orderIndex: 3, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Barbell Back Squat", targetSets: 4, targetReps: "6-8", restSeconds: 150),
            RoutineExercise(orderIndex: 2, exerciseName: "Romanian Deadlift (RDL)", targetSets: 3, targetReps: "8-10", restSeconds: 120),
            RoutineExercise(orderIndex: 3, exerciseName: "Bulgarian Split Squat", targetSets: 3, targetReps: "10-12", restSeconds: 90),
            RoutineExercise(orderIndex: 4, exerciseName: "Hanging Leg Raise / Knee Raise", targetSets: 3, targetReps: "12-15", restSeconds: 60)
        ])
        let p4 = RoutineDay(dayName: "Day 4: Upper Hybrid", orderIndex: 4, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Dumbbell Incline Press", targetSets: 4, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Barbell Bent-Over Row", targetSets: 4, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 3, exerciseName: "Cable Chest Fly", targetSets: 3, targetReps: "12-15", restSeconds: 60),
            RoutineExercise(orderIndex: 4, exerciseName: "Dumbbell Lateral Raise", targetSets: 4, targetReps: "12-15", restSeconds: 60)
        ])
        let p5 = RoutineDay(dayName: "Day 5: Lower Posterior & Deadlift", orderIndex: 5, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Conventional Barbell Deadlift", targetSets: 3, targetReps: "5", restSeconds: 180),
            RoutineExercise(orderIndex: 2, exerciseName: "Dumbbell Goblet Squat", targetSets: 3, targetReps: "12-15", restSeconds: 75),
            RoutineExercise(orderIndex: 3, exerciseName: "Hanging Leg Raise / Knee Raise", targetSets: 3, targetReps: "15", restSeconds: 60)
        ])
        return Routine(
            name: "5-Day Push / Pull / Legs / Upper / Lower",
            subtitle: "High-frequency elite hypertrophy program",
            targetGoal: goal,
            equipmentTier: .commercialGym,
            daysPerWeek: 5,
            days: [p1, p2, p3, p4, p5]
        )
    }
    
    private static func build6DayPPLCommercial(goal: FitnessGoal) -> Routine {
        let base = build5DayPPLUpperLowerCommercial(goal: goal)
        return Routine(
            name: "6-Day Push / Pull / Legs 2x",
            subtitle: "Maximum volume split for dedicated recovery and adaptation",
            targetGoal: goal,
            equipmentTier: .commercialGym,
            daysPerWeek: 6,
            days: base.days
        )
    }
    
    private static func build3DayFullBodyCommercial(goal: FitnessGoal) -> Routine {
        let day1 = RoutineDay(dayName: "Workout A: Squat & Bench Foundation", orderIndex: 1, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Barbell Back Squat", targetSets: 3, targetReps: "6-8", restSeconds: 120),
            RoutineExercise(orderIndex: 2, exerciseName: "Barbell Bench Press", targetSets: 3, targetReps: "6-8", restSeconds: 120),
            RoutineExercise(orderIndex: 3, exerciseName: "Barbell Bent-Over Row", targetSets: 3, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 4, exerciseName: "Dumbbell Lateral Raise", targetSets: 3, targetReps: "12-15", restSeconds: 60)
        ])
        let day2 = RoutineDay(dayName: "Workout B: Deadlift & Overhead Focus", orderIndex: 2, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Conventional Barbell Deadlift", targetSets: 3, targetReps: "5", restSeconds: 180),
            RoutineExercise(orderIndex: 2, exerciseName: "Overhead Barbell Press", targetSets: 3, targetReps: "6-8", restSeconds: 120),
            RoutineExercise(orderIndex: 3, exerciseName: "Pull-Up / Lat Pulldown", targetSets: 3, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 4, exerciseName: "Bulgarian Split Squat", targetSets: 3, targetReps: "10-12", restSeconds: 90)
        ])
        let day3 = RoutineDay(dayName: "Workout C: Full Body Hypertrophy & Volume", orderIndex: 3, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Dumbbell Incline Press", targetSets: 3, targetReps: "8-12", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Romanian Deadlift (RDL)", targetSets: 3, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 3, exerciseName: "Dumbbell Single-Arm Row", targetSets: 3, targetReps: "10-12", restSeconds: 75),
            RoutineExercise(orderIndex: 4, exerciseName: "Hanging Leg Raise / Knee Raise", targetSets: 3, targetReps: "12-15", restSeconds: 60)
        ])
        return Routine(
            name: "3-Day Full Body Compounding",
            subtitle: "High efficiency full body routines with 48h rest intervals",
            targetGoal: goal,
            equipmentTier: .commercialGym,
            daysPerWeek: 3,
            days: [day1, day2, day3]
        )
    }
    
    // MARK: - Dumbbell & Home Splitting
    private static func build4DayDumbbellSplit(goal: FitnessGoal) -> Routine {
        let d1 = RoutineDay(dayName: "Day 1: Dumbbell Upper Push & Pull", orderIndex: 1, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Dumbbell Incline Press", targetSets: 4, targetReps: "8-12", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Dumbbell Single-Arm Row", targetSets: 4, targetReps: "10-12", restSeconds: 75),
            RoutineExercise(orderIndex: 3, exerciseName: "Dumbbell Lateral Raise", targetSets: 3, targetReps: "12-15", restSeconds: 60),
            RoutineExercise(orderIndex: 4, exerciseName: "Dumbbell Incline Bicep Curl", targetSets: 3, targetReps: "10-12", restSeconds: 60),
            RoutineExercise(orderIndex: 5, exerciseName: "Tricep Overhead Extension", targetSets: 3, targetReps: "10-12", restSeconds: 60)
        ])
        let d2 = RoutineDay(dayName: "Day 2: Dumbbell Lower Legs & Core", orderIndex: 2, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Dumbbell Goblet Squat", targetSets: 4, targetReps: "10-12", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Romanian Deadlift (RDL)", targetSets: 4, targetReps: "10-12", restSeconds: 90),
            RoutineExercise(orderIndex: 3, exerciseName: "Bulgarian Split Squat", targetSets: 3, targetReps: "10-12", restSeconds: 75),
            RoutineExercise(orderIndex: 4, exerciseName: "Push-ups (Strict Form)", targetSets: 3, targetReps: "15-20", restSeconds: 60)
        ])
        let d3 = RoutineDay(dayName: "Day 3: Dumbbell Upper Volume", orderIndex: 3, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Push-ups (Strict Form)", targetSets: 4, targetReps: "12-20", restSeconds: 75),
            RoutineExercise(orderIndex: 2, exerciseName: "Dumbbell Single-Arm Row", targetSets: 4, targetReps: "10-12", restSeconds: 75),
            RoutineExercise(orderIndex: 3, exerciseName: "Dumbbell Lateral Raise", targetSets: 4, targetReps: "15-20", restSeconds: 60),
            RoutineExercise(orderIndex: 4, exerciseName: "Dumbbell Incline Bicep Curl", targetSets: 3, targetReps: "12", restSeconds: 60)
        ])
        let d4 = RoutineDay(dayName: "Day 4: Dumbbell Posterior & Unilateral", orderIndex: 4, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Romanian Deadlift (RDL)", targetSets: 4, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Bulgarian Split Squat", targetSets: 3, targetReps: "10-12", restSeconds: 75),
            RoutineExercise(orderIndex: 3, exerciseName: "Dumbbell Goblet Squat", targetSets: 3, targetReps: "12-15", restSeconds: 75),
            RoutineExercise(orderIndex: 4, exerciseName: "Push-ups (Strict Form)", targetSets: 3, targetReps: "15", restSeconds: 60)
        ])
        return Routine(
            name: "Dumbbell Precision 4-Day Split",
            subtitle: "Full-body hypertrophy engineered exclusively for dumbbells and bench/floor",
            targetGoal: goal,
            equipmentTier: .dumbbellsOnly,
            daysPerWeek: 4,
            days: [d1, d2, d3, d4]
        )
    }
    
    private static func build3DayDumbbellFullBody(goal: FitnessGoal) -> Routine {
        let d1 = RoutineDay(dayName: "Workout 1: Dumbbell Full Body A", orderIndex: 1, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Dumbbell Goblet Squat", targetSets: 3, targetReps: "10-12", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Dumbbell Incline Press", targetSets: 3, targetReps: "8-12", restSeconds: 90),
            RoutineExercise(orderIndex: 3, exerciseName: "Dumbbell Single-Arm Row", targetSets: 3, targetReps: "10-12", restSeconds: 75),
            RoutineExercise(orderIndex: 4, exerciseName: "Dumbbell Lateral Raise", targetSets: 3, targetReps: "12-15", restSeconds: 60)
        ])
        let d2 = RoutineDay(dayName: "Workout 2: Dumbbell Full Body B", orderIndex: 2, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Romanian Deadlift (RDL)", targetSets: 3, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Push-ups (Strict Form)", targetSets: 3, targetReps: "12-15", restSeconds: 60),
            RoutineExercise(orderIndex: 3, exerciseName: "Bulgarian Split Squat", targetSets: 3, targetReps: "10-12", restSeconds: 75),
            RoutineExercise(orderIndex: 4, exerciseName: "Tricep Overhead Extension", targetSets: 3, targetReps: "10-12", restSeconds: 60)
        ])
        let d3 = RoutineDay(dayName: "Workout 3: Dumbbell Full Body C", orderIndex: 3, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Dumbbell Goblet Squat", targetSets: 3, targetReps: "12-15", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Dumbbell Incline Press", targetSets: 3, targetReps: "10-12", restSeconds: 90),
            RoutineExercise(orderIndex: 3, exerciseName: "Dumbbell Single-Arm Row", targetSets: 3, targetReps: "10-12", restSeconds: 75),
            RoutineExercise(orderIndex: 4, exerciseName: "Dumbbell Incline Bicep Curl", targetSets: 3, targetReps: "10-12", restSeconds: 60)
        ])
        return Routine(
            name: "Dumbbell 3-Day Full Body",
            subtitle: "3 days of high-intensity dumbbell compounds",
            targetGoal: goal,
            equipmentTier: .dumbbellsOnly,
            daysPerWeek: 3,
            days: [d1, d2, d3]
        )
    }
    
    private static func build4DayHomeGym(goal: FitnessGoal) -> Routine {
        return build4DayUpperLowerCommercial(goal: goal)
    }
    
    private static func build3DayHomeGym(goal: FitnessGoal) -> Routine {
        return build3DayFullBodyCommercial(goal: goal)
    }
    
    private static func buildBodyweightCalisthenicsRoutine(days: Int, goal: FitnessGoal) -> Routine {
        let d1 = RoutineDay(dayName: "Session 1: Calisthenics Push & Legs", orderIndex: 1, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Push-ups (Strict Form)", targetSets: 4, targetReps: "15-20", restSeconds: 60),
            RoutineExercise(orderIndex: 2, exerciseName: "Bulgarian Split Squat", targetSets: 4, targetReps: "15 each", restSeconds: 60),
            RoutineExercise(orderIndex: 3, exerciseName: "Hanging Leg Raise / Knee Raise", targetSets: 4, targetReps: "12-15", restSeconds: 60)
        ])
        let d2 = RoutineDay(dayName: "Session 2: Calisthenics Pull & Posterior", orderIndex: 2, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Pull-Up / Lat Pulldown", targetSets: 4, targetReps: "8-12", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Push-ups (Strict Form)", targetSets: 3, targetReps: "12-15", restSeconds: 60),
            RoutineExercise(orderIndex: 3, exerciseName: "Hanging Leg Raise / Knee Raise", targetSets: 3, targetReps: "15", restSeconds: 60)
        ])
        let d3 = RoutineDay(dayName: "Session 3: Full Body Density", orderIndex: 3, exercises: [
            RoutineExercise(orderIndex: 1, exerciseName: "Pull-Up / Lat Pulldown", targetSets: 3, targetReps: "8-10", restSeconds: 90),
            RoutineExercise(orderIndex: 2, exerciseName: "Push-ups (Strict Form)", targetSets: 4, targetReps: "15-20", restSeconds: 60),
            RoutineExercise(orderIndex: 3, exerciseName: "Bulgarian Split Squat", targetSets: 3, targetReps: "12 each", restSeconds: 60)
        ])
        return Routine(
            name: "Ascend Calisthenics Blueprint",
            subtitle: "Bodyweight mastery, core stability, and structural endurance",
            targetGoal: goal,
            equipmentTier: .bodyweight,
            daysPerWeek: min(days, 3),
            days: [d1, d2, d3]
        )
    }
    
    private static func buildBandsRoutine(days: Int, goal: FitnessGoal) -> Routine {
        return buildBodyweightCalisthenicsRoutine(days: days, goal: goal)
    }
    
    // MARK: - Food & Supplement Seeding
    public static func defaultFoodCatalog() -> [FoodItem] {
        return [
            // PROTEIN
            FoodItem(
                name: "Chicken Breast (Boneless)",
                category: .protein,
                servingDescription: "1 Palm (~150g raw / 120g cooked)",
                proteinGrams: 36.0,
                carbsGrams: 0.0,
                fatsGrams: 3.5,
                calories: 180,
                handGuide: .palm,
                portionVisualTip: "Size and thickness of your open palm (excluding fingers). Clean, ultra-high protein source.",
                isBudgetStaple: true
            ),
            FoodItem(
                name: "Whole Large Eggs (3 Eggs)",
                category: .protein,
                servingDescription: "3 Large Eggs (~150g)",
                proteinGrams: 19.5,
                carbsGrams: 1.2,
                fatsGrams: 15.0,
                calories: 215,
                handGuide: .cuppedHand,
                portionVisualTip: "Three whole eggs. Rich in choline, vitamin D, and leucine for muscle protein synthesis.",
                isBudgetStaple: true,
                isVegetarian: true
            ),
            FoodItem(
                name: "Egg Whites (Liquid)",
                category: .protein,
                servingDescription: "1 Cup (240ml)",
                proteinGrams: 26.0,
                carbsGrams: 1.8,
                fatsGrams: 0.4,
                calories: 120,
                handGuide: .fist,
                portionVisualTip: "About the volume of your closed fist. Pure protein with almost zero fats or carbs.",
                isBudgetStaple: true,
                isVegetarian: true
            ),
            FoodItem(
                name: "Plain Greek Yogurt (0% Fat)",
                category: .protein,
                servingDescription: "1 Fist (~1 Cup / 200g)",
                proteinGrams: 20.0,
                carbsGrams: 7.0,
                fatsGrams: 0.5,
                calories: 115,
                handGuide: .fist,
                portionVisualTip: "Volume of your closed fist. High casein content provides sustained amino acid release.",
                isBudgetStaple: true,
                isVegetarian: true
            ),
            FoodItem(
                name: "Whey Protein Isolate (1 Scoop)",
                category: .protein,
                servingDescription: "1 Level Scoop (~30g)",
                proteinGrams: 25.0,
                carbsGrams: 1.5,
                fatsGrams: 0.8,
                calories: 115,
                handGuide: .cuppedHand,
                portionVisualTip: "Fastest-absorbing protein. Ideal within 1-2 hours around workout window.",
                isBudgetStaple: true,
                isVegetarian: true
            ),
            FoodItem(
                name: "Lean Ground Beef (93/7)",
                category: .protein,
                servingDescription: "1 Palm (~140g raw)",
                proteinGrams: 28.0,
                carbsGrams: 0.0,
                fatsGrams: 9.0,
                calories: 200,
                handGuide: .palm,
                portionVisualTip: "Thickness of your palm. Excellent source of bioavailable iron, zinc, and natural creatine.",
                isBudgetStaple: false
            ),
            FoodItem(
                name: "Canned Chunk Light Tuna in Water",
                category: .protein,
                servingDescription: "1 Can Drained (~120g)",
                proteinGrams: 28.0,
                carbsGrams: 0.0,
                fatsGrams: 1.0,
                calories: 120,
                handGuide: .palm,
                portionVisualTip: "Standard canned tuna size. Unbeatable budget protein per dollar.",
                isBudgetStaple: true
            ),
            FoodItem(
                name: "Extra Firm Tofu / Tempeh",
                category: .protein,
                servingDescription: "1 Palm (~150g)",
                proteinGrams: 22.0,
                carbsGrams: 4.0,
                fatsGrams: 9.0,
                calories: 180,
                handGuide: .palm,
                portionVisualTip: "Palm-sized block. Complete plant-based amino acid profile.",
                isBudgetStaple: true,
                isVegetarian: true,
                isVegan: true
            ),
            
            // CARBS
            FoodItem(
                name: "Jasmine / Basmati White Rice (Cooked)",
                category: .complexCarb,
                servingDescription: "1 Fist (~1 Cup / 160g cooked)",
                proteinGrams: 4.0,
                carbsGrams: 45.0,
                fatsGrams: 0.5,
                calories: 205,
                handGuide: .fist,
                portionVisualTip: "Volume of your closed fist. Fast digesting, easy on gut, perfect pre/post workout glycogen fuel.",
                isBudgetStaple: true,
                isVegetarian: true,
                isVegan: true
            ),
            FoodItem(
                name: "Whole Wheat Roti / Flatbread (2 Pieces)",
                category: .complexCarb,
                servingDescription: "2 Medium Rotis (~70g)",
                proteinGrams: 6.0,
                carbsGrams: 34.0,
                fatsGrams: 1.5,
                calories: 175,
                handGuide: .palm,
                portionVisualTip: "Two flat round rotis roughly the diameter of your spread hand. Good complex carb fiber.",
                isBudgetStaple: true,
                isVegetarian: true,
                isVegan: true
            ),
            FoodItem(
                name: "Rolled Oats (Dry)",
                category: .complexCarb,
                servingDescription: "1 Cupped Hand (~1/2 Cup / 50g dry)",
                proteinGrams: 6.5,
                carbsGrams: 32.0,
                fatsGrams: 3.0,
                calories: 180,
                handGuide: .cuppedHand,
                portionVisualTip: "One generous cupped hand of dry oats. Slow-burning beta-glucan fiber keeps you full.",
                isBudgetStaple: true,
                isVegetarian: true,
                isVegan: true
            ),
            FoodItem(
                name: "Baked Sweet Potato / Russet Potato",
                category: .complexCarb,
                servingDescription: "1 Fist-Sized Potato (~200g)",
                proteinGrams: 4.0,
                carbsGrams: 42.0,
                fatsGrams: 0.2,
                calories: 185,
                handGuide: .fist,
                portionVisualTip: "Size of your closed fist. Rich in potassium to prevent workout cramps.",
                isBudgetStaple: true,
                isVegetarian: true,
                isVegan: true
            ),
            
            // FATS
            FoodItem(
                name: "Extra Virgin Olive Oil",
                category: .healthyFat,
                servingDescription: "1 Thumb (~1 Tbsp / 14g)",
                proteinGrams: 0.0,
                carbsGrams: 0.0,
                fatsGrams: 14.0,
                calories: 125,
                handGuide: .thumb,
                portionVisualTip: "Tip of your thumb from first knuckle to nail. Heart-healthy monounsaturated polyphenols.",
                isBudgetStaple: true,
                isVegetarian: true,
                isVegan: true
            ),
            FoodItem(
                name: "Peanut Butter / Almond Butter",
                category: .healthyFat,
                servingDescription: "1 Thumb (~1 Tbsp / 16g)",
                proteinGrams: 4.0,
                carbsGrams: 3.5,
                fatsGrams: 8.0,
                calories: 95,
                handGuide: .thumb,
                portionVisualTip: "Length of your thumb. Calorie-dense healthy fat.",
                isBudgetStaple: true,
                isVegetarian: true,
                isVegan: true
            ),
            
            // VEGGIES
            FoodItem(
                name: "Broccoli & Mixed Greens",
                category: .fruitAndVeg,
                servingDescription: "2 Fists (~2 Cups)",
                proteinGrams: 3.0,
                carbsGrams: 8.0,
                fatsGrams: 0.5,
                calories: 45,
                handGuide: .fist,
                portionVisualTip: "Two full fists. Micronutrient powerhouse packed with sulforaphane, potassium, and fiber.",
                isBudgetStaple: true,
                isVegetarian: true,
                isVegan: true
            )
        ]
    }
    
    public static func defaultSupplementCatalog() -> [SupplementItem] {
        return [
            SupplementItem(
                name: "Creatine Monohydrate",
                dosage: "5 grams daily",
                timing: .anytime,
                purpose: "Cellular ATP Energy & Strength",
                whyItMatters: "Most clinically validated supplement in sports science. Saturates muscle phosphocreatine stores, boosting maximal strength by 5-15% and promoting muscle fullness.",
                isEssential: true
            ),
            SupplementItem(
                name: "Whey or Plant Protein",
                dosage: "1-2 scoops (25-50g protein)",
                timing: .postWorkout,
                purpose: "Muscle Protein Synthesis (MPS)",
                whyItMatters: "Provides high concentrations of essential amino acids and leucine to trigger muscle repair rapidly after intense training sessions.",
                isEssential: true
            ),
            SupplementItem(
                name: "Vitamin D3 + K2",
                dosage: "2,000 - 5,000 IU",
                timing: .morning,
                purpose: "Hormone Optimization & Bone Density",
                whyItMatters: "Supports optimal testosterone production, immune defense, and calcium absorption directly into bones rather than arteries.",
                isEssential: true
            ),
            SupplementItem(
                name: "Electrolytes (Sodium, Potassium, Magnesium)",
                dosage: "1 packet / pinch in water",
                timing: .preWorkout,
                purpose: "Hydration & Muscle Pump",
                whyItMatters: "Sodium drives muscular contractions and blood volume. Prevents mid-workout fatigue, headaches, and cramping.",
                isEssential: false
            ),
            SupplementItem(
                name: "Omega-3 Fish Oil",
                dosage: "2,000mg (1,000mg EPA/DHA)",
                timing: .morning,
                purpose: "Joint Health & Anti-Inflammation",
                whyItMatters: "Reduces post-workout soreness, lubricates heavy joints, and supports cardiovascular and cognitive performance.",
                isEssential: false
            ),
            SupplementItem(
                name: "Magnesium Glycinate",
                dosage: "200-400mg",
                timing: .bedtime,
                purpose: "Deep Sleep & Central Nervous System Recovery",
                whyItMatters: "Relaxes muscles, calms sympathetic nervous tone, and dramatically improves slow-wave deep sleep where growth hormone is secreted.",
                isEssential: false
            )
        ]
    }
}
