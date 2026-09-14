import UIKit
import Vision

public struct SmartMealPrediction: Sendable, Identifiable {
    public var id = UUID()
    public var isFoodDetected: Bool
    public var detectedObject: String?
    public var foodName: String
    public var estimatedCalories: Int
    public var proteinGrams: Double
    public var carbsGrams: Double
    public var fatsGrams: Double
    public var confidence: Double
    public var suggestedMealSlot: String
    public var breakdownItems: [String]
    public var portionDescription: String
    
    public init(
        isFoodDetected: Bool = true,
        detectedObject: String? = nil,
        foodName: String,
        estimatedCalories: Int,
        proteinGrams: Double,
        carbsGrams: Double,
        fatsGrams: Double,
        confidence: Double,
        suggestedMealSlot: String,
        breakdownItems: [String],
        portionDescription: String
    ) {
        self.isFoodDetected = isFoodDetected
        self.detectedObject = detectedObject
        self.foodName = foodName
        self.estimatedCalories = estimatedCalories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatsGrams = fatsGrams
        self.confidence = confidence
        self.suggestedMealSlot = suggestedMealSlot
        self.breakdownItems = breakdownItems
        self.portionDescription = portionDescription
    }
}

public final class SmartMealScannerService: Sendable {
    public static let shared = SmartMealScannerService()
    
    private init() {}
    
    /// Analyzes a meal photo using Vision classification and nutritional estimation logic.
    public func analyzeMealPhoto(_ image: UIImage) async -> SmartMealPrediction {
        // Small async pause to give a tactile scanning experience in UI
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        guard let cgImage = image.cgImage else {
            return noFoodDetectedPrediction(objectName: "Unknown Object")
        }
        
        var observations: [(identifier: String, confidence: Float)] = []
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNClassifyImageRequest()
        
        do {
            try handler.perform([request])
            if let results = request.results {
                observations = results
                    .prefix(30)
                    .map { (identifier: $0.identifier.lowercased(), confidence: $0.confidence) }
            }
        } catch {
            print("Vision classification error: \(error)")
        }
        
        return evaluateObservations(observations)
    }
    
    private func evaluateObservations(_ observations: [(identifier: String, confidence: Float)]) -> SmartMealPrediction {
        guard !observations.isEmpty else {
            return noFoodDetectedPrediction(objectName: "Unrecognized Object")
        }
        
        // Non-food blacklist keywords that definitely indicate non-food items
        let nonFoodKeywords = [
            "pillow", "cushion", "bed", "bedding", "quilt", "blanket", "sheet", "mattress",
            "couch", "sofa", "furniture", "chair", "table", "desk", "curtain", "linen",
            "clothing", "shirt", "jacket", "pants", "shoe", "sneaker", "sock", "textile",
            "screen", "monitor", "laptop", "computer", "keyboard", "mouse", "phone", "tablet",
            "wall", "floor", "ceiling", "window", "door", "room", "carpet", "rug", "tile",
            "dog", "cat", "pet", "animal", "face", "person", "human", "hand", "arm",
            "car", "vehicle", "wheel", "bicycle", "paper", "book", "cardboard", "box"
        ]
        
        // Food indicator keywords
        let foodRoots = [
            "food", "dish", "meal", "drink", "beverage", "produce", "fruit", "vegetable",
            "meat", "dairy", "grain", "baked", "snack", "dessert", "cuisine", "edible",
            "sauce", "soup", "salad", "appetizer", "dinner", "lunch", "breakfast", "supper"
        ]
        
        // Calculate max non-food confidence vs food confidence
        var detectedNonFood: (name: String, confidence: Float)? = nil
        var detectedFoodKeywords: [(name: String, confidence: Float)] = []
        
        for obs in observations {
            let id = obs.identifier
            
            // Check non-food
            for nf in nonFoodKeywords {
                if id.contains(nf) {
                    if detectedNonFood == nil || obs.confidence > (detectedNonFood?.confidence ?? 0) {
                        detectedNonFood = (cleanIdentifier(id), obs.confidence)
                    }
                }
            }
            
            // Check food roots or specific foods
            let isFood = foodRoots.contains { id.contains($0) } || isSpecificFoodKeyword(id)
            if isFood {
                detectedFoodKeywords.append((id, obs.confidence))
            }
        }
        
        // If a strong non-food item is detected and no substantial food indicator exists
        if let nonFood = detectedNonFood, nonFood.confidence > 0.3 {
            let maxFoodConfidence = detectedFoodKeywords.map { $0.confidence }.max() ?? 0.0
            if maxFoodConfidence < 0.25 || nonFood.confidence > (maxFoodConfidence * 2.0) {
                return noFoodDetectedPrediction(objectName: nonFood.name)
            }
        }
        
        // If no food keywords were found at all in the top results
        if detectedFoodKeywords.isEmpty {
            let topLabel = observations.first?.identifier ?? "Non-food item"
            return noFoodDetectedPrediction(objectName: cleanIdentifier(topLabel))
        }
        
        // Map food keywords to nutritional profiles
        return matchFoodProfile(detectedFoodKeywords)
    }
    
    private func isSpecificFoodKeyword(_ id: String) -> Bool {
        let specifics = [
            "coffee", "espresso", "latte", "cappuccino", "tea", "mocha", "americano",
            "oat", "porridge", "cereal", "granola", "muesli",
            "egg", "omelet", "scramble", "toast", "pancake", "waffle", "crepe",
            "chicken", "poultry", "turkey", "breast", "wing", "thigh",
            "salmon", "fish", "tuna", "shrimp", "seafood", "cod", "sushi", "sashimi",
            "steak", "beef", "ribeye", "sirloin", "burger", "patty", "meatball",
            "pasta", "spaghetti", "noodle", "ramen", "lasagna", "penne", "macaroni",
            "rice", "risotto", "grain", "quinoa", "fried rice",
            "salad", "lettuce", "spinach", "kale", "cucumber", "broccoli", "avocado",
            "pizza", "sandwich", "wrap", "taco", "burrito", "quesadilla",
            "shake", "smoothie", "protein", "whey", "yogurt", "parfait",
            "apple", "banana", "berry", "orange", "grape", "mango", "strawberry"
        ]
        return specifics.contains { id.contains($0) }
    }
    
    private func matchFoodProfile(_ keywords: [(name: String, confidence: Float)]) -> SmartMealPrediction {
        let combined = keywords.map { $0.name }.joined(separator: " ")
        let maxConfidence = Double(keywords.map { $0.confidence }.max() ?? 0.85)
        let normalizedConf = min(0.96, max(0.75, maxConfidence))
        
        // 1. Coffee / Latte / Espresso
        if combined.contains("coffee") || combined.contains("espresso") || combined.contains("latte") || combined.contains("cappuccino") || combined.contains("mocha") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Milk Coffee / Cafe Latte",
                estimatedCalories: 135,
                proteinGrams: 7,
                carbsGrams: 12,
                fatsGrams: 6,
                confidence: normalizedConf,
                suggestedMealSlot: "Breakfast",
                breakdownItems: ["Fresh Brewed Espresso", "Steamed Whole/Oat Milk (~200ml)", "Natural Crema"],
                portionDescription: "1 Mug (~250ml)"
            )
        }
        
        // 2. Oats / Porridge / Granola
        if combined.contains("oat") || combined.contains("porridge") || combined.contains("cereal") || combined.contains("granola") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Power Oatmeal Bowl with Berries",
                estimatedCalories: 360,
                proteinGrams: 12,
                carbsGrams: 62,
                fatsGrams: 6,
                confidence: normalizedConf,
                suggestedMealSlot: "Breakfast",
                breakdownItems: ["Rolled Oats (~80g dry)", "Wild Blueberries & Banana", "Touch of Honey/Maple"],
                portionDescription: "1 Medium Bowl (~320g)"
            )
        }
        
        // 3. Eggs / Breakfast Skillet / Omelet
        if combined.contains("egg") || combined.contains("omelet") || combined.contains("scramble") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Scrambled Eggs & Sourdough Toast",
                estimatedCalories: 390,
                proteinGrams: 24,
                carbsGrams: 28,
                fatsGrams: 16,
                confidence: normalizedConf,
                suggestedMealSlot: "Breakfast",
                breakdownItems: ["3 Whole Eggs Scrambled", "1 Thick Slice Sourdough", "Grass-Fed Butter"],
                portionDescription: "1 Plate (~220g)"
            )
        }
        
        // 4. Pizza
        if combined.contains("pizza") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Wood-Fired Pizza",
                estimatedCalories: 680,
                proteinGrams: 28,
                carbsGrams: 76,
                fatsGrams: 28,
                confidence: normalizedConf,
                suggestedMealSlot: "Dinner",
                breakdownItems: ["Crust Dough", "San Marzano Tomato Sauce", "Whole Milk Mozzarella & Basil"],
                portionDescription: "2 Standard Slices (~260g)"
            )
        }
        
        // 5. Burger
        if combined.contains("burger") || combined.contains("patty") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Gourmet Beef Burger with Brioche Bun",
                estimatedCalories: 620,
                proteinGrams: 36,
                carbsGrams: 46,
                fatsGrams: 32,
                confidence: normalizedConf,
                suggestedMealSlot: "Lunch",
                breakdownItems: ["Lean Beef Patty (~180g)", "Toasted Brioche Bun", "Cheddar Cheese, Tomato & Lettuce"],
                portionDescription: "1 Burger (~280g)"
            )
        }
        
        // 6. Salmon / Fish / Seafood
        if combined.contains("salmon") || combined.contains("fish") || combined.contains("seafood") || combined.contains("tuna") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Pan-Seared Salmon with Jasmine Rice & Greens",
                estimatedCalories: 560,
                proteinGrams: 42,
                carbsGrams: 52,
                fatsGrams: 18,
                confidence: normalizedConf,
                suggestedMealSlot: "Dinner",
                breakdownItems: ["Atlantic Salmon Fillet (~180g)", "Steamed Jasmine Rice (1 cup)", "Asparagus & Lemon"],
                portionDescription: "1 Full Plate (~380g)"
            )
        }
        
        // 7. Chicken / Poultry & Rice
        if combined.contains("chicken") || combined.contains("poultry") || combined.contains("turkey") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Grilled Chicken Breast with Herb Rice & Veggies",
                estimatedCalories: 510,
                proteinGrams: 46,
                carbsGrams: 54,
                fatsGrams: 9,
                confidence: normalizedConf,
                suggestedMealSlot: "Lunch",
                breakdownItems: ["Lean Chicken Breast (~200g)", "Seasoned White Rice", "Steamed Broccoli & Carrots"],
                portionDescription: "1 Standard Athlete Plate (~400g)"
            )
        }
        
        // 8. Steak / Beef
        if combined.contains("steak") || combined.contains("beef") || combined.contains("meat") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Sirloin Steak with Roasted Sweet Potato",
                estimatedCalories: 640,
                proteinGrams: 52,
                carbsGrams: 44,
                fatsGrams: 22,
                confidence: normalizedConf,
                suggestedMealSlot: "Dinner",
                breakdownItems: ["Grass-Fed Sirloin (~220g)", "Baked Sweet Potato", "Compound Herb Butter"],
                portionDescription: "1 Plate (~420g)"
            )
        }
        
        // 9. Pasta / Noodles / Ramen
        if combined.contains("pasta") || combined.contains("spaghetti") || combined.contains("noodle") || combined.contains("ramen") || combined.contains("penne") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Pasta Bolognese with Lean Beef",
                estimatedCalories: 620,
                proteinGrams: 36,
                carbsGrams: 78,
                fatsGrams: 16,
                confidence: normalizedConf,
                suggestedMealSlot: "Dinner",
                breakdownItems: ["Durum Wheat Pasta (1.5 cups)", "Lean Ground Beef Ragu", "Grated Parmesan"],
                portionDescription: "1 Generous Pasta Bowl (~380g)"
            )
        }
        
        // 10. Sandwich / Wrap / Taco / Burrito
        if combined.contains("sandwich") || combined.contains("wrap") || combined.contains("burrito") || combined.contains("taco") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Turkey & Avocado Artisan Sandwich",
                estimatedCalories: 480,
                proteinGrams: 32,
                carbsGrams: 48,
                fatsGrams: 18,
                confidence: normalizedConf,
                suggestedMealSlot: "Lunch",
                breakdownItems: ["Sliced Roasted Turkey", "Whole Grain Bread", "Avocado, Tomato & Greens"],
                portionDescription: "1 Sandwich (~240g)"
            )
        }
        
        // 11. Salad / Greens
        if combined.contains("salad") || combined.contains("lettuce") || combined.contains("spinach") || combined.contains("kale") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Mediterranean Grilled Chicken Salad",
                estimatedCalories: 430,
                proteinGrams: 38,
                carbsGrams: 18,
                fatsGrams: 22,
                confidence: normalizedConf,
                suggestedMealSlot: "Lunch",
                breakdownItems: ["Mixed Field Greens", "Grilled Chicken Strips", "Extra Virgin Olive Oil & Feta"],
                portionDescription: "1 Large Salad Bowl (~300g)"
            )
        }
        
        // 12. Protein Shake / Smoothie / Drink
        if combined.contains("shake") || combined.contains("smoothie") || combined.contains("whey") || combined.contains("beverage") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Whey Protein Shake with Banana",
                estimatedCalories: 290,
                proteinGrams: 32,
                carbsGrams: 34,
                fatsGrams: 4,
                confidence: normalizedConf,
                suggestedMealSlot: "Pre-Workout Fuel",
                breakdownItems: ["1 Scoop Whey Isolate", "1 Medium Ripe Banana", "Low-Fat Milk (300ml)"],
                portionDescription: "1 Shaker Bottle (~400ml)"
            )
        }
        
        // 13. Greek Yogurt / Parfait / Fruit Bowl
        if combined.contains("yogurt") || combined.contains("parfait") || combined.contains("fruit") || combined.contains("apple") || combined.contains("banana") {
            return SmartMealPrediction(
                isFoodDetected: true,
                foodName: "Greek Yogurt Bowl with Fresh Berries",
                estimatedCalories: 240,
                proteinGrams: 20,
                carbsGrams: 28,
                fatsGrams: 4,
                confidence: normalizedConf,
                suggestedMealSlot: "Snack",
                breakdownItems: ["0% Greek Yogurt (~200g)", "Blueberries & Raspberries", "Drizzle of Honey"],
                portionDescription: "1 Bowl (~260g)"
            )
        }
        
        // General fallback ONLY when genuine food was detected
        return SmartMealPrediction(
            isFoodDetected: true,
            foodName: "Balanced Athlete Fuel Plate",
            estimatedCalories: 520,
            proteinGrams: 38,
            carbsGrams: 52,
            fatsGrams: 14,
            confidence: 0.78,
            suggestedMealSlot: currentMealSlotByTime(),
            breakdownItems: ["Complex Carbohydrate Base", "Lean Protein Portion (~Palm Size)", "Steamed Greens & Healthy Fats"],
            portionDescription: "1 Balanced Meal (~350g)"
        )
    }
    
    private func noFoodDetectedPrediction(objectName: String) -> SmartMealPrediction {
        SmartMealPrediction(
            isFoodDetected: false,
            detectedObject: objectName,
            foodName: "No Food Detected",
            estimatedCalories: 0,
            proteinGrams: 0,
            carbsGrams: 0,
            fatsGrams: 0,
            confidence: 0.0,
            suggestedMealSlot: currentMealSlotByTime(),
            breakdownItems: ["Identified non-food item: \(objectName)"],
            portionDescription: "Non-edible item"
        )
    }
    
    private func cleanIdentifier(_ id: String) -> String {
        let parts = id.components(separatedBy: " > ")
        let raw = parts.last ?? id
        let cleaned = raw
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        return cleaned
    }
    
    public func currentMealSlotByTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11: return "Breakfast"
        case 11..<15: return "Lunch"
        case 15..<18: return "Pre-Workout Fuel"
        case 18..<22: return "Dinner"
        default: return "Snack"
        }
    }
}
