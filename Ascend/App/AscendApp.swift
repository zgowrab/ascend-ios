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
    
    @State private var isAppReady: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                
                if !isAppReady {
                    AppLaunchLoadingView()
                        .transition(.opacity)
                        .zIndex(100)
                }
            }
            .task {
                // Brief pause allowing SwiftData initialization and brand crest presentation
                try? await Task.sleep(nanoseconds: 1_250_000_000)
                withAnimation(.easeInOut(duration: 0.45)) {
                    isAppReady = true
                }
            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
    
    @MainActor
    private static func seedDefaultStaplesIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<SavedFavoriteMeal>()
        if let existing = try? context.fetch(descriptor) {
            // Auto-heal any persisted legacy 'bowl.fill' icons from previous builds
            var needsSave = false
            for item in existing where item.icon == "bowl.fill" {
                item.icon = "cup.and.heat.waves.fill"
                needsSave = true
            }
            if needsSave {
                try? context.save()
            }
            
            if existing.isEmpty {
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
}

