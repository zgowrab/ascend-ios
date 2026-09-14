import SwiftUI

public enum AnatomicalPerspective: String, CaseIterable, Identifiable {
    case front = "Anterior (Front)"
    case back = "Posterior (Back)"
    
    public var id: String { rawValue }
}

public struct MuscleActivationProfile {
    public let primaryMuscles: [String]
    public let secondaryMuscles: [String]
    public let defaultPerspective: AnatomicalPerspective
    public let biomechanicalRole: String
    
    public static func profile(for exerciseName: String, muscleGroup: MuscleGroup) -> MuscleActivationProfile {
        let name = exerciseName.lowercased()
        
        if name.contains("bench") || name.contains("push-up") || name.contains("push up") || name.contains("chest press") || name.contains("fly") {
            return MuscleActivationProfile(
                primaryMuscles: ["Chest (Pectoralis Major)"],
                secondaryMuscles: ["Triceps", "Front Deltoids"],
                defaultPerspective: .front,
                biomechanicalRole: "Horizontal adduction and scapular depression under heavy resistance load."
            )
        }
        
        if name.contains("overhead") || name.contains("shoulder press") || name.contains("military") || name.contains("arnold") {
            return MuscleActivationProfile(
                primaryMuscles: ["Shoulders (Deltoids)"],
                secondaryMuscles: ["Triceps", "Upper Chest", "Core"],
                defaultPerspective: .front,
                biomechanicalRole: "Vertical humeral abduction and scapular elevation."
            )
        }
        
        if name.contains("deadlift") || name.contains("rdl") {
            return MuscleActivationProfile(
                primaryMuscles: ["Hamstrings & Glutes", "Lower Back (Erector Spinae)"],
                secondaryMuscles: ["Lats & Traps", "Core", "Forearms"],
                defaultPerspective: .back,
                biomechanicalRole: "Posterior chain hip extension and spinal anti-flexion stability."
            )
        }
        
        if name.contains("pull-up") || name.contains("pull up") || name.contains("lat pull") || name.contains("pulldown") {
            return MuscleActivationProfile(
                primaryMuscles: ["Back (Lats)"],
                secondaryMuscles: ["Biceps", "Rhomboids", "Rear Delts"],
                defaultPerspective: .back,
                biomechanicalRole: "Scapular depression and humeral adduction for lat width and vertical pulling strength."
            )
        }
        
        if name.contains("row") {
            return MuscleActivationProfile(
                primaryMuscles: ["Back (Lats & Traps)"],
                secondaryMuscles: ["Biceps", "Rear Deltoids", "Lower Back"],
                defaultPerspective: .back,
                biomechanicalRole: "Scapular retraction and humeral extension for back thickness."
            )
        }
        
        if name.contains("squat") || name.contains("leg press") || name.contains("lunge") {
            return MuscleActivationProfile(
                primaryMuscles: ["Quads (Quadriceps)", "Glutes"],
                secondaryMuscles: ["Hamstrings", "Calves", "Core"],
                defaultPerspective: .front,
                biomechanicalRole: "Knee extension and hip drive through triple-extension mechanics."
            )
        }
        
        if name.contains("curl") {
            return MuscleActivationProfile(
                primaryMuscles: ["Biceps"],
                secondaryMuscles: ["Forearms", "Brachialis"],
                defaultPerspective: .front,
                biomechanicalRole: "Elbow flexion and forearm supination."
            )
        }
        
        if name.contains("tricep") || name.contains("skull") || name.contains("dip") || name.contains("pushdown") {
            return MuscleActivationProfile(
                primaryMuscles: ["Triceps"],
                secondaryMuscles: ["Chest", "Front Deltoids"],
                defaultPerspective: .back,
                biomechanicalRole: "Elbow extension and lock-out kinetic drive."
            )
        }
        
        if name.contains("plank") || name.contains("crunch") || name.contains("leg raise") || name.contains("ab") {
            return MuscleActivationProfile(
                primaryMuscles: ["Core & Abs"],
                secondaryMuscles: ["Obliques", "Hip Flexors"],
                defaultPerspective: .front,
                biomechanicalRole: "Spinal anti-extension and trunk intra-abdominal bracing."
            )
        }
        
        // Default based on MuscleGroup
        switch muscleGroup {
        case .chest:
            return MuscleActivationProfile(
                primaryMuscles: ["Chest (Pectoralis Major)"],
                secondaryMuscles: ["Triceps", "Front Deltoids"],
                defaultPerspective: .front,
                biomechanicalRole: "Upper body pushing mechanics and pectoral tension."
            )
        case .back:
            return MuscleActivationProfile(
                primaryMuscles: ["Back (Lats & Traps)"],
                secondaryMuscles: ["Biceps", "Rear Delts"],
                defaultPerspective: .back,
                biomechanicalRole: "Posterior torso pulling and spinal stability."
            )
        case .shoulders:
            return MuscleActivationProfile(
                primaryMuscles: ["Shoulders (Deltoids)"],
                secondaryMuscles: ["Triceps", "Upper Traps"],
                defaultPerspective: .front,
                biomechanicalRole: "Deltoid abduction and overhead stability."
            )
        case .quads:
            return MuscleActivationProfile(
                primaryMuscles: ["Quads (Quadriceps)"],
                secondaryMuscles: ["Glutes", "Calves"],
                defaultPerspective: .front,
                biomechanicalRole: "Anterior leg drive and knee extension power."
            )
        case .hamstringsAndGlutes:
            return MuscleActivationProfile(
                primaryMuscles: ["Hamstrings & Glutes"],
                secondaryMuscles: ["Lower Back", "Calves"],
                defaultPerspective: .back,
                biomechanicalRole: "Hip extension and explosive posterior chain power."
            )
        case .arms:
            return MuscleActivationProfile(
                primaryMuscles: ["Biceps & Triceps"],
                secondaryMuscles: ["Forearms"],
                defaultPerspective: .front,
                biomechanicalRole: "Upper extremity articulation and grip strength."
            )
        case .core:
            return MuscleActivationProfile(
                primaryMuscles: ["Core & Abs"],
                secondaryMuscles: ["Obliques"],
                defaultPerspective: .front,
                biomechanicalRole: "Core stabilization and force transmission."
            )
        case .fullBody:
            return MuscleActivationProfile(
                primaryMuscles: ["Full Body Compound"],
                secondaryMuscles: ["Core", "Grip"],
                defaultPerspective: .front,
                biomechanicalRole: "Integrated kinetic chain compound load."
            )
        }
    }
}

public struct TargetMuscleMapVisualizer: View {
    let exerciseName: String
    let muscleGroup: MuscleGroup
    
    @State private var selectedPerspective: AnatomicalPerspective = .front
    @State private var pulseGlow: Bool = false
    
    private var profile: MuscleActivationProfile {
        MuscleActivationProfile.profile(for: exerciseName, muscleGroup: muscleGroup)
    }
    
    public init(exerciseName: String, muscleGroup: MuscleGroup) {
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        _selectedPerspective = State(initialValue: MuscleActivationProfile.profile(for: exerciseName, muscleGroup: muscleGroup).defaultPerspective)
    }
    
    public var body: some View {
        VStack(spacing: 14) {
            // View Switcher: Anterior / Posterior
            Picker("Perspective", selection: $selectedPerspective) {
                ForEach(AnatomicalPerspective.allCases) { p in
                    Text(p.rawValue).tag(p)
                }
            }
            .pickerStyle(.segmented)
            
            // Anatomical Silhouette Stage
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AscendTheme.bgSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AscendTheme.cardBorder, lineWidth: 1)
                    )
                
                // Blueprint Canvas
                Canvas { context, size in
                    drawAnatomicalBody(
                        context: context,
                        size: size,
                        perspective: selectedPerspective,
                        profile: profile,
                        pulse: pulseGlow
                    )
                }
                .frame(height: 250)
                .padding(.vertical, 8)
                
                // Floating Perspective Watermark
                VStack {
                    HStack {
                        Label(
                            selectedPerspective == .front ? "ANTERIOR VIEW" : "POSTERIOR VIEW",
                            systemImage: "figure.stand"
                        )
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(AscendTheme.textMuted)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AscendTheme.bgElevated.opacity(0.8))
                        .clipShape(Capsule())
                        
                        Spacer()
                    }
                    .padding(12)
                    Spacer()
                }
            }
            
            // Muscle Legend & Activation Breakdown
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(AscendTheme.emerald)
                        .frame(width: 8, height: 8)
                    Text("PRIMARY:")
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.textSecondary)
                    
                    ForEach(profile.primaryMuscles, id: \.self) { prim in
                        Text(prim)
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.emerald)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AscendTheme.emerald.opacity(0.18))
                            .clipShape(Capsule())
                    }
                }
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(AscendTheme.cyan)
                        .frame(width: 8, height: 8)
                    Text("SYNERGIST:")
                        .font(.caption2.bold())
                        .foregroundStyle(AscendTheme.textSecondary)
                    
                    ForEach(profile.secondaryMuscles, id: \.self) { sec in
                        Text(sec)
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.cyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AscendTheme.cyan.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                
                Text(profile.biomechanicalRole)
                    .font(.caption)
                    .foregroundStyle(AscendTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(AscendTheme.bgElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
    }
    
    // MARK: - Procedural Anatomical Drawing
    private func drawAnatomicalBody(
        context: GraphicsContext,
        size: CGSize,
        perspective: AnatomicalPerspective,
        profile: MuscleActivationProfile,
        pulse: Bool
    ) {
        let midX = size.width / 2
        let scale: CGFloat = 1.05
        
        // Colors
        let baseBodyColor = Color.white.opacity(0.08)
        let primaryColor = AscendTheme.emerald
        let secondaryColor = AscendTheme.cyan
        
        let isFront = perspective == .front
        
        // Helper to determine muscle status
        let isChestPrimary = isFront && profile.primaryMuscles.contains(where: { $0.lowercased().contains("chest") })
        let isChestSecondary = isFront && profile.secondaryMuscles.contains(where: { $0.lowercased().contains("chest") })
        
        let isShoulderPrimary = profile.primaryMuscles.contains(where: { $0.lowercased().contains("shoulder") })
        let isShoulderSecondary = profile.secondaryMuscles.contains(where: { $0.lowercased().contains("shoulder") || $0.lowercased().contains("delt") })
        
        let isCorePrimary = isFront && profile.primaryMuscles.contains(where: { $0.lowercased().contains("core") || $0.lowercased().contains("abs") })
        let isCoreSecondary = isFront && profile.secondaryMuscles.contains(where: { $0.lowercased().contains("core") })
        
        let isBackPrimary = !isFront && profile.primaryMuscles.contains(where: { $0.lowercased().contains("back") || $0.lowercased().contains("lat") })
        let isBackSecondary = !isFront && profile.secondaryMuscles.contains(where: { $0.lowercased().contains("back") || $0.lowercased().contains("lat") })
        
        let isQuadsPrimary = isFront && profile.primaryMuscles.contains(where: { $0.lowercased().contains("quad") })
        let isQuadsSecondary = isFront && profile.secondaryMuscles.contains(where: { $0.lowercased().contains("quad") })
        
        let isHamsPrimary = !isFront && profile.primaryMuscles.contains(where: { $0.lowercased().contains("ham") || $0.lowercased().contains("glute") })
        let isHamsSecondary = !isFront && profile.secondaryMuscles.contains(where: { $0.lowercased().contains("ham") || $0.lowercased().contains("glute") })
        
        let isArmsPrimary = profile.primaryMuscles.contains(where: { $0.lowercased().contains("arm") || $0.lowercased().contains("bicep") || $0.lowercased().contains("tricep") })
        let isArmsSecondary = profile.secondaryMuscles.contains(where: { $0.lowercased().contains("arm") || $0.lowercased().contains("bicep") || $0.lowercased().contains("tricep") })
        
        // 1. Head & Neck
        let headRect = CGRect(x: midX - 11 * scale, y: 16, width: 22 * scale, height: 26 * scale)
        context.fill(Path(ellipseIn: headRect), with: .color(baseBodyColor))
        context.stroke(Path(ellipseIn: headRect), with: .color(Color.white.opacity(0.2)), lineWidth: 1)
        
        // Neck
        var neck = Path()
        neck.move(to: CGPoint(x: midX - 6 * scale, y: 40))
        neck.addLine(to: CGPoint(x: midX + 6 * scale, y: 40))
        neck.addLine(to: CGPoint(x: midX + 8 * scale, y: 48))
        neck.addLine(to: CGPoint(x: midX - 8 * scale, y: 48))
        context.fill(neck, with: .color(baseBodyColor))
        
        // 2. Shoulders (Deltoids)
        let shoulderColor: Color = isShoulderPrimary ? primaryColor : (isShoulderSecondary ? secondaryColor : baseBodyColor)
        let shoulderLeft = CGRect(x: midX - 44 * scale, y: 46, width: 16 * scale, height: 22 * scale)
        let shoulderRight = CGRect(x: midX + 28 * scale, y: 46, width: 16 * scale, height: 22 * scale)
        
        context.fill(Path(ellipseIn: shoulderLeft), with: .color(shoulderColor))
        context.fill(Path(ellipseIn: shoulderRight), with: .color(shoulderColor))
        if isShoulderPrimary || isShoulderSecondary {
            context.stroke(Path(ellipseIn: shoulderLeft), with: .color(shoulderColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
            context.stroke(Path(ellipseIn: shoulderRight), with: .color(shoulderColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
        }
        
        // 3. Chest (Anterior) or Upper Back (Posterior)
        if isFront {
            // Pectorals
            let chestColor: Color = isChestPrimary ? primaryColor : (isChestSecondary ? secondaryColor : baseBodyColor)
            let pecLeft = CGRect(x: midX - 27 * scale, y: 50, width: 25 * scale, height: 22 * scale)
            let pecRight = CGRect(x: midX + 2 * scale, y: 50, width: 25 * scale, height: 22 * scale)
            
            context.fill(Path(roundedRect: pecLeft, cornerRadius: 4), with: .color(chestColor))
            context.fill(Path(roundedRect: pecRight, cornerRadius: 4), with: .color(chestColor))
            if isChestPrimary || isChestSecondary {
                context.stroke(Path(roundedRect: pecLeft, cornerRadius: 4), with: .color(chestColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
                context.stroke(Path(roundedRect: pecRight, cornerRadius: 4), with: .color(chestColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
            }
            
            // Abs / Core
            let coreColor: Color = isCorePrimary ? primaryColor : (isCoreSecondary ? secondaryColor : baseBodyColor)
            for row in 0..<3 {
                let yPos = 76 + CGFloat(row * 11) * scale
                let abLeft = CGRect(x: midX - 16 * scale, y: yPos, width: 14 * scale, height: 9 * scale)
                let abRight = CGRect(x: midX + 2 * scale, y: yPos, width: 14 * scale, height: 9 * scale)
                context.fill(Path(roundedRect: abLeft, cornerRadius: 2), with: .color(coreColor))
                context.fill(Path(roundedRect: abRight, cornerRadius: 2), with: .color(coreColor))
            }
            if isCorePrimary || isCoreSecondary {
                let coreOutline = CGRect(x: midX - 18 * scale, y: 74, width: 36 * scale, height: 36 * scale)
                context.stroke(Path(roundedRect: coreOutline, cornerRadius: 6), with: .color(coreColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
            }
        } else {
            // Lats & Trapezius (Posterior Back)
            let backColor: Color = isBackPrimary ? primaryColor : (isBackSecondary ? secondaryColor : baseBodyColor)
            
            // Traps (Diamond)
            var traps = Path()
            traps.move(to: CGPoint(x: midX, y: 44))
            traps.addLine(to: CGPoint(x: midX + 24 * scale, y: 52))
            traps.addLine(to: CGPoint(x: midX, y: 76 * scale))
            traps.addLine(to: CGPoint(x: midX - 24 * scale, y: 52))
            traps.closeSubpath()
            context.fill(traps, with: .color(backColor))
            
            // Lats Wings
            var latLeft = Path()
            latLeft.move(to: CGPoint(x: midX - 8 * scale, y: 65))
            latLeft.addLine(to: CGPoint(x: midX - 30 * scale, y: 68))
            latLeft.addLine(to: CGPoint(x: midX - 15 * scale, y: 106))
            latLeft.addLine(to: CGPoint(x: midX - 4 * scale, y: 104))
            latLeft.closeSubpath()
            context.fill(latLeft, with: .color(backColor))
            
            var latRight = Path()
            latRight.move(to: CGPoint(x: midX + 8 * scale, y: 65))
            latRight.addLine(to: CGPoint(x: midX + 30 * scale, y: 68))
            latRight.addLine(to: CGPoint(x: midX + 15 * scale, y: 106))
            latRight.addLine(to: CGPoint(x: midX + 4 * scale, y: 104))
            latRight.closeSubpath()
            context.fill(latRight, with: .color(backColor))
            
            if isBackPrimary || isBackSecondary {
                context.stroke(traps, with: .color(backColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
                context.stroke(latLeft, with: .color(backColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
                context.stroke(latRight, with: .color(backColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
            }
        }
        
        // 4. Arms (Biceps / Triceps & Forearms)
        let armColor: Color = isArmsPrimary ? primaryColor : (isArmsSecondary ? secondaryColor : baseBodyColor)
        
        // Upper arms
        let upperArmLeft = CGRect(x: midX - 46 * scale, y: 70, width: 12 * scale, height: 32 * scale)
        let upperArmRight = CGRect(x: midX + 34 * scale, y: 70, width: 12 * scale, height: 32 * scale)
        context.fill(Path(roundedRect: upperArmLeft, cornerRadius: 4), with: .color(armColor))
        context.fill(Path(roundedRect: upperArmRight, cornerRadius: 4), with: .color(armColor))
        
        // Forearms
        let forearmLeft = CGRect(x: midX - 44 * scale, y: 104, width: 10 * scale, height: 30 * scale)
        let forearmRight = CGRect(x: midX + 34 * scale, y: 104, width: 10 * scale, height: 30 * scale)
        context.fill(Path(roundedRect: forearmLeft, cornerRadius: 3), with: .color(baseBodyColor))
        context.fill(Path(roundedRect: forearmRight, cornerRadius: 3), with: .color(baseBodyColor))
        
        // 5. Pelvis / Glutes
        let pelvisColor: Color = isHamsPrimary ? primaryColor : (isHamsSecondary ? secondaryColor : baseBodyColor)
        if !isFront {
            // Glutes on posterior
            let gluteLeft = CGRect(x: midX - 25 * scale, y: 110, width: 23 * scale, height: 24 * scale)
            let gluteRight = CGRect(x: midX + 2 * scale, y: 110, width: 23 * scale, height: 24 * scale)
            context.fill(Path(roundedRect: gluteLeft, cornerRadius: 6), with: .color(pelvisColor))
            context.fill(Path(roundedRect: gluteRight, cornerRadius: 6), with: .color(pelvisColor))
        } else {
            let pelvis = CGRect(x: midX - 22 * scale, y: 110, width: 44 * scale, height: 20 * scale)
            context.fill(Path(roundedRect: pelvis, cornerRadius: 4), with: .color(baseBodyColor))
        }
        
        // 6. Upper Legs (Quads or Hamstrings)
        let legColor: Color = isFront
            ? (isQuadsPrimary ? primaryColor : (isQuadsSecondary ? secondaryColor : baseBodyColor))
            : (isHamsPrimary ? primaryColor : (isHamsSecondary ? secondaryColor : baseBodyColor))
        
        let thighLeft = CGRect(x: midX - 25 * scale, y: 136, width: 21 * scale, height: 50 * scale)
        let thighRight = CGRect(x: midX + 4 * scale, y: 136, width: 21 * scale, height: 50 * scale)
        context.fill(Path(roundedRect: thighLeft, cornerRadius: 7), with: .color(legColor))
        context.fill(Path(roundedRect: thighRight, cornerRadius: 7), with: .color(legColor))
        if (isFront && (isQuadsPrimary || isQuadsSecondary)) || (!isFront && (isHamsPrimary || isHamsSecondary)) {
            context.stroke(Path(roundedRect: thighLeft, cornerRadius: 7), with: .color(legColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
            context.stroke(Path(roundedRect: thighRight, cornerRadius: 7), with: .color(legColor.opacity(pulse ? 0.9 : 0.4)), lineWidth: 2)
        }
        
        // 7. Lower Legs (Calves)
        let calfLeft = CGRect(x: midX - 23 * scale, y: 190, width: 17 * scale, height: 42 * scale)
        let calfRight = CGRect(x: midX + 6 * scale, y: 190, width: 17 * scale, height: 42 * scale)
        context.fill(Path(roundedRect: calfLeft, cornerRadius: 5), with: .color(baseBodyColor))
        context.fill(Path(roundedRect: calfRight, cornerRadius: 5), with: .color(baseBodyColor))
    }
}
