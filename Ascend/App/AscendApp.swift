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
            SupplementItem.self,
            SavedFavoriteMeal.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            Task { @MainActor in
                seedDefaultStaplesIfNeeded(context: container.mainContext)
            }
            return container
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
    
    @MainActor
    private static func seedDefaultStaplesIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<SavedFavoriteMeal>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count == 0 {
            let defaults: [SavedFavoriteMeal] = [
                SavedFavoriteMeal(name: "Morning Milk Coffee", mealSlot: "Breakfast", calories: 135, proteinGrams: 7, carbsGrams: 12, fatsGrams: 6, servingDescription: "1 mug (~250ml)", icon: "cup.and.saucer.fill", isPinned: true, useCount: 0),
                SavedFavoriteMeal(name: "Bowl of Oats & Berries", mealSlot: "Breakfast", calories: 350, proteinGrams: 11, carbsGrams: 60, fatsGrams: 6, servingDescription: "1 medium bowl", icon: "cup.and.heat.waves.fill", isPinned: true, useCount: 0),
                SavedFavoriteMeal(name: "Whey Protein Shake", mealSlot: "Pre-Workout Fuel", calories: 140, proteinGrams: 25, carbsGrams: 3, fatsGrams: 2, servingDescription: "1 shaker bottle", icon: "bolt.fill", isPinned: true, useCount: 0),
                SavedFavoriteMeal(name: "Eggs & Sourdough Toast", mealSlot: "Breakfast", calories: 380, proteinGrams: 24, carbsGrams: 28, fatsGrams: 14, servingDescription: "3 eggs + 1 slice toast", icon: "fork.knife", isPinned: true, useCount: 0),
                SavedFavoriteMeal(name: "Greek Yogurt & Honey", mealSlot: "Snack", calories: 220, proteinGrams: 18, carbsGrams: 24, fatsGrams: 3, servingDescription: "1 bowl (~200g)", icon: "takeoutbag.and.cup.and.straw.fill", isPinned: true, useCount: 0),
                SavedFavoriteMeal(name: "Chicken, Rice & Greens", mealSlot: "Lunch", calories: 510, proteinGrams: 46, carbsGrams: 54, fatsGrams: 9, servingDescription: "1 athlete fuel plate", icon: "flame.fill", isPinned: true, useCount: 0)
            ]
            for item in defaults {
                context.insert(item)
            }
            try? context.save()
        }
    }
}

