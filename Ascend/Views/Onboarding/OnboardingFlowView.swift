import SwiftUI
import SwiftData

public struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var profile: UserProfile
    
    @State private var currentStep = 0
    @State private var calculatedPlan: MacroCalculationResult?
    
    // Step 1 State
    @State private var nameText: String = "Athlete"
    @State private var ageVal: Int = 26
    @State private var genderChoice: String = "Male"
    @State private var heightVal: Double = 178.0
    @State private var weightVal: Double = 75.0
    
    // Step 2 State
    @State private var selectedGoal: FitnessGoal = .hypertrophy
    
    // Step 3 State
    @State private var selectedEquipment: EquipmentAccess = .commercialGym
    
    // Step 4 State
    @State private var selectedDays: Int = 4
    
    // Step 5 State
    @State private var selectedBudget: BudgetTier = .smartStaples
    @State private var selectedCarb: CarbStaple = .rice
    @State private var selectedProtein: ProteinPreference = .chickenAndEggs
    @State private var selectedDietStyle: DietStyle = .omnivore
    
    public init(profile: UserProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AscendTheme.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header progress bar
                    HStack(spacing: 6) {
                        ForEach(0..<6) { index in
                            Capsule()
                                .fill(index <= currentStep ? AscendTheme.emerald : Color.white.opacity(0.12))
                                .frame(height: 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            switch currentStep {
                            case 0: step1Biometrics
                            case 1: step2Goal
                            case 2: step3Equipment
                            case 3: step4Schedule
                            case 4: step5DietStaples
                            case 5: step6BlueprintSummary
                            default: EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                    
                    // Bottom Controls
                    VStack(spacing: 12) {
                        if currentStep < 5 {
                            Button {
                                withAnimation(.snappy) {
                                    if currentStep == 4 {
                                        recalculate()
                                    }
                                    currentStep += 1
                                }
                            } label: {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundStyle(AscendTheme.bgPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(AscendTheme.primaryGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        } else {
                            Button {
                                completeOnboarding()
                            } label: {
                                HStack {
                                    Text("Commit & Begin Ascension")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.headline.bold())
                                .foregroundStyle(AscendTheme.bgPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AscendTheme.primaryGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: AscendTheme.emerald.opacity(0.35), radius: 12, y: 4)
                            }
                        }
                        
                        if currentStep > 0 {
                            Button {
                                withAnimation(.snappy) {
                                    currentStep -= 1
                                }
                            } label: {
                                Text("Back")
                                    .font(.subheadline)
                                    .foregroundStyle(AscendTheme.textSecondary)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .onAppear {
            nameText = profile.name
            ageVal = profile.age
            genderChoice = profile.gender
            heightVal = profile.heightCm
            weightVal = profile.weightKg
            selectedGoal = profile.goal
            selectedEquipment = profile.equipment
            selectedDays = profile.trainingDaysPerWeek
            selectedBudget = profile.budgetTier
            selectedCarb = profile.carbStaple
            selectedProtein = profile.proteinPreference
            selectedDietStyle = profile.dietStyle
        }
    }
    
    // MARK: - Step 1: Biometrics
    private var step1Biometrics: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Step 1 of 5")
                    .font(.caption.bold())
                    .foregroundStyle(AscendTheme.emerald)
                    .textCase(.uppercase)
                
                Text("Your Physical Baseline")
                    .font(.title2.bold())
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Text("Ascend tailors exact metabolic energy formulas and progressive resistance to your physical body.")
                    .font(.subheadline)
                    .foregroundStyle(AscendTheme.textSecondary)
            }
            
            VStack(spacing: 16) {
                // Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("First Name or Call-Sign")
                        .font(.caption)
                        .foregroundStyle(AscendTheme.textSecondary)
                    TextField("Athlete Name", text: $nameText)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(AscendTheme.bgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(AscendTheme.textPrimary)
                }
                
                // Gender Selection
                HStack(spacing: 12) {
                    ForEach(["Male", "Female"], id: \.self) { g in
                        Button {
                            genderChoice = g
                        } label: {
                            Text(g)
                                .font(.subheadline.bold())
                                .foregroundStyle(genderChoice == g ? AscendTheme.bgPrimary : AscendTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(genderChoice == g ? AscendTheme.emerald : AscendTheme.bgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
                // Age Picker
                HStack {
                    Text("Age")
                        .foregroundStyle(AscendTheme.textPrimary)
                    Spacer()
                    Stepper("\(ageVal) years old", value: $ageVal, in: 14...90)
                        .foregroundStyle(AscendTheme.textPrimary)
                }
                .padding()
                .background(AscendTheme.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Height Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Height")
                            .foregroundStyle(AscendTheme.textPrimary)
                        Spacer()
                        Text("\(Int(heightVal)) cm (\(formatHeightFeetInches(cm: heightVal)))")
                            .font(.headline)
                            .foregroundStyle(AscendTheme.emerald)
                    }
                    Slider(value: $heightVal, in: 140...220, step: 1)
                        .tint(AscendTheme.emerald)
                }
                .padding()
                .background(AscendTheme.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Weight Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Weight")
                            .foregroundStyle(AscendTheme.textPrimary)
                        Spacer()
                        Text(String(format: "%.1f kg (%.1f lbs)", weightVal, weightVal * 2.20462))
                            .font(.headline)
                            .foregroundStyle(AscendTheme.emerald)
                    }
                    Slider(value: $weightVal, in: 45...160, step: 0.5)
                        .tint(AscendTheme.emerald)
                }
                .padding()
                .background(AscendTheme.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Step 2: Goal
    private var step2Goal: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Step 2 of 5")
                    .font(.caption.bold())
                    .foregroundStyle(AscendTheme.emerald)
                    .textCase(.uppercase)
                
                Text("Your Prime Objective")
                    .font(.title2.bold())
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Text("Every rep and macro gram will be calibrated toward this focus.")
                    .font(.subheadline)
                    .foregroundStyle(AscendTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                ForEach(FitnessGoal.allCases) { goal in
                    Button {
                        selectedGoal = goal
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: goal.badge)
                                .font(.title2)
                                .foregroundStyle(selectedGoal == goal ? AscendTheme.bgPrimary : AscendTheme.emerald)
                                .frame(width: 48, height: 48)
                                .background(selectedGoal == goal ? AscendTheme.emerald : AscendTheme.bgElevated)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(goal.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(AscendTheme.textPrimary)
                                
                                Text(goal.tagline)
                                    .font(.caption)
                                    .foregroundStyle(AscendTheme.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            if selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AscendTheme.emerald)
                            }
                        }
                        .padding(16)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedGoal == goal ? AscendTheme.bgElevated : AscendTheme.bgSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedGoal == goal ? AscendTheme.emerald : Color.clear, lineWidth: 1.5)
                                )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Step 3: Equipment
    private var step3Equipment: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Step 3 of 5")
                    .font(.caption.bold())
                    .foregroundStyle(AscendTheme.emerald)
                    .textCase(.uppercase)
                
                Text("Your Training Arena")
                    .font(.title2.bold())
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Text("We only program exercises you can realistically execute with your available setup.")
                    .font(.subheadline)
                    .foregroundStyle(AscendTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                ForEach(EquipmentAccess.allCases) { equip in
                    Button {
                        selectedEquipment = equip
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: equip.icon)
                                .font(.title3)
                                .foregroundStyle(selectedEquipment == equip ? AscendTheme.bgPrimary : AscendTheme.cyan)
                                .frame(width: 44, height: 44)
                                .background(selectedEquipment == equip ? AscendTheme.cyan : AscendTheme.bgElevated)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(equip.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(AscendTheme.textPrimary)
                                
                                Text(equip.detail)
                                    .font(.caption)
                                    .foregroundStyle(AscendTheme.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            if selectedEquipment == equip {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AscendTheme.cyan)
                            }
                        }
                        .padding(16)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedEquipment == equip ? AscendTheme.bgElevated : AscendTheme.bgSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedEquipment == equip ? AscendTheme.cyan : Color.clear, lineWidth: 1.5)
                                )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Step 4: Schedule
    private var step4Schedule: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Step 4 of 5")
                    .font(.caption.bold())
                    .foregroundStyle(AscendTheme.emerald)
                    .textCase(.uppercase)
                
                Text("Weekly Training Frequency")
                    .font(.title2.bold())
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Text("Consistency beats intensity. Choose a frequency you can uphold without burnout.")
                    .font(.subheadline)
                    .foregroundStyle(AscendTheme.textSecondary)
            }
            
            VStack(spacing: 14) {
                let options = [
                    (3, "3 Days / Week", "Full Body Compounding", "Optimal for busy schedules with 48h rest between sessions."),
                    (4, "4 Days / Week", "Upper / Lower Split", "The gold standard sweet spot for muscle building and strength recovery."),
                    (5, "5 Days / Week", "Push / Pull / Legs / Upper / Lower", "High volume frequency for rapid muscular development."),
                    (6, "6 Days / Week", "Push / Pull / Legs (2x)", "Maximum volume for seasoned athletes with disciplined sleep.")
                ]
                
                ForEach(options, id: \.0) { days, title, sub, desc in
                    Button {
                        selectedDays = days
                    } label: {
                        HStack(spacing: 16) {
                            Text("\(days)")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(selectedDays == days ? AscendTheme.bgPrimary : AscendTheme.emerald)
                                .frame(width: 48, height: 48)
                                .background(selectedDays == days ? AscendTheme.emerald : AscendTheme.bgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(title)
                                        .font(.headline)
                                        .foregroundStyle(AscendTheme.textPrimary)
                                    Text("• \(sub)")
                                        .font(.caption.bold())
                                        .foregroundStyle(AscendTheme.emerald)
                                }
                                
                                Text(desc)
                                    .font(.caption)
                                    .foregroundStyle(AscendTheme.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedDays == days ? AscendTheme.bgElevated : AscendTheme.bgSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedDays == days ? AscendTheme.emerald : Color.clear, lineWidth: 1.5)
                                )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Step 5: Diet Staples
    private var step5DietStaples: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Step 5 of 5")
                    .font(.caption.bold())
                    .foregroundStyle(AscendTheme.emerald)
                    .textCase(.uppercase)
                
                Text("Nutrition Staples & Feasibility")
                    .font(.title2.bold())
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Text("Diet success is about eating foods you genuinely enjoy that fit your budget and lifestyle.")
                    .font(.subheadline)
                    .foregroundStyle(AscendTheme.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 18) {
                // Budget Selection
                VStack(alignment: .leading, spacing: 8) {
                    Label("Budget Tier", systemImage: "banknote.fill")
                        .font(.headline)
                        .foregroundStyle(AscendTheme.emerald)
                    
                    ForEach(BudgetTier.allCases) { budget in
                        Button {
                            selectedBudget = budget
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(budget.rawValue)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(AscendTheme.textPrimary)
                                    Text(budget.descriptor)
                                        .font(.caption2)
                                        .foregroundStyle(AscendTheme.textSecondary)
                                }
                                Spacer()
                                if selectedBudget == budget {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AscendTheme.emerald)
                                }
                            }
                            .padding(12)
                            .background(selectedBudget == budget ? AscendTheme.bgElevated : AscendTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                
                // Primary Carb Staple
                VStack(alignment: .leading, spacing: 8) {
                    Label("Primary Carbohydrate Staple", systemImage: "fork.knife")
                        .font(.headline)
                        .foregroundStyle(AscendTheme.cyan)
                    
                    ForEach(CarbStaple.allCases) { carb in
                        Button {
                            selectedCarb = carb
                        } label: {
                            HStack {
                                Text(carb.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(AscendTheme.textPrimary)
                                Spacer()
                                if selectedCarb == carb {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AscendTheme.cyan)
                                }
                            }
                            .padding(12)
                            .background(selectedCarb == carb ? AscendTheme.bgElevated : AscendTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                
                // Primary Protein Source
                VStack(alignment: .leading, spacing: 8) {
                    Label("Primary Protein Staples", systemImage: "flame.fill")
                        .font(.headline)
                        .foregroundStyle(AscendTheme.flame)
                    
                    ForEach(ProteinPreference.allCases) { prot in
                        Button {
                            selectedProtein = prot
                        } label: {
                            HStack {
                                Text(prot.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(AscendTheme.textPrimary)
                                Spacer()
                                if selectedProtein == prot {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AscendTheme.flame)
                                }
                            }
                            .padding(12)
                            .background(selectedProtein == prot ? AscendTheme.bgElevated : AscendTheme.bgSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Step 6: Blueprint Summary
    private var step6BlueprintSummary: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(AscendTheme.emerald)
                    Text("Ascend Blueprint Generated")
                        .font(.caption.bold())
                        .foregroundStyle(AscendTheme.emerald)
                        .textCase(.uppercase)
                }
                
                Text("Your Personalized Directive")
                    .font(.title2.bold())
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Text("Here are your tailored metrics calculated strictly from your inputs.")
                    .font(.subheadline)
                    .foregroundStyle(AscendTheme.textSecondary)
            }
            
            if let plan = calculatedPlan {
                VStack(spacing: 16) {
                    // Calorie & Protein Hero Card
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Calories")
                                .font(.caption)
                                .foregroundStyle(AscendTheme.textSecondary)
                            Text("\(plan.dailyCalories)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(AscendTheme.emerald)
                            Text("kcal / day")
                                .font(.caption2)
                                .foregroundStyle(AscendTheme.textMuted)
                        }
                        
                        Divider().frame(height: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Protein Target")
                                .font(.caption)
                                .foregroundStyle(AscendTheme.textSecondary)
                            Text("\(plan.proteinGrams)g")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(AscendTheme.cyan)
                            Text("~2.0g per kg bodyweight")
                                .font(.caption2)
                                .foregroundStyle(AscendTheme.textMuted)
                        }
                    }
                    .padding(20)
                    .glassCardStyle(cornerRadius: 20)
                    
                    // Supporting Macros
                    HStack(spacing: 12) {
                        VStack(spacing: 2) {
                            Text("Carbs")
                                .font(.caption)
                                .foregroundStyle(AscendTheme.textSecondary)
                            Text("\(plan.carbsGrams)g")
                                .font(.headline.bold())
                                .foregroundStyle(AscendTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AscendTheme.bgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(spacing: 2) {
                            Text("Fats")
                                .font(.caption)
                                .foregroundStyle(AscendTheme.textSecondary)
                            Text("\(plan.fatsGrams)g")
                                .font(.headline.bold())
                                .foregroundStyle(AscendTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AscendTheme.bgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(spacing: 2) {
                            Text("Hydration")
                                .font(.caption)
                                .foregroundStyle(AscendTheme.textSecondary)
                            Text(String(format: "%.1f L", plan.waterLiters))
                                .font(.headline.bold())
                                .foregroundStyle(AscendTheme.cyan)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AscendTheme.bgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Training Strategy Card
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Training Allocation", systemImage: "dumbbell.fill")
                            .font(.headline)
                            .foregroundStyle(AscendTheme.emerald)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Arena: \(selectedEquipment.rawValue)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(AscendTheme.textPrimary)
                                Text("Frequency: \(selectedDays) Days / Week")
                                    .font(.caption)
                                    .foregroundStyle(AscendTheme.textSecondary)
                            }
                            Spacer()
                        }
                        
                        Text("Personalized routines will be populated into your Workouts tab ready for live guidance.")
                            .font(.caption2)
                            .foregroundStyle(AscendTheme.textMuted)
                    }
                    .padding(16)
                    .glassCardStyle(cornerRadius: 16)
                    
                    // Food & Portions Summary Card
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Nutrition & Portions Strategy", systemImage: "leaf.fill")
                            .font(.headline)
                            .foregroundStyle(AscendTheme.cyan)
                        
                        Text("Staples: \(selectedCarb.rawValue) + \(selectedProtein.rawValue)")
                            .font(.subheadline.bold())
                            .foregroundStyle(AscendTheme.textPrimary)
                        
                        Text("Budget Tier: \(selectedBudget.rawValue)")
                            .font(.caption)
                            .foregroundStyle(AscendTheme.textSecondary)
                        
                        Text("You will receive hand-based visual portion guides in your Nutrition tab so you never have to obsessively carry food scales.")
                            .font(.caption2)
                            .foregroundStyle(AscendTheme.textMuted)
                    }
                    .padding(16)
                    .glassCardStyle(cornerRadius: 16)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func recalculate() {
        calculatedPlan = OnboardingCalculator.calculateTargets(
            age: ageVal,
            gender: genderChoice,
            heightCm: heightVal,
            weightKg: weightVal,
            goal: selectedGoal,
            daysPerWeek: selectedDays
        )
    }
    
    private func completeOnboarding() {
        recalculate()
        guard let plan = calculatedPlan else { return }
        
        // Update profile
        profile.name = nameText.isEmpty ? "Athlete" : nameText
        profile.age = ageVal
        profile.gender = genderChoice
        profile.heightCm = heightVal
        profile.weightKg = weightVal
        profile.goal = selectedGoal
        profile.equipment = selectedEquipment
        profile.trainingDaysPerWeek = selectedDays
        profile.budgetTier = selectedBudget
        profile.carbStaple = selectedCarb
        profile.proteinPreference = selectedProtein
        profile.dietStyle = selectedDietStyle
        
        profile.dailyCalorieTarget = plan.dailyCalories
        profile.dailyProteinGrams = plan.proteinGrams
        profile.dailyCarbsGrams = plan.carbsGrams
        profile.dailyFatsGrams = plan.fatsGrams
        profile.dailyWaterTargetLiters = plan.waterLiters
        
        // Seed database
        // 1. Exercise catalog
        for ex in RoutineGenerator.defaultExerciseCatalog() {
            modelContext.insert(ex)
        }
        
        // 2. Personalized routine
        let routine = RoutineGenerator.generatePersonalizedRoutine(for: profile)
        modelContext.insert(routine)
        
        // 3. Food catalog
        for food in RoutineGenerator.defaultFoodCatalog() {
            modelContext.insert(food)
        }
        
        // 4. Supplement stack
        for supp in RoutineGenerator.defaultSupplementCatalog() {
            modelContext.insert(supp)
        }
        
        // 5. Initial daily discipline entry for today
        let todayDiscipline = DailyDisciplineEntry(
            date: Calendar.current.startOfDay(for: Date()),
            workoutCompleted: false,
            proteinHit: false,
            supplementsTaken: false,
            hydrationHit: false,
            sleepHit: false
        )
        modelContext.insert(todayDiscipline)
        
        profile.isOnboarded = true
        try? modelContext.save()
    }
    
    private func formatHeightFeetInches(cm: Double) -> String {
        let totalInches = cm / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return "\(feet)'\(inches)\""
    }
}
