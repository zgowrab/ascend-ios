import Foundation
import SwiftData

public enum FitnessGoal: String, Codable, CaseIterable, Identifiable {
    case hypertrophy = "Hypertrophy (Muscle Gain)"
    case strength = "Strength & Power"
    case fatLoss = "Fat Loss & Cut"
    case recomposition = "Body Recomposition"
    case athletic = "Athletic & Longevity"
    
    public var id: String { rawValue }
    
    public var badge: String {
        switch self {
        case .hypertrophy: return "flame.fill"
        case .strength: return "bolt.shield.fill"
        case .fatLoss: return "scalemass.fill"
        case .recomposition: return "arrow.triangle.2.circlepath"
        case .athletic: return "figure.run"
        }
    }
    
    public var tagline: String {
        switch self {
        case .hypertrophy: return "Optimize mechanical tension and progressive volume to build dense lean mass."
        case .strength: return "Focus on heavy compound lifts and nervous system efficiency."
        case .fatLoss: return "Preserve lean muscle in a controlled caloric deficit with high protein."
        case .recomposition: return "Build muscle while dropping fat at maintenance caloric intake."
        case .athletic: return "Develop functional power, cardiovascular resilience, and mobility."
        }
    }
}

public enum EquipmentAccess: String, Codable, CaseIterable, Identifiable {
    case commercialGym = "Commercial Gym"
    case homeGym = "Home Gym (Barbell & Rack)"
    case dumbbellsOnly = "Dumbbells Only"
    case bodyweight = "Bodyweight / Calisthenics"
    case resistanceBands = "Resistance Bands & Minimal"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .commercialGym: return "building.columns.fill"
        case .homeGym: return "house.fill"
        case .dumbbellsOnly: return "dumbbell.fill"
        case .bodyweight: return "figure.walk"
        case .resistanceBands: return "circle.dotted"
        }
    }
    
    public var detail: String {
        switch self {
        case .commercialGym: return "Barbells, dumbbells, cable stacks, and isolation machines."
        case .homeGym: return "Squat rack, Olympic barbell, bench, and weight plates."
        case .dumbbellsOnly: return "Set of adjustable or fixed dumbbells and optional bench."
        case .bodyweight: return "No tools required; optional pull-up bar / dip handles."
        case .resistanceBands: return "Loop bands, tube bands with door anchor."
        }
    }
}

public enum DietStyle: String, Codable, CaseIterable, Identifiable {
    case omnivore = "Omnivore (All Foods)"
    case highProteinVegetarian = "Vegetarian (Eggs/Dairy Included)"
    case vegan = "Plant-Based / Vegan"
    case pescatarian = "Pescatarian (Fish & Seafood)"
    
    public var id: String { rawValue }
}

public enum BudgetTier: String, Codable, CaseIterable, Identifiable {
    case smartStaples = "Smart Staples (Budget Conscious)"
    case balanced = "Balanced Daily Variety"
    case premium = "Premium & Specialty"
    
    public var id: String { rawValue }
    
    public var descriptor: String {
        switch self {
        case .smartStaples: return "High protein per dollar: eggs, chicken breast, canned tuna, oats, bulk rice, whey."
        case .balanced: return "Versatile mix of chicken, ground beef, Greek yogurt, potatoes, and seasonal produce."
        case .premium: return "Salmon, steak, organic poultry, specialty supplements, and micro-greens."
        }
    }
}

public enum CarbStaple: String, Codable, CaseIterable, Identifiable {
    case rice = "Rice (White / Basmati / Jasmine)"
    case flatbreadOrFlour = "Roti / Flatbread / Whole Wheat Bread"
    case oatsAndPotatoes = "Oats & Potatoes / Sweet Potatoes"
    case mixedOrKeto = "Low-Carb & Green Vegetables"
    
    public var id: String { rawValue }
}

public enum ProteinPreference: String, Codable, CaseIterable, Identifiable {
    case chickenAndEggs = "Chicken & Eggs Primary"
    case beefAndPoultry = "Beef, Chicken & Dairy"
    case seafoodAndPoultry = "Salmon, White Fish & Poultry"
    case plantProtein = "Tofu, Tempeh, Lentils & Plant Whey"
    case dairyAndEggs = "Greek Yogurt, Paneer, Cottage Cheese & Eggs"
    
    public var id: String { rawValue }
}

@Model
public final class UserProfile {
    public var id: UUID
    public var name: String
    public var age: Int
    public var gender: String
    public var heightCm: Double
    public var weightKg: Double
    public var goalRaw: String
    public var equipmentTierRaw: String
    public var trainingDaysPerWeek: Int
    public var dietStyleRaw: String
    public var budgetTierRaw: String
    public var primaryCarbStapleRaw: String
    public var primaryProteinSourceRaw: String
    public var dailyCalorieTarget: Int
    public var dailyProteinGrams: Int
    public var dailyCarbsGrams: Int
    public var dailyFatsGrams: Int
    public var dailyWaterTargetLiters: Double
    public var isOnboarded: Bool
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String = "Athlete",
        age: Int = 26,
        gender: String = "Male",
        heightCm: Double = 178,
        weightKg: Double = 75,
        goal: FitnessGoal = .hypertrophy,
        equipment: EquipmentAccess = .commercialGym,
        trainingDays: Int = 4,
        dietStyle: DietStyle = .omnivore,
        budget: BudgetTier = .smartStaples,
        carbStaple: CarbStaple = .rice,
        proteinPref: ProteinPreference = .chickenAndEggs,
        calories: Int = 2400,
        protein: Int = 165,
        carbs: Int = 260,
        fats: Int = 65,
        waterLiters: Double = 3.5,
        isOnboarded: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.goalRaw = goal.rawValue
        self.equipmentTierRaw = equipment.rawValue
        self.trainingDaysPerWeek = trainingDays
        self.dietStyleRaw = dietStyle.rawValue
        self.budgetTierRaw = budget.rawValue
        self.primaryCarbStapleRaw = carbStaple.rawValue
        self.primaryProteinSourceRaw = proteinPref.rawValue
        self.dailyCalorieTarget = calories
        self.dailyProteinGrams = protein
        self.dailyCarbsGrams = carbs
        self.dailyFatsGrams = fats
        self.dailyWaterTargetLiters = waterLiters
        self.isOnboarded = isOnboarded
        self.createdAt = createdAt
    }
    
    public var goal: FitnessGoal {
        get { FitnessGoal(rawValue: goalRaw) ?? .hypertrophy }
        set { goalRaw = newValue.rawValue }
    }
    
    public var equipment: EquipmentAccess {
        get { EquipmentAccess(rawValue: equipmentTierRaw) ?? .commercialGym }
        set { equipmentTierRaw = newValue.rawValue }
    }
    
    public var dietStyle: DietStyle {
        get { DietStyle(rawValue: dietStyleRaw) ?? .omnivore }
        set { dietStyleRaw = newValue.rawValue }
    }
    
    public var budgetTier: BudgetTier {
        get { BudgetTier(rawValue: budgetTierRaw) ?? .smartStaples }
        set { budgetTierRaw = newValue.rawValue }
    }
    
    public var carbStaple: CarbStaple {
        get { CarbStaple(rawValue: primaryCarbStapleRaw) ?? .rice }
        set { primaryCarbStapleRaw = newValue.rawValue }
    }
    
    public var proteinPreference: ProteinPreference {
        get { ProteinPreference(rawValue: primaryProteinSourceRaw) ?? .chickenAndEggs }
        set { primaryProteinSourceRaw = newValue.rawValue }
    }
    
    public var weightLbs: Double {
        weightKg * 2.20462
    }
    
    public var heightFeetInches: (feet: Int, inches: Int) {
        let totalInches = heightCm / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return (feet, inches)
    }
}
