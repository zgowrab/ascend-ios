import SwiftUI
import SwiftData

@main
struct AscendApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            ExerciseDefinition.self,
            Routine.self,
            RoutineDay.self,
            RoutineExercise.self,
            WorkoutSession.self,
            ExerciseSetRecord.self,
            FoodItem.self,
            DailyMealLog.self,
            DailyDisciplineEntry.self,
            SupplementItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
