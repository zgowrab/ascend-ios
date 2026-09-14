import SwiftUI
import SwiftData
import PhotosUI

public struct SmartMealScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var compressionResult: ImageCompressionResult?
    
    @State private var isScanning = false
    @State private var scanProgressText = "Analyzing plate with Vision AI..."
    @State private var scanAnimationPhase: CGFloat = 0
    
    // Prediction state
    @State private var prediction: SmartMealPrediction?
    @State private var mealName: String = ""
    @State private var mealSlot: String = "Lunch"
    @State private var portionMultiplier: Double = 1.0
    @State private var saveToStaples: Bool = false
    @State private var customNotes: String = ""
    
    // Image Picker sheet state (for camera)
    @State private var showingCamera = false
    @State private var cameraUnavailableAlert = false
    
    public init() {}
    
    private var adjustedCalories: Int {
        Int(Double(prediction?.estimatedCalories ?? 0) * portionMultiplier)
    }
    
    private var adjustedProtein: Double {
        (prediction?.proteinGrams ?? 0) * portionMultiplier
    }
    
    private var adjustedCarbs: Double {
        (prediction?.carbsGrams ?? 0) * portionMultiplier
    }
    
    private var adjustedFats: Double {
        (prediction?.fatsGrams ?? 0) * portionMultiplier
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AscendTheme.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let image = capturedImage {
                            imageDisplayAndScanner(image: image)
                            
                            if !isScanning, let pred = prediction {
                                if pred.isFoodDetected {
                                    predictionDetailCard
                                    
                                    portionAdjusterSection
                                    
                                    saveToStaplesSection
                                    
                                    logMealActionButton
                                } else {
                                    noFoodDetectedCard(pred)
                                }
                            }
                        } else {
                            photoPickerHeroView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Smart Meal Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AscendTheme.textSecondary)
                }
                
                if capturedImage != nil && !isScanning {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation(.smooth) {
                                capturedImage = nil
                                prediction = nil
                                compressionResult = nil
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Retake")
                            }
                            .font(.caption.bold())
                            .foregroundStyle(AscendTheme.cyan)
                        }
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await processCapturedImage(image)
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraCaptureWrapper(image: $capturedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: capturedImage) { _, newImg in
                if let newImg = newImg, prediction == nil && !isScanning {
                    Task {
                        await processCapturedImage(newImg)
                    }
                }
            }
            .alert("Camera Unavailable", isPresented: $cameraUnavailableAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Camera is not available on this device simulator. Please choose a photo from the library or select a sample dish.")
            }
        }
    }
    
    // MARK: - Initial Photo Selection Hero
    private var photoPickerHeroView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AscendTheme.emerald.opacity(0.12))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 42))
                        .foregroundStyle(AscendTheme.emerald)
                }
                .padding(.top, 20)
                
                Text("Snap & Auto-Predict")
                    .font(.title2.bold())
                    .foregroundStyle(AscendTheme.textPrimary)
                
                Text("Ascend's Vision AI recognizes your meal, compresses the image by ~95% for instant zero-bloat storage, and predicts calories and macros in seconds.")
                    .font(.subheadline)
                    .foregroundStyle(AscendTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            
            VStack(spacing: 14) {
                // Camera Button
                Button {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showingCamera = true
                    } else {
                        cameraUnavailableAlert = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.headline)
                        Text("Take Meal Photo")
                            .font(.headline.bold())
                    }
                    .foregroundStyle(AscendTheme.bgPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AscendTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // Photo Library Picker
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.headline)
                        Text("Choose from Photo Library")
                            .font(.headline)
                    }
                    .foregroundStyle(AscendTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AscendTheme.bgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AscendTheme.cardBorder, lineWidth: 1)
                    )
                }
            }
            .padding(.top, 10)
            
            // Demo/Preset Quick Test Options for instant testing
            VStack(alignment: .leading, spacing: 12) {
                Text("QUICK TEST PRESETS")
                    .font(.caption2.bold())
                    .foregroundStyle(AscendTheme.textMuted)
                    .tracking(1)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        sampleDishButton(title: "Milk Coffee", icon: "cup.and.saucer.fill", query: "coffee mug latte")
                        sampleDishButton(title: "Oatmeal Bowl", icon: "bowl.fill", query: "oatmeal bowl porridge berries")
                        sampleDishButton(title: "Eggs & Toast", icon: "fork.knife", query: "egg scramble toast")
                        sampleDishButton(title: "Grilled Chicken", icon: "flame.fill", query: "chicken rice vegetables")
                        sampleDishButton(title: "Salmon Plate", icon: "leaf.fill", query: "salmon fish rice")
                    }
                }
            }
            .padding(.top, 16)
        }
    }
    
    private func sampleDishButton(title: String, icon: String, query: String) -> some View {
        Button {
            let simulatedImage = generateSampleMealImage(for: title, icon: icon)
            Task {
                await processCapturedImage(simulatedImage, mockKeywords: query)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(AscendTheme.emerald)
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(AscendTheme.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AscendTheme.bgElevated)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AscendTheme.cardBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Image Display & Scanner Animation HUD
    private func imageDisplayAndScanner(image: UIImage) -> some View {
        ZStack(alignment: .bottom) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isScanning ? AscendTheme.emerald : (prediction?.isFoodDetected == false ? AscendTheme.flame.opacity(0.8) : AscendTheme.cardBorder), lineWidth: isScanning || prediction?.isFoodDetected == false ? 2 : 1)
                )
            
            if isScanning {
                // High-tech scanning overlay
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.45))
                    
                    // Moving Neon Scan Beam
                    GeometryReader { geo in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, AscendTheme.emerald.opacity(0.8), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 12)
                            .shadow(color: AscendTheme.emerald, radius: 12)
                            .offset(y: scanAnimationPhase * (geo.size.height - 12))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 8) {
                        ProgressView()
                            .tint(AscendTheme.emerald)
                            .scaleEffect(1.2)
                        
                        Text(scanProgressText)
                            .font(.caption.bold())
                            .foregroundStyle(AscendTheme.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                .frame(height: 250)
            } else if let pred = prediction, !pred.isFoodDetected {
                // Non-food warning badge
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(AscendTheme.flame)
                    Text("Non-Food: \(pred.detectedObject ?? "Item")")
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(12)
            } else if let compression = compressionResult {
                // Storage optimization badge
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(AscendTheme.emerald)
                    Text("Saved: \(compression.formattedOriginalSize) ➔ \(compression.formattedCompressedSize) (\(compression.savedPercentage)% smaller)")
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(12)
            }
        }
    }
    
    // MARK: - No Food Detected Warning Card
    private func noFoodDetectedCard(_ pred: SmartMealPrediction) -> some View {
        GlassCard(cornerRadius: 20, padding: 22) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AscendTheme.flame.opacity(0.15))
                        .frame(width: 64, height: 64)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(AscendTheme.flame)
                }
                
                VStack(spacing: 6) {
                    Text("No Food Detected")
                        .font(.title3.bold())
                        .foregroundStyle(AscendTheme.textPrimary)
                    
                    Text("This photo looks like **\(pred.detectedObject ?? "a non-food item")** rather than a meal. Zero calories logged. Ascend's scanner is calibrated for meals, snacks, and beverages.")
                        .font(.subheadline)
                        .foregroundStyle(AscendTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 10) {
                    Button {
                        withAnimation(.smooth) {
                            capturedImage = nil
                            prediction = nil
                            compressionResult = nil
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                            Text("Retake Photo")
                        }
                        .font(.headline.bold())
                        .foregroundStyle(AscendTheme.bgPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AscendTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button {
                        withAnimation(.snappy) {
                            prediction?.isFoodDetected = true
                            prediction?.estimatedCalories = 400
                            prediction?.proteinGrams = 25
                            prediction?.carbsGrams = 40
                            prediction?.fatsGrams = 12
                            mealName = "Custom Meal"
                        }
                    } label: {
                        Text("This is food — Enter manually anyway")
                            .font(.caption.bold())
                            .foregroundStyle(AscendTheme.cyan)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
    }
    
    // MARK: - Prediction Detail Card
    private var predictionDetailCard: some View {
        GlassCard(cornerRadius: 20, padding: 18) {
            VStack(alignment: .leading, spacing: 16) {
                // Title & Confidence
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DETECTED MEAL")
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.emerald)
                            .tracking(1)
                        
                        TextField("Meal Name", text: $mealName)
                            .font(.title3.bold())
                            .foregroundStyle(AscendTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    if let conf = prediction?.confidence {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                            Text("\(Int(conf * 100))% match")
                        }
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.emerald)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AscendTheme.emerald.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
                
                Divider()
                
                // Big 4 Macro Prediction Meters
                HStack(spacing: 12) {
                    macroMetricPill(
                        label: "Calories",
                        value: "\(adjustedCalories)",
                        unit: "kcal",
                        color: AscendTheme.emerald
                    )
                    
                    macroMetricPill(
                        label: "Protein",
                        value: String(format: "%.0fg", adjustedProtein),
                        unit: "",
                        color: AscendTheme.cyan
                    )
                    
                    macroMetricPill(
                        label: "Carbs",
                        value: String(format: "%.0fg", adjustedCarbs),
                        unit: "",
                        color: AscendTheme.amber
                    )
                    
                    macroMetricPill(
                        label: "Fats",
                        value: String(format: "%.0fg", adjustedFats),
                        unit: "",
                        color: AscendTheme.flame
                    )
                }
                
                // Meal Timing Slot Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meal Timing")
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.textSecondary)
                    
                    Picker("Meal Slot", selection: $mealSlot) {
                        ForEach(["Breakfast", "Lunch", "Pre-Workout Fuel", "Dinner", "Snack"], id: \.self) { slot in
                            Text(slot).tag(slot)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Ingredients/Component Tags
                if let items = prediction?.breakdownItems, !items.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Plate Components")
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(items, id: \.self) { item in
                                HStack(spacing: 6) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 5))
                                        .foregroundStyle(AscendTheme.emerald)
                                    Text(item)
                                        .font(.caption)
                                        .foregroundStyle(AscendTheme.textPrimary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func macroMetricPill(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(AscendTheme.textSecondary)
            
            Text(value)
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(color)
            
            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 9))
                    .foregroundStyle(AscendTheme.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(AscendTheme.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Portion Adjuster Section
    private var portionAdjusterSection: some View {
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Portion Multiplier")
                            .font(.subheadline.bold())
                            .foregroundStyle(AscendTheme.textPrimary)
                        Text(prediction?.portionDescription ?? "1 Standard Serving")
                            .font(.caption)
                            .foregroundStyle(AscendTheme.textSecondary)
                    }
                    Spacer()
                    Text(String(format: "%.2fx", portionMultiplier))
                        .font(.headline.bold())
                        .monospacedDigit()
                        .foregroundStyle(AscendTheme.cyan)
                }
                
                HStack(spacing: 8) {
                    ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { factor in
                        Button {
                            withAnimation(.snappy) {
                                portionMultiplier = factor
                            }
                        } label: {
                            Text(String(format: "%.2gx", factor))
                                .font(.caption2.bold())
                                .foregroundStyle(portionMultiplier == factor ? AscendTheme.bgPrimary : AscendTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 34)
                                .background(portionMultiplier == factor ? AscendTheme.cyan : AscendTheme.bgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Save to Staples Toggle
    private var saveToStaplesSection: some View {
        Toggle(isOn: $saveToStaples) {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundStyle(AscendTheme.amber)
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Save to Daily Staples")
                        .font(.subheadline.bold())
                        .foregroundStyle(AscendTheme.textPrimary)
                    Text("Adds a 1-tap quick log button for future days")
                        .font(.caption2)
                        .foregroundStyle(AscendTheme.textMuted)
                }
            }
        }
        .padding(14)
        .background(AscendTheme.bgElevated)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    // MARK: - Action Button
    private var logMealActionButton: some View {
        Button {
            saveAndLogMeal()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.headline)
                Text("Log Fuel (+\(adjustedCalories) kcal)")
                    .font(.headline.bold())
            }
            .foregroundStyle(AscendTheme.bgPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AscendTheme.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.top, 6)
        .padding(.bottom, 20)
    }
    
    // MARK: - Processing Logic
    private func processCapturedImage(_ image: UIImage, mockKeywords: String? = nil) async {
        await MainActor.run {
            capturedImage = image
            isScanning = true
            scanAnimationPhase = 0
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                scanAnimationPhase = 1
            }
        }
        
        // 1. Optimize and compress photo
        let result = MealImageStorageService.shared.saveMealPhoto(image)
        
        // 2. Perform Vision AI nutrition analysis
        var pred = await SmartMealScannerService.shared.analyzeMealPhoto(image)
        if let keywords = mockKeywords {
            let customService = SmartMealScannerService.shared
            pred = customService.currentMealSlotByTime() == "Breakfast" ? pred : pred
            if keywords.contains("coffee") {
                pred.foodName = "Milk Coffee / Cafe Latte"
                pred.estimatedCalories = 135
                pred.proteinGrams = 7
                pred.carbsGrams = 12
                pred.fatsGrams = 6
                pred.suggestedMealSlot = "Breakfast"
                pred.breakdownItems = ["Espresso Shot", "Steamed Whole/Oat Milk", "Silky Crema"]
            } else if keywords.contains("oatmeal") {
                pred.foodName = "Morning Oatmeal Bowl with Honey"
                pred.estimatedCalories = 350
                pred.proteinGrams = 11
                pred.carbsGrams = 60
                pred.fatsGrams = 6
                pred.suggestedMealSlot = "Breakfast"
                pred.breakdownItems = ["Rolled Oats", "Blueberries & Sliced Banana", "Raw Honey"]
            }
        }
        
        await MainActor.run {
            self.compressionResult = result
            self.prediction = pred
            self.mealName = pred.foodName
            self.mealSlot = pred.suggestedMealSlot
            self.portionMultiplier = 1.0
            self.isScanning = false
        }
    }
    
    private func saveAndLogMeal() {
        guard let pred = prediction else { return }
        
        // Insert DailyMealLog
        let mealLog = DailyMealLog(
            mealSlot: mealSlot,
            foodName: mealName.isEmpty ? pred.foodName : mealName,
            servings: portionMultiplier,
            proteinGrams: pred.proteinGrams,
            carbsGrams: pred.carbsGrams,
            fatsGrams: pred.fatsGrams,
            calories: pred.estimatedCalories,
            photoFileName: compressionResult?.fileName,
            isSmartScanned: true,
            portionNotes: pred.portionDescription
        )
        modelContext.insert(mealLog)
        
        // If user toggled "Save to Daily Staples", also save as recurring staple
        if saveToStaples {
            let staple = SavedFavoriteMeal(
                name: mealName.isEmpty ? pred.foodName : mealName,
                mealSlot: mealSlot,
                calories: adjustedCalories,
                proteinGrams: adjustedProtein,
                carbsGrams: adjustedCarbs,
                fatsGrams: adjustedFats,
                servingDescription: pred.portionDescription,
                icon: stapleIconFor(name: mealName),
                isPinned: true,
                useCount: 1,
                lastLoggedAt: Date()
            )
            modelContext.insert(staple)
        }
        
        try? modelContext.save()
        
        // Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
    
    private func stapleIconFor(name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("coffee") || lower.contains("latte") || lower.contains("tea") {
            return "cup.and.saucer.fill"
        } else if lower.contains("oat") || lower.contains("bowl") || lower.contains("cereal") {
            return "bowl.fill"
        } else if lower.contains("shake") || lower.contains("smoothie") {
            return "takeoutbag.and.cup.and.straw.fill"
        } else if lower.contains("egg") || lower.contains("toast") {
            return "fork.knife"
        } else if lower.contains("chicken") || lower.contains("salmon") || lower.contains("steak") {
            return "flame.fill"
        }
        return "fork.knife"
    }
    
    private func generateSampleMealImage(for title: String, icon: String) -> UIImage {
        let size = CGSize(width: 600, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            
            // Dark gradient backdrop
            let colors = [UIColor(red: 0.08, green: 0.12, blue: 0.16, alpha: 1.0).cgColor,
                          UIColor(red: 0.03, green: 0.05, blue: 0.07, alpha: 1.0).cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!
            ctx.cgContext.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: size.width, y: size.height), options: [])
            
            // Draw Icon
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 90, weight: .bold)
            if let sfSymbol = UIImage(systemName: icon, withConfiguration: iconConfig)?.withTintColor(UIColor(red: 0.06, green: 0.84, blue: 0.60, alpha: 1.0), renderingMode: .alwaysOriginal) {
                let iconRect = CGRect(x: (size.width - 100) / 2, y: (size.height - 150) / 2, width: 100, height: 100)
                sfSymbol.draw(in: iconRect)
            }
            
            // Draw Title
            let text = title as NSString
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: (size.width - textSize.width) / 2, y: size.height - 110), withAttributes: attrs)
            
            // Subtitle
            let sub = "Ascend Smart Vision Scan Plate" as NSString
            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor(white: 0.7, alpha: 1.0)
            ]
            let subSize = sub.size(withAttributes: subAttrs)
            sub.draw(at: CGPoint(x: (size.width - subSize.width) / 2, y: size.height - 70), withAttributes: subAttrs)
        }
    }
}

// MARK: - Camera Capture UIViewControllerRepresentable
struct CameraCaptureWrapper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCaptureWrapper
        
        init(_ parent: CameraCaptureWrapper) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
