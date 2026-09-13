import SwiftUI
import SwiftData

public struct DietAndPortionView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var profiles: [UserProfile]
    @Query(sort: \FoodItem.name) private var foodItems: [FoodItem]
    @Query(sort: \DailyMealLog.date, order: .reverse) private var mealLogs: [DailyMealLog]
    
    @State private var selectedFoodCategory: FoodCategory = .protein
    @State private var showingAddMealSheet = false
    @State private var selectedFoodToLog: FoodItem?
    @State private var logMealSlot: String = "Lunch"
    @State private var logServings: Double = 1.0
    
    private var profile: UserProfile? { profiles.first }
    
    private var todayMealLogs: [DailyMealLog] {
        let today = Calendar.current.startOfDay(for: Date())
        return mealLogs.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    private var totalCaloriesToday: Int {
        todayMealLogs.reduce(0) { $0 + $1.calories }
    }
    
    private var totalProteinToday: Double {
        todayMealLogs.reduce(0) { $0 + $1.proteinGrams }
    }
    
    private var totalCarbsToday: Double {
        todayMealLogs.reduce(0) { $0 + $1.carbsGrams }
    }
    
    private var totalFatsToday: Double {
        todayMealLogs.reduce(0) { $0 + $1.fatsGrams }
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Macro Progress Ring & Numbers
                    macroHeroCard
                    
                    // Hand-Based Visual Portion Guide
                    handPortionGuideSection
                    
                    // Food Suggestions & Staple Library
                    foodSuggestionsSection
                    
                    // Today's Logged Meals
                    todayLoggedMealsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .ascendBackground()
            .navigationTitle("Nutrition & Portions")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedFoodToLog) { food in
                logFoodSheet(for: food)
            }
        }
    }
    
    // MARK: - Macro Hero Card
    private var macroHeroCard: some View {
        GlassCard(cornerRadius: 22, padding: 18) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TARGET MACRO PROTOCOL")
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.emerald)
                            .tracking(1)
                        
                        Text("\(profile?.goal.rawValue ?? "Personalized Blueprint")")
                            .font(.headline)
                            .foregroundStyle(AscendTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("\(profile?.budgetTier.rawValue ?? "Smart Staples")")
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AscendTheme.bgElevated)
                        .clipShape(Capsule())
                }
                
                // Big 4 Macro Meters
                HStack(spacing: 12) {
                    macroMeter(
                        title: "Calories",
                        current: Double(totalCaloriesToday),
                        target: Double(profile?.dailyCalorieTarget ?? 2400),
                        unit: "kcal",
                        color: AscendTheme.emerald
                    )
                    
                    macroMeter(
                        title: "Protein",
                        current: totalProteinToday,
                        target: Double(profile?.dailyProteinGrams ?? 165),
                        unit: "g",
                        color: AscendTheme.cyan
                    )
                    
                    macroMeter(
                        title: "Carbs",
                        current: totalCarbsToday,
                        target: Double(profile?.dailyCarbsGrams ?? 260),
                        unit: "g",
                        color: AscendTheme.amber
                    )
                    
                    macroMeter(
                        title: "Fats",
                        current: totalFatsToday,
                        target: Double(profile?.dailyFatsGrams ?? 65),
                        unit: "g",
                        color: AscendTheme.flame
                    )
                }
            }
        }
    }
    
    private func macroMeter(
        title: String,
        current: Double,
        target: Double,
        unit: String,
        color: Color
    ) -> some View {
        let progress = target > 0 ? min(1.0, current / target) : 0
        return VStack(spacing: 6) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(AscendTheme.textSecondary)
            
            Text("\(Int(current))")
                .font(.system(.subheadline, design: .rounded).bold())
                .monospacedDigit()
                .foregroundStyle(AscendTheme.textPrimary)
            
            Text("/ \(Int(target))\(unit)")
                .font(.system(size: 9))
                .foregroundStyle(AscendTheme.textMuted)
            
            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 4)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(progress), height: 4)
                }
            }
            .frame(height: 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(AscendTheme.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Hand Portion Guide
    private var handPortionGuideSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("No-Scale Hand Portion Visualizer", systemImage: "hand.raised.fill")
                .font(.headline)
                .foregroundStyle(AscendTheme.emerald)
            
            Text("Estimate accurate portions instantly anywhere without obsessive food weighing.")
                .font(.caption)
                .foregroundStyle(AscendTheme.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    handCard(
                        title: "Palm of Hand",
                        rule: "~25-35g Protein",
                        desc: "Thickness & diameter of your palm: chicken breast, beef, salmon, firm tofu.",
                        icon: "hand.raised.fill",
                        color: AscendTheme.emerald
                    )
                    
                    handCard(
                        title: "Closed Fist",
                        rule: "~1 Cup / 35-45g Carbs",
                        desc: "Volume of your fist: cooked rice, potato, oats, pasta, or raw veggies.",
                        icon: "hand.point.up.left.fill",
                        color: AscendTheme.cyan
                    )
                    
                    handCard(
                        title: "Cupped Hand",
                        rule: "~1/2 Cup / 20-25g Carbs",
                        desc: "Volume that fits in your cupped palm: dry oats, berries, dry beans.",
                        icon: "hand.wave.fill",
                        color: AscendTheme.amber
                    )
                    
                    handCard(
                        title: "Full Thumb",
                        rule: "~1 Tbsp / 12-14g Fats",
                        desc: "Tip of your thumb: olive oil, peanut butter, butter, seeds.",
                        icon: "hand.thumbsup.fill",
                        color: AscendTheme.flame
                    )
                }
            }
        }
    }
    
    private func handCard(
        title: String,
        rule: String,
        desc: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                Spacer()
                Text(rule)
                    .font(.caption2.bold())
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(AscendTheme.textPrimary)
            
            Text(desc)
                .font(.caption2)
                .foregroundStyle(AscendTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 170, height: 110)
        .padding(12)
        .background(AscendTheme.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Food Suggestions
    private var foodSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recommended Staple Foods", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(AscendTheme.cyan)
            
            // Category selector
            HStack(spacing: 8) {
                ForEach(FoodCategory.allCases) { cat in
                    Button {
                        selectedFoodCategory = cat
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: cat.icon)
                            Text(cat.rawValue)
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selectedFoodCategory == cat ? AscendTheme.cyan : AscendTheme.bgElevated)
                        .foregroundStyle(selectedFoodCategory == cat ? AscendTheme.bgPrimary : AscendTheme.textSecondary)
                        .clipShape(Capsule())
                    }
                }
            }
            
            // Food items in category
            let filteredFoods = foodItems.filter { $0.category == selectedFoodCategory }
            VStack(spacing: 8) {
                ForEach(filteredFoods) { food in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(food.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(AscendTheme.textPrimary)
                                
                                if food.isBudgetStaple {
                                    Text("BUDGET STAPLE")
                                        .font(.system(size: 8, weight: .black))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(AscendTheme.emerald.opacity(0.18))
                                        .foregroundStyle(AscendTheme.emerald)
                                        .clipShape(Capsule())
                                }
                            }
                            
                            Text("\(food.servingDescription) • \(food.portionVisualTip)")
                                .font(.caption2)
                                .foregroundStyle(AscendTheme.textSecondary)
                                .lineLimit(2)
                            
                            HStack(spacing: 8) {
                                Text("\(Int(food.proteinGrams))g P")
                                    .font(.caption2.bold())
                                    .foregroundStyle(AscendTheme.cyan)
                                Text("\(Int(food.carbsGrams))g C")
                                    .font(.caption2.bold())
                                    .foregroundStyle(AscendTheme.amber)
                                Text("\(Int(food.fatsGrams))g F")
                                    .font(.caption2.bold())
                                    .foregroundStyle(AscendTheme.flame)
                                Text("• \(food.calories) kcal")
                                    .font(.caption2)
                                    .foregroundStyle(AscendTheme.textMuted)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            selectedFoodToLog = food
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(AscendTheme.emerald)
                        }
                    }
                    .padding(12)
                    .background(AscendTheme.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
    
    // MARK: - Today's Logged Meals
    private var todayLoggedMealsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Today's Logged Fuel", systemImage: "clock.arrow.circlepath")
                    .font(.headline)
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Spacer()
                
                Text("\(todayMealLogs.count) Items")
                    .font(.caption)
                    .foregroundStyle(AscendTheme.textSecondary)
            }
            
            if todayMealLogs.isEmpty {
                Text("No meals logged yet today. Tap + on any food above to log your portions.")
                    .font(.caption)
                    .foregroundStyle(AscendTheme.textMuted)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(todayMealLogs) { meal in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(meal.mealSlot)
                                        .font(.caption2.bold())
                                        .foregroundStyle(AscendTheme.emerald)
                                    Text("•")
                                        .foregroundStyle(AscendTheme.textMuted)
                                    Text(meal.foodName)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(AscendTheme.textPrimary)
                                }
                                
                                Text("\(Int(meal.proteinGrams))g Protein • \(meal.calories) kcal")
                                    .font(.caption2)
                                    .foregroundStyle(AscendTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                modelContext.delete(meal)
                                try? modelContext.save()
                            } label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .foregroundStyle(AscendTheme.textMuted)
                            }
                        }
                        .padding(10)
                        .background(AscendTheme.bgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
    
    // MARK: - Log Sheet
    private func logFoodSheet(for food: FoodItem) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text(food.name)
                        .font(.title3.bold())
                        .foregroundStyle(AscendTheme.textPrimary)
                    Text(food.portionVisualTip)
                        .font(.caption)
                        .foregroundStyle(AscendTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                // Meal Slot Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meal Timing")
                        .font(.caption)
                        .foregroundStyle(AscendTheme.textSecondary)
                    Picker("Meal Slot", selection: $logMealSlot) {
                        ForEach(["Breakfast", "Lunch", "Pre-Workout Fuel", "Dinner", "Snack"], id: \.self) { slot in
                            Text(slot).tag(slot)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Servings Stepper
                HStack {
                    Text("Portions / Servings")
                        .foregroundStyle(AscendTheme.textPrimary)
                    Spacer()
                    Stepper(String(format: "%.1f portion(s)", logServings), value: $logServings, in: 0.5...5.0, step: 0.5)
                        .foregroundStyle(AscendTheme.textPrimary)
                }
                .padding()
                .background(AscendTheme.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Macro Preview for this log
                HStack(spacing: 16) {
                    VStack {
                        Text("Calories")
                            .font(.caption2)
                            .foregroundStyle(AscendTheme.textSecondary)
                        Text("\(Int(Double(food.calories) * logServings))")
                            .font(.headline.bold())
                            .foregroundStyle(AscendTheme.emerald)
                    }
                    VStack {
                        Text("Protein")
                            .font(.caption2)
                            .foregroundStyle(AscendTheme.textSecondary)
                        Text("\(Int(food.proteinGrams * logServings))g")
                            .font(.headline.bold())
                            .foregroundStyle(AscendTheme.cyan)
                    }
                    VStack {
                        Text("Carbs")
                            .font(.caption2)
                            .foregroundStyle(AscendTheme.textSecondary)
                        Text("\(Int(food.carbsGrams * logServings))g")
                            .font(.headline.bold())
                            .foregroundStyle(AscendTheme.amber)
                    }
                    VStack {
                        Text("Fats")
                            .font(.caption2)
                            .foregroundStyle(AscendTheme.textSecondary)
                        Text("\(Int(food.fatsGrams * logServings))g")
                            .font(.headline.bold())
                            .foregroundStyle(AscendTheme.flame)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .glassCardStyle(cornerRadius: 14)
                
                Spacer()
                
                Button {
                    let log = DailyMealLog(
                        mealSlot: logMealSlot,
                        foodName: food.name,
                        servings: logServings,
                        proteinGrams: food.proteinGrams,
                        carbsGrams: food.carbsGrams,
                        fatsGrams: food.fatsGrams,
                        calories: food.calories
                    )
                    modelContext.insert(log)
                    try? modelContext.save()
                    selectedFoodToLog = nil
                } label: {
                    Text("Add to Today's Fuel Log")
                        .font(.headline.bold())
                        .foregroundStyle(AscendTheme.bgPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AscendTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .ascendBackground()
            .navigationTitle("Log Portion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        selectedFoodToLog = nil
                    }
                    .foregroundStyle(AscendTheme.textSecondary)
                }
            }
        }
    }
}
