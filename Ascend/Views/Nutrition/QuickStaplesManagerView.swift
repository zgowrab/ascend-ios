import SwiftUI
import SwiftData

public struct QuickStaplesManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \SavedFavoriteMeal.useCount, order: .reverse) private var staples: [SavedFavoriteMeal]
    
    @State private var showingAddCustomSheet = false
    
    // New staple fields
    @State private var newName = ""
    @State private var newSlot = "Breakfast"
    @State private var newCalories = "150"
    @State private var newProtein = "10"
    @State private var newCarbs = "15"
    @State private var newFats = "4"
    @State private var newServingDesc = "1 mug / cup"
    @State private var selectedIcon = "cup.and.saucer.fill"
    
    let availableIcons = [
        "cup.and.saucer.fill",
        "cup.and.heat.waves.fill",
        "fork.knife",
        "flame.fill",
        "takeoutbag.and.cup.and.straw.fill",
        "leaf.fill",
        "fish.fill",
        "drop.fill",
        "bolt.fill",
        "apple.logo"
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Daily staples allow 1-tap logging for foods you consume every day (such as morning milk coffee or oats), eliminating repetitive logging.")
                        .font(.caption)
                        .foregroundStyle(AscendTheme.textSecondary)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4))
                }
                
                Section("Your Saved Recurring Foods") {
                    if staples.isEmpty {
                        Text("No saved staples yet. Tap '+ Add Custom Staple' to create your first recurring meal.")
                            .font(.caption)
                            .foregroundStyle(AscendTheme.textMuted)
                    } else {
                        ForEach(staples) { staple in
                            HStack(spacing: 14) {
                                Image(systemName: staple.safeIcon)
                                    .font(.headline)
                                    .foregroundStyle(AscendTheme.emerald)
                                    .frame(width: 36, height: 36)
                                    .background(AscendTheme.bgElevated)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(staple.name)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(AscendTheme.textPrimary)
                                    
                                    HStack(spacing: 8) {
                                        Text("\(staple.calories) kcal")
                                            .font(.caption2.bold())
                                            .foregroundStyle(AscendTheme.emerald)
                                        
                                        Text("•")
                                            .font(.caption2)
                                            .foregroundStyle(AscendTheme.textMuted)
                                        
                                        Text("\(Int(staple.proteinGrams))g Protein")
                                            .font(.caption2)
                                            .foregroundStyle(AscendTheme.cyan)
                                        
                                        Text("•")
                                            .font(.caption2)
                                            .foregroundStyle(AscendTheme.textMuted)
                                        
                                        Text("Logged \(staple.useCount)x")
                                            .font(.caption2)
                                            .foregroundStyle(AscendTheme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(AscendTheme.bgSecondary)
                        }
                        .onDelete(perform: deleteStaples)
                    }
                }
                
                Section {
                    Button {
                        showingAddCustomSheet = true
                    } label: {
                        Label("Add Custom Staple Meal", systemImage: "plus.circle.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(AscendTheme.emerald)
                    }
                    .listRowBackground(AscendTheme.bgSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .ascendBackground()
            .navigationTitle("Manage Daily Staples")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(AscendTheme.emerald)
                }
            }
            .sheet(isPresented: $showingAddCustomSheet) {
                addCustomStapleSheet
            }
        }
    }
    
    private func deleteStaples(at offsets: IndexSet) {
        for index in offsets {
            let staple = staples[index]
            modelContext.delete(staple)
        }
        try? modelContext.save()
    }
    
    // MARK: - Add Custom Staple Sheet
    private var addCustomStapleSheet: some View {
        NavigationStack {
            Form {
                Section("Meal Information") {
                    TextField("Name (e.g. Milk Coffee, Protein Oatmeal)", text: $newName)
                        .foregroundStyle(AscendTheme.textPrimary)
                    
                    Picker("Meal Slot", selection: $newSlot) {
                        ForEach(["Breakfast", "Lunch", "Pre-Workout Fuel", "Dinner", "Snack"], id: \.self) { slot in
                            Text(slot).tag(slot)
                        }
                    }
                    
                    TextField("Serving Size (e.g. 1 mug, 1 bowl)", text: $newServingDesc)
                        .foregroundStyle(AscendTheme.textPrimary)
                }
                .listRowBackground(AscendTheme.bgSecondary)
                
                Section("Macronutrient Profile") {
                    HStack {
                        Text("Calories (kcal)")
                        Spacer()
                        TextField("0", text: $newCalories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", text: $newProtein)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", text: $newCarbs)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fats (g)")
                        Spacer()
                        TextField("0", text: $newFats)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .listRowBackground(AscendTheme.bgSecondary)
                
                Section("Select Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title3)
                                        .foregroundStyle(selectedIcon == icon ? AscendTheme.bgPrimary : AscendTheme.emerald)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon ? AscendTheme.emerald : AscendTheme.bgElevated)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowBackground(AscendTheme.bgSecondary)
            }
            .scrollContentBackground(.hidden)
            .ascendBackground()
            .navigationTitle("New Daily Staple")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingAddCustomSheet = false
                    }
                    .foregroundStyle(AscendTheme.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save Staple") {
                        saveNewCustomStaple()
                    }
                    .font(.subheadline.bold())
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundStyle(AscendTheme.emerald)
                }
            }
        }
    }
    
    private func saveNewCustomStaple() {
        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let staple = SavedFavoriteMeal(
            name: name,
            mealSlot: newSlot,
            calories: Int(newCalories) ?? 0,
            proteinGrams: Double(newProtein) ?? 0,
            carbsGrams: Double(newCarbs) ?? 0,
            fatsGrams: Double(newFats) ?? 0,
            servingDescription: newServingDesc.isEmpty ? "1 serving" : newServingDesc,
            icon: selectedIcon,
            isPinned: true,
            useCount: 0,
            createdAt: Date()
        )
        
        modelContext.insert(staple)
        try? modelContext.save()
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        showingAddCustomSheet = false
    }
}
