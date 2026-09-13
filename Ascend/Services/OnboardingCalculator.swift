import Foundation

public struct MacroCalculationResult {
    public let dailyCalories: Int
    public let proteinGrams: Int
    public let carbsGrams: Int
    public let fatsGrams: Int
    public let waterLiters: Double
    public let bmr: Int
    public let tdee: Int
}

public struct OnboardingCalculator {
    public static func calculateTargets(
        age: Int,
        gender: String,
        heightCm: Double,
        weightKg: Double,
        goal: FitnessGoal,
        daysPerWeek: Int
    ) -> MacroCalculationResult {
        // Mifflin-St Jeor Equation
        let isFemale = gender.lowercased().starts(with: "f")
        let baseBMR: Double
        if isFemale {
            baseBMR = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * Double(age)) - 161.0
        } else {
            baseBMR = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * Double(age)) + 5.0
        }
        let bmr = max(1200, Int(baseBMR))
        
        // Activity multiplier
        let activityMultiplier: Double
        switch daysPerWeek {
        case ...2: activityMultiplier = 1.3
        case 3: activityMultiplier = 1.42
        case 4: activityMultiplier = 1.55
        case 5: activityMultiplier = 1.62
        default: activityMultiplier = 1.72
        }
        
        let tdee = Int(Double(bmr) * activityMultiplier)
        
        // Goal-adjusted calories
        let calorieTarget: Int
        switch goal {
        case .hypertrophy:
            calorieTarget = tdee + 300 // Lean bulk surplus
        case .fatLoss:
            calorieTarget = max(1400, tdee - 450) // Safe deficit
        case .strength:
            calorieTarget = tdee + 150
        case .recomposition:
            calorieTarget = tdee // Maintenance
        case .athletic:
            calorieTarget = tdee + 100
        }
        
        // Protein: 2.0g/kg for hypertrophy & cut, 1.8g/kg for recomp & strength, 1.6g/kg for athletic
        let proteinPerKg: Double
        switch goal {
        case .hypertrophy, .fatLoss:
            proteinPerKg = 2.0
        case .strength, .recomposition:
            proteinPerKg = 1.8
        case .athletic:
            proteinPerKg = 1.6
        }
        let proteinGrams = Int(weightKg * proteinPerKg)
        let proteinCalories = proteinGrams * 4
        
        // Fats: 25% of total calories (9 kcal/g)
        let fatCalories = Double(calorieTarget) * 0.25
        let fatsGrams = Int(fatCalories / 9.0)
        
        // Carbs: Remainder of calories (4 kcal/g)
        let remainingCalories = max(0, calorieTarget - proteinCalories - (fatsGrams * 9))
        let carbsGrams = Int(Double(remainingCalories) / 4.0)
        
        // Water: ~45ml per kg of bodyweight, minimum 2.8L
        let waterLiters = max(2.8, Double(round((weightKg * 0.045) * 10) / 10))
        
        return MacroCalculationResult(
            dailyCalories: calorieTarget,
            proteinGrams: proteinGrams,
            carbsGrams: carbsGrams,
            fatsGrams: fatsGrams,
            waterLiters: waterLiters,
            bmr: bmr,
            tdee: tdee
        )
    }
}
