import Foundation
import SwiftData

public enum FoodCategory: String, Codable, CaseIterable, Identifiable {
    case protein = "Lean Protein"
    case complexCarb = "Complex Carbohydrate"
    case healthyFat = "Healthy Fat"
    case fruitAndVeg = "Vegetable & Fiber"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .protein: return "fork.knife"
        case .complexCarb: return "bolt.fill"
        case .healthyFat: return "drop.fill"
        case .fruitAndVeg: return "leaf.fill"
        }
    }
}

public enum PortionHandGuide: String, Codable, CaseIterable, Identifiable {
    case palm = "Palm of Hand (~25-35g Protein)"
    case fist = "Fist (~1 Cup / 35-45g Carbs or Veggies)"
    case cuppedHand = "Cupped Hand (~1/2 Cup / 20-30g Carbs)"
    case thumb = "Thumb (~1 Tbsp / 10-14g Healthy Fats)"
    
    public var id: String { rawValue }
    
    public var handIcon: String {
        switch self {
        case .palm: return "hand.raised.fill"
        case .fist: return "hand.point.up.left.fill"
        case .cuppedHand: return "hand.wave.fill"
        case .thumb: return "hand.thumbsup.fill"
        }
    }
}

@Model
public final class FoodItem {
    public var id: UUID
    public var name: String
    public var categoryRaw: String
    public var servingDescription: String
    public var proteinGrams: Double
    public var carbsGrams: Double
    public var fatsGrams: Double
    public var calories: Int
    public var handGuideRaw: String
    public var portionVisualTip: String
    public var isBudgetStaple: Bool
    public var isVegetarian: Bool
    public var isVegan: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        category: FoodCategory,
        servingDescription: String,
        proteinGrams: Double,
        carbsGrams: Double,
        fatsGrams: Double,
        calories: Int,
        handGuide: PortionHandGuide,
        portionVisualTip: String,
        isBudgetStaple: Bool = true,
        isVegetarian: Bool = false,
        isVegan: Bool = false
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = category.rawValue
        self.servingDescription = servingDescription
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatsGrams = fatsGrams
        self.calories = calories
        self.handGuideRaw = handGuide.rawValue
        self.portionVisualTip = portionVisualTip
        self.isBudgetStaple = isBudgetStaple
        self.isVegetarian = isVegetarian
        self.isVegan = isVegan
    }
    
    public var category: FoodCategory {
        get { FoodCategory(rawValue: categoryRaw) ?? .protein }
        set { categoryRaw = newValue.rawValue }
    }
    
    public var handGuide: PortionHandGuide {
        get { PortionHandGuide(rawValue: handGuideRaw) ?? .palm }
        set { handGuideRaw = newValue.rawValue }
    }
}

@Model
public final class DailyMealLog {
    public var id: UUID
    public var date: Date
    public var mealSlot: String // "Breakfast", "Lunch", "Pre-Workout Fuel", "Dinner", "Snack"
    public var foodName: String
    public var servings: Double
    public var proteinGrams: Double
    public var carbsGrams: Double
    public var fatsGrams: Double
    public var calories: Int
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        mealSlot: String = "Lunch",
        foodName: String,
        servings: Double = 1.0,
        proteinGrams: Double,
        carbsGrams: Double,
        fatsGrams: Double,
        calories: Int
    ) {
        self.id = id
        self.date = date
        self.mealSlot = mealSlot
        self.foodName = foodName
        self.servings = servings
        self.proteinGrams = proteinGrams * servings
        self.carbsGrams = carbsGrams * servings
        self.fatsGrams = fatsGrams * servings
        self.calories = Int(Double(calories) * servings)
    }
}
