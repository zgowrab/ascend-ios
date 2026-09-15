import SwiftUI

public enum MovementPattern: String, CaseIterable {
    case horizontalPress = "Horizontal Press"
    case verticalPress = "Vertical Press"
    case horizontalPull = "Horizontal Pull"
    case verticalPull = "Vertical Pull"
    case squat = "Squat Pattern"
    case hinge = "Hip Hinge"
    case curl = "Bicep Flexion"
    case tricepExtension = "Tricep Extension"
    case coreFlexion = "Core Flexion"
    
    public static func detect(for exerciseName: String, muscleGroup: MuscleGroup) -> MovementPattern {
        let name = exerciseName.lowercased()
        
        if name.contains("bench") || name.contains("push-up") || name.contains("push up") || name.contains("chest press") || name.contains("fly") {
            return .horizontalPress
        }
        if name.contains("overhead") || name.contains("shoulder press") || name.contains("lateral raise") || name.contains("arnold") || name.contains("military") {
            return .verticalPress
        }
        if name.contains("row") || name.contains("face pull") {
            return .horizontalPull
        }
        if name.contains("pull-up") || name.contains("pull up") || name.contains("chin-up") || name.contains("chin up") || name.contains("pulldown") || name.contains("lat pull") {
            return .verticalPull
        }
        if name.contains("squat") || name.contains("leg press") || name.contains("lunge") || name.contains("split squat") || name.contains("hack") {
            return .squat
        }
        if name.contains("deadlift") || name.contains("rdl") || name.contains("hip thrust") || name.contains("good morning") {
            return .hinge
        }
        if name.contains("curl") {
            return .curl
        }
        if name.contains("tricep") || name.contains("skull") || name.contains("dip") || name.contains("pushdown") || name.contains("extension") {
            return .tricepExtension
        }
        if name.contains("plank") || name.contains("crunch") || name.contains("leg raise") || name.contains("ab") {
            return .coreFlexion
        }
        
        // Muscle group fallbacks
        switch muscleGroup {
        case .chest: return .horizontalPress
        case .shoulders: return .verticalPress
        case .back: return .horizontalPull
        case .quads: return .squat
        case .hamstringsAndGlutes: return .hinge
        case .arms: return .curl
        case .core: return .coreFlexion
        case .fullBody: return .hinge
        }
    }
}

public struct ExerciseKinematicAnimationView: View {
    let exerciseName: String
    let muscleGroup: MuscleGroup
    var height: CGFloat = 240
    
    @State private var isPlaying: Bool = true
    
    private var pattern: MovementPattern {
        MovementPattern.detect(for: exerciseName, muscleGroup: muscleGroup)
    }
    
    public init(exerciseName: String, muscleGroup: MuscleGroup, height: CGFloat = 240) {
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.height = height
    }
    
    public var body: some View {
        TimelineView(.animation(paused: !isPlaying)) { timeline in
            let date = timeline.date.timeIntervalSinceReferenceDate
            let cyclePeriod: Double = 4.0
            let phaseProgress = (date.truncatingRemainder(dividingBy: cyclePeriod)) / cyclePeriod
            
            // Calculate movement depth factor: 0.0 (start/lockout) to 1.0 (deepest eccentric tension)
            let depthFactor: CGFloat = {
                if phaseProgress < 0.55 {
                    let p = phaseProgress / 0.55
                    return CGFloat(sin(p * .pi / 2))
                } else if phaseProgress < 0.65 {
                    return 1.0
                } else {
                    let p = (phaseProgress - 0.65) / 0.35
                    return CGFloat(cos(p * .pi / 2))
                }
            }()
            
            let phaseText: String = {
                if phaseProgress < 0.55 {
                    return "ECCENTRIC • 3s LOWER"
                } else if phaseProgress < 0.65 {
                    return "PEAK TENSION • PAUSE"
                } else {
                    return "CONCENTRIC • EXPLODE"
                }
            }()
            
            let phaseColor: Color = {
                if phaseProgress < 0.55 {
                    return AscendTheme.cyan
                } else if phaseProgress < 0.65 {
                    return AscendTheme.amber
                } else {
                    return AscendTheme.emerald
                }
            }()
            
            ZStack {
                // Background dark gym stage
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AscendTheme.bgSecondary, AscendTheme.bgPrimary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AscendTheme.cardBorder, lineWidth: 1)
                    )
                
                // Subtle architectural gym grid
                GymStageGrid()
                    .opacity(0.12)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                
                // Realistic Sculpted Human Athletic Canvas
                Canvas { context, size in
                    drawAthleticMovement(
                        context: context,
                        size: size,
                        pattern: pattern,
                        depth: depthFactor,
                        phaseProgress: phaseProgress
                    )
                }
                
                // Top HUD Bar
                VStack {
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(phaseColor)
                                .frame(width: 8, height: 8)
                            Text(phaseText)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(phaseColor)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(phaseColor.opacity(0.14))
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        Button {
                            isPlaying.toggle()
                        } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.caption.bold())
                                .foregroundStyle(AscendTheme.textSecondary)
                                .padding(8)
                                .background(AscendTheme.bgElevated)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // Bottom Movement Badge & Tempo Cadence Bar
                    HStack {
                        Text(pattern.rawValue)
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        Spacer()
                        
                        HStack(spacing: 3) {
                            ForEach(0..<4) { index in
                                let active = Int(phaseProgress * 4) >= index
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(active ? phaseColor : AscendTheme.textMuted.opacity(0.3))
                                    .frame(width: 14, height: 4)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                }
            }
            .frame(height: height)
        }
    }
    
    // MARK: - Athletic Movement Router
    private func drawAthleticMovement(
        context: GraphicsContext,
        size: CGSize,
        pattern: MovementPattern,
        depth: CGFloat,
        phaseProgress: Double
    ) {
        let midX = size.width / 2
        let midY = size.height / 2
        
        switch pattern {
        case .horizontalPress:
            drawHumanBenchPress(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .verticalPress:
            drawHumanOverheadPress(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .squat:
            drawHumanSquat(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .hinge:
            drawHumanDeadlift(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .verticalPull:
            drawHumanPullUp(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .horizontalPull:
            drawHumanBentOverRow(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .curl:
            drawHumanBicepCurl(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .tricepExtension:
            drawHumanTricepPushdown(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .coreFlexion:
            drawHumanCoreLegRaise(context: context, size: size, midX: midX, midY: midY, depth: depth)
        }
    }
    
    // MARK: - 1. Sculpted Human Bench Press
    private func drawHumanBenchPress(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        // High-density padded bench with leatherette dual-tone & steel support
        let benchY = midY + 28
        let benchPad = CGRect(x: midX - 85, y: benchY, width: 155, height: 12)
        context.fill(Path(roundedRect: benchPad, cornerRadius: 4), with: .color(Color(white: 0.18)))
        context.stroke(Path(roundedRect: benchPad, cornerRadius: 4), with: .color(Color(white: 0.3)), lineWidth: 1.5)
        
        // Steel frame legs
        var legs = Path()
        legs.move(to: CGPoint(x: midX - 65, y: benchY + 12))
        legs.addLine(to: CGPoint(x: midX - 65, y: benchY + 48))
        legs.move(to: CGPoint(x: midX + 45, y: benchY + 12))
        legs.addLine(to: CGPoint(x: midX + 45, y: benchY + 48))
        context.stroke(legs, with: .color(Color(white: 0.35)), lineWidth: 4)
        
        // Barbell trajectory: top is midY - 48, bottom is midY + 10
        let barY = (midY - 48) + (depth * 58)
        let barX = midX - 8
        
        // --- 1. FAR LEG (Background layer for 3D depth) ---
        let farHip = CGPoint(x: midX + 22, y: benchY - 4)
        let farKnee = CGPoint(x: midX + 48, y: benchY + 22)
        let farFoot = CGPoint(x: midX + 48, y: benchY + 48)
        drawMuscularLeg(context: context, hip: farHip, knee: farKnee, ankle: farFoot, isForeground: false)
        
        // --- 2. ATHLETE TORSO & HEAD ---
        let headPos = CGPoint(x: midX - 62, y: benchY - 10)
        let shoulderPos = CGPoint(x: midX - 25, y: benchY - 6)
        let hipPos = CGPoint(x: midX + 25, y: benchY - 6)
        
        // Head & Jawline
        drawAthleticHead(context: context, center: headPos, angle: 0)
        
        // Muscular Torso with Pectoral Swell
        let pecFlexRatio = 1.0 - depth // maximum flex at lockout
        drawMuscularTorsoSide(
            context: context,
            shoulder: shoulderPos,
            hip: hipPos,
            pecSwell: pecFlexRatio,
            isLyingDown: true
        )
        
        // --- 3. FOREGROUND LEG ---
        let nearHip = CGPoint(x: midX + 28, y: benchY - 2)
        let nearKnee = CGPoint(x: midX + 54, y: benchY + 20)
        let nearFoot = CGPoint(x: midX + 54, y: benchY + 48)
        drawMuscularLeg(context: context, hip: nearHip, knee: nearKnee, ankle: nearFoot, isForeground: true)
        
        // --- 4. ARMS & MUSCULAR ARTICULATION ---
        let elbowY = (midY - 14) + (depth * 34)
        let elbowX = (midX - 32) + (depth * 6)
        let handPos = CGPoint(x: barX, y: barY)
        
        drawMuscularArm(
            context: context,
            shoulder: shoulderPos,
            elbow: CGPoint(x: elbowX, y: elbowY),
            hand: handPos,
            isFlexed: pecFlexRatio > 0.6,
            isForeground: true
        )
        
        // --- 5. OLYMPIC BARBELL & WEIGHT PLATES ---
        drawOlympicBarbell(context: context, center: handPos, width: 95)
    }
    
    // MARK: - 2. Sculpted Human Overhead Press
    private func drawHumanOverheadPress(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        let floorY = midY + 74
        drawGymFloor(context: context, midX: midX, floorY: floorY)
        
        let hipPos = CGPoint(x: midX, y: midY + 20)
        let shoulderPos = CGPoint(x: midX, y: midY - 18)
        let headPos = CGPoint(x: midX, y: midY - 34)
        
        // Legs (Far and Near)
        drawMuscularLeg(context: context, hip: hipPos, knee: CGPoint(x: midX - 12, y: midY + 48), ankle: CGPoint(x: midX - 12, y: floorY), isForeground: false)
        drawMuscularLeg(context: context, hip: hipPos, knee: CGPoint(x: midX + 12, y: midY + 48), ankle: CGPoint(x: midX + 12, y: floorY), isForeground: true)
        
        // Torso
        drawMuscularTorsoFront(context: context, shoulder: shoulderPos, hip: hipPos, deltoidFlex: 1.0 - depth)
        drawAthleticHead(context: context, center: headPos, angle: 0)
        
        // Barbell overhead motion: depth 0 is lockout (midY - 68), depth 1 is at collarbone (midY - 14)
        let barY = (midY - 68) + (depth * 54)
        
        let elbowY = (midY - 36) + (depth * 38)
        let elbowLeftX = midX - 22 - (depth * 8)
        let elbowRightX = midX + 22 + (depth * 8)
        
        // Arms
        drawMuscularArm(context: context, shoulder: CGPoint(x: midX - 16, y: shoulderPos.y), elbow: CGPoint(x: elbowLeftX, y: elbowY), hand: CGPoint(x: midX - 22, y: barY), isFlexed: depth < 0.4, isForeground: true)
        drawMuscularArm(context: context, shoulder: CGPoint(x: midX + 16, y: shoulderPos.y), elbow: CGPoint(x: elbowRightX, y: elbowY), hand: CGPoint(x: midX + 22, y: barY), isFlexed: depth < 0.4, isForeground: true)
        
        // Barbell
        drawOlympicBarbell(context: context, center: CGPoint(x: midX, y: barY), width: 95)
    }
    
    // MARK: - 3. Sculpted Human Squat
    private func drawHumanSquat(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        let floorY = midY + 74
        drawGymFloor(context: context, midX: midX, floorY: floorY)
        
        // Dynamic biomechanical squat kinematics
        let hipX = midX - 4 - (depth * 28)
        let hipY = (midY + 14) + (depth * 36)
        
        let shoulderX = midX + 4 - (depth * 12)
        let shoulderY = (midY - 24) + (depth * 36)
        
        let kneeX = midX + 10 + (depth * 12)
        let kneeY = (midY + 44) + (depth * 6)
        
        let ankleX = midX + 6
        let ankleY = floorY
        
        // 1. Far Leg
        let farHip = CGPoint(x: hipX - 4, y: hipY - 2)
        let farKnee = CGPoint(x: kneeX - 4, y: kneeY)
        let farAnkle = CGPoint(x: ankleX - 4, y: ankleY)
        drawMuscularLeg(context: context, hip: farHip, knee: farKnee, ankle: farAnkle, isForeground: false)
        
        // 2. Torso with athletic back arch & spinal bracing
        drawMuscularTorsoSide(
            context: context,
            shoulder: CGPoint(x: shoulderX, y: shoulderY),
            hip: CGPoint(x: hipX, y: hipY),
            pecSwell: 0.5,
            isLyingDown: false
        )
        
        // Head tilted proud
        let headPos = CGPoint(x: shoulderX + 6, y: shoulderY - 16)
        drawAthleticHead(context: context, center: headPos, angle: 0.1)
        
        // 3. Near Leg with powerful quad teardrop flex
        let nearHip = CGPoint(x: hipX, y: hipY)
        let nearKnee = CGPoint(x: kneeX, y: kneeY)
        let nearAnkle = CGPoint(x: ankleX, y: ankleY)
        drawMuscularLeg(context: context, hip: nearHip, knee: nearKnee, ankle: nearAnkle, isForeground: true)
        
        // Barbell resting comfortably across traps
        let barY = shoulderY - 2
        let barCenter = CGPoint(x: shoulderX, y: barY)
        drawOlympicBarbell(context: context, center: barCenter, width: 85)
        
        // Hands gripping bar
        let handPos = CGPoint(x: shoulderX + 18, y: barY + 2)
        drawMuscularArm(
            context: context,
            shoulder: CGPoint(x: shoulderX, y: shoulderY),
            elbow: CGPoint(x: shoulderX + 10, y: shoulderY + 16),
            hand: handPos,
            isFlexed: true,
            isForeground: true
        )
    }
    
    // MARK: - 4. Sculpted Human Deadlift
    private func drawHumanDeadlift(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        let floorY = midY + 74
        drawGymFloor(context: context, midX: midX, floorY: floorY)
        
        // Hinge kinematics
        let hipX = midX - (depth * 34)
        let hipY = (midY + 14) + (depth * 14)
        
        let shoulderX = midX + 8 + (depth * 6)
        let shoulderY = (midY - 26) + (depth * 44)
        
        let kneeX = midX + 6 + (depth * 8)
        let kneeY = midY + 44
        
        let ankleX = midX + 6
        let ankleY = floorY
        
        let barX = midX + 18
        let barY = (midY + 14) + (depth * 52)
        
        // Far Leg
        drawMuscularLeg(context: context, hip: CGPoint(x: hipX - 4, y: hipY), knee: CGPoint(x: kneeX - 4, y: kneeY), ankle: CGPoint(x: ankleX - 4, y: ankleY), isForeground: false)
        
        // Torso & flat neutral spine
        drawMuscularTorsoSide(context: context, shoulder: CGPoint(x: shoulderX, y: shoulderY), hip: CGPoint(x: hipX, y: hipY), pecSwell: 0.4, isLyingDown: false)
        drawAthleticHead(context: context, center: CGPoint(x: shoulderX + 8, y: shoulderY - 14), angle: 0.1)
        
        // Near Leg
        drawMuscularLeg(context: context, hip: CGPoint(x: hipX, y: hipY), knee: CGPoint(x: kneeX, y: kneeY), ankle: CGPoint(x: ankleX, y: ankleY), isForeground: true)
        
        // Long straight arms dragging bar along shins
        drawMuscularArm(
            context: context,
            shoulder: CGPoint(x: shoulderX, y: shoulderY),
            elbow: CGPoint(x: (shoulderX + barX) / 2, y: (shoulderY + barY) / 2),
            hand: CGPoint(x: barX, y: barY),
            isFlexed: true,
            isForeground: true
        )
        
        // Olympic Barbell with large 450mm diameter bumper plates
        drawOlympicBarbell(context: context, center: CGPoint(x: barX, y: barY), width: 80, plateRadius: 20)
    }
    
    // MARK: - 5. Sculpted Human Pull-Up
    private func drawHumanPullUp(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        // Overhead bar
        var bar = Path()
        bar.move(to: CGPoint(x: midX - 65, y: midY - 62))
        bar.addLine(to: CGPoint(x: midX + 65, y: midY - 62))
        context.stroke(bar, with: .color(Color(white: 0.8)), lineWidth: 5)
        
        let bodyOffset = (1.0 - depth) * 44
        let shoulderY = (midY - 26) + bodyOffset
        let hipY = (midY + 16) + bodyOffset
        
        // Torso with lat flare
        drawMuscularTorsoFront(context: context, shoulder: CGPoint(x: midX, y: shoulderY), hip: CGPoint(x: midX, y: hipY), deltoidFlex: depth)
        drawAthleticHead(context: context, center: CGPoint(x: midX, y: shoulderY - 16), angle: 0)
        
        // Legs with slight athletic knee tuck
        drawMuscularLeg(context: context, hip: CGPoint(x: midX, y: hipY), knee: CGPoint(x: midX - 6, y: hipY + 30), ankle: CGPoint(x: midX - 12, y: hipY + 54), isForeground: true)
        
        // Muscular arms pulling to bar
        let handLeft = CGPoint(x: midX - 36, y: midY - 62)
        let handRight = CGPoint(x: midX + 36, y: midY - 62)
        
        let elbowLeft = CGPoint(x: midX - 26 - (depth * 8), y: shoulderY + 4)
        let elbowRight = CGPoint(x: midX + 26 + (depth * 8), y: shoulderY + 4)
        
        drawMuscularArm(context: context, shoulder: CGPoint(x: midX - 16, y: shoulderY), elbow: elbowLeft, hand: handLeft, isFlexed: depth > 0.5, isForeground: true)
        drawMuscularArm(context: context, shoulder: CGPoint(x: midX + 16, y: shoulderY), elbow: elbowRight, hand: handRight, isFlexed: depth > 0.5, isForeground: true)
    }
    
    // MARK: - 6. Sculpted Human Bent-Over Row
    private func drawHumanBentOverRow(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        let floorY = midY + 74
        drawGymFloor(context: context, midX: midX, floorY: floorY)
        
        let hip = CGPoint(x: midX - 26, y: midY + 14)
        let shoulder = CGPoint(x: midX + 16, y: midY - 14)
        
        // Legs
        drawMuscularLeg(context: context, hip: hip, knee: CGPoint(x: midX - 10, y: midY + 44), ankle: CGPoint(x: midX - 6, y: floorY), isForeground: true)
        
        // Torso
        drawMuscularTorsoSide(context: context, shoulder: shoulder, hip: hip, pecSwell: 0.3, isLyingDown: false)
        drawAthleticHead(context: context, center: CGPoint(x: shoulder.x + 12, y: shoulder.y - 12), angle: 0.1)
        
        // Bar path: pulling from midY + 34 up into lower ribs (midY - 2)
        let barX = midX + 6
        let barY = (midY + 34) - (depth * 36)
        
        let elbowX = (midX + 6) - (depth * 24)
        let elbowY = (midY + 8) - (depth * 18)
        
        drawMuscularArm(context: context, shoulder: shoulder, elbow: CGPoint(x: elbowX, y: elbowY), hand: CGPoint(x: barX, y: barY), isFlexed: depth > 0.5, isForeground: true)
        drawOlympicBarbell(context: context, center: CGPoint(x: barX, y: barY), width: 75)
    }
    
    // MARK: - 7. Sculpted Human Bicep Curl
    private func drawHumanBicepCurl(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        let floorY = midY + 74
        drawGymFloor(context: context, midX: midX, floorY: floorY)
        
        let hip = CGPoint(x: midX - 4, y: midY + 20)
        let shoulder = CGPoint(x: midX - 4, y: midY - 20)
        
        drawMuscularLeg(context: context, hip: hip, knee: CGPoint(x: midX - 4, y: midY + 48), ankle: CGPoint(x: midX - 4, y: floorY), isForeground: true)
        drawMuscularTorsoSide(context: context, shoulder: shoulder, hip: hip, pecSwell: 0.4, isLyingDown: false)
        drawAthleticHead(context: context, center: CGPoint(x: midX - 4, y: shoulder.y - 16), angle: 0)
        
        let elbow = CGPoint(x: midX + 6, y: midY + 8)
        let curlAngle: CGFloat = (.pi / 2) - (depth * 2.3)
        let forearmLength: CGFloat = 36
        let hand = CGPoint(x: elbow.x + (cos(curlAngle) * forearmLength), y: elbow.y + (sin(curlAngle) * forearmLength))
        
        drawMuscularArm(context: context, shoulder: shoulder, elbow: elbow, hand: hand, isFlexed: depth > 0.5, isForeground: true)
        
        // Dumbbell in hand
        context.fill(Path(roundedRect: CGRect(x: hand.x - 10, y: hand.y - 7, width: 20, height: 14), cornerRadius: 4), with: .color(AscendTheme.cyan))
        context.stroke(Path(roundedRect: CGRect(x: hand.x - 10, y: hand.y - 7, width: 20, height: 14), cornerRadius: 4), with: .color(.white), lineWidth: 1.5)
    }
    
    // MARK: - 8. Sculpted Human Tricep Pushdown
    private func drawHumanTricepPushdown(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        let floorY = midY + 74
        drawGymFloor(context: context, midX: midX, floorY: floorY)
        
        // Cable tower guide
        var cable = Path()
        cable.move(to: CGPoint(x: midX + 24, y: midY - 65))
        cable.addLine(to: CGPoint(x: midX + 24, y: midY - 6))
        context.stroke(cable, with: .color(Color(white: 0.4)), lineWidth: 2)
        
        let hip = CGPoint(x: midX - 16, y: midY + 24)
        let shoulder = CGPoint(x: midX - 8, y: midY - 14)
        
        drawMuscularLeg(context: context, hip: hip, knee: CGPoint(x: midX - 10, y: midY + 50), ankle: CGPoint(x: midX - 8, y: floorY), isForeground: true)
        drawMuscularTorsoSide(context: context, shoulder: shoulder, hip: hip, pecSwell: 0.3, isLyingDown: false)
        drawAthleticHead(context: context, center: CGPoint(x: shoulder.x - 4, y: shoulder.y - 16), angle: -0.1)
        
        let elbow = CGPoint(x: midX + 4, y: midY + 8)
        let angle: CGFloat = (-0.2) + (depth * 1.7)
        let hand = CGPoint(x: elbow.x + (cos(angle) * 36), y: elbow.y + (sin(angle) * 36))
        
        drawMuscularArm(context: context, shoulder: shoulder, elbow: elbow, hand: hand, isFlexed: depth > 0.6, isForeground: true)
    }
    
    // MARK: - 9. Sculpted Human Core Leg Raise
    private func drawHumanCoreLegRaise(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        var bar = Path()
        bar.move(to: CGPoint(x: midX - 55, y: midY - 60))
        bar.addLine(to: CGPoint(x: midX + 55, y: midY - 60))
        context.stroke(bar, with: .color(Color(white: 0.8)), lineWidth: 5)
        
        let shoulder = CGPoint(x: midX, y: midY - 28)
        let hip = CGPoint(x: midX, y: midY + 16)
        
        // Overhead arms hanging
        drawMuscularArm(context: context, shoulder: shoulder, elbow: CGPoint(x: midX, y: midY - 44), hand: CGPoint(x: midX, y: midY - 60), isFlexed: false, isForeground: true)
        
        // Torso
        drawMuscularTorsoFront(context: context, shoulder: shoulder, hip: hip, deltoidFlex: 0.3)
        drawAthleticHead(context: context, center: CGPoint(x: midX, y: shoulder.y - 16), angle: 0)
        
        // Legs lifting up
        let legAngle: CGFloat = (.pi / 2) - (depth * (.pi / 2))
        let knee = CGPoint(x: hip.x + (cos(legAngle) * 32), y: hip.y + (sin(legAngle) * 32))
        let foot = CGPoint(x: hip.x + (cos(legAngle) * 58), y: hip.y + (sin(legAngle) * 58))
        
        drawMuscularLeg(context: context, hip: hip, knee: knee, ankle: foot, isForeground: true)
    }
    
    // MARK: - Anatomical Component Rendering Helpers
    
    private func drawAthleticHead(context: GraphicsContext, center: CGPoint, angle: CGFloat) {
        let headBox = CGRect(x: center.x - 9, y: center.y - 10, width: 18, height: 20)
        context.fill(Path(ellipseIn: headBox), with: .color(AscendTheme.textPrimary))
        // Athletic jaw contour
        var jaw = Path()
        jaw.move(to: CGPoint(x: center.x - 8, y: center.y + 2))
        jaw.addLine(to: CGPoint(x: center.x + 2, y: center.y + 8))
        jaw.addLine(to: CGPoint(x: center.x + 8, y: center.y + 2))
        context.fill(jaw, with: .color(AscendTheme.textPrimary))
    }
    
    private func drawMuscularTorsoSide(
        context: GraphicsContext,
        shoulder: CGPoint,
        hip: CGPoint,
        pecSwell: CGFloat,
        isLyingDown: Bool
    ) {
        var torso = Path()
        let pecThickness: CGFloat = 16 + (pecSwell * 6)
        
        if isLyingDown {
            // Lying flat with chest facing upward
            torso.move(to: CGPoint(x: shoulder.x - 10, y: shoulder.y + 10))
            torso.addCurve(
                to: CGPoint(x: hip.x, y: hip.y + 8),
                control1: CGPoint(x: shoulder.x + 8, y: shoulder.y - pecThickness),
                control2: CGPoint(x: hip.x - 8, y: hip.y - 2)
            )
            torso.addLine(to: CGPoint(x: hip.x, y: hip.y + 12))
            torso.addLine(to: CGPoint(x: shoulder.x - 10, y: shoulder.y + 12))
            torso.closeSubpath()
        } else {
            // Standing or inclined V-taper torso
            torso.move(to: CGPoint(x: shoulder.x - 8, y: shoulder.y))
            torso.addCurve(
                to: CGPoint(x: hip.x, y: hip.y),
                control1: CGPoint(x: shoulder.x + pecThickness, y: (shoulder.y + hip.y) / 2),
                control2: CGPoint(x: hip.x + 4, y: hip.y - 4)
            )
            torso.addLine(to: CGPoint(x: hip.x - 10, y: hip.y))
            torso.addLine(to: CGPoint(x: shoulder.x - 10, y: shoulder.y))
            torso.closeSubpath()
        }
        
        let torsoColor = pecSwell > 0.6 ? AscendTheme.emerald.opacity(0.85) : Color(white: 0.88)
        context.fill(torso, with: .color(torsoColor))
        context.stroke(torso, with: .color(.white), lineWidth: 1.5)
    }
    
    private func drawMuscularTorsoFront(
        context: GraphicsContext,
        shoulder: CGPoint,
        hip: CGPoint,
        deltoidFlex: CGFloat
    ) {
        var torso = Path()
        torso.move(to: CGPoint(x: shoulder.x - 18, y: shoulder.y))
        torso.addLine(to: CGPoint(x: shoulder.x + 18, y: shoulder.y))
        torso.addCurve(
            to: CGPoint(x: hip.x + 10, y: hip.y),
            control1: CGPoint(x: shoulder.x + 22, y: shoulder.y + 16),
            control2: CGPoint(x: hip.x + 12, y: hip.y - 6)
        )
        torso.addLine(to: CGPoint(x: hip.x - 10, y: hip.y))
        torso.addCurve(
            to: CGPoint(x: shoulder.x - 18, y: shoulder.y),
            control1: CGPoint(x: hip.x - 12, y: hip.y - 6),
            control2: CGPoint(x: shoulder.x - 22, y: shoulder.y + 16)
        )
        torso.closeSubpath()
        
        let color = deltoidFlex > 0.6 ? AscendTheme.emerald.opacity(0.85) : Color(white: 0.88)
        context.fill(torso, with: .color(color))
        context.stroke(torso, with: .color(.white), lineWidth: 1.5)
    }
    
    private func drawMuscularArm(
        context: GraphicsContext,
        shoulder: CGPoint,
        elbow: CGPoint,
        hand: CGPoint,
        isFlexed: Bool,
        isForeground: Bool
    ) {
        let baseColor: Color = isForeground ? (isFlexed ? AscendTheme.emerald : Color.white) : Color(white: 0.45)
        let armThickness: CGFloat = isFlexed ? 7.5 : 6.0
        
        // Upper Arm (Bicep / Tricep)
        var upperArm = Path()
        upperArm.move(to: shoulder)
        upperArm.addLine(to: elbow)
        context.stroke(upperArm, with: .color(baseColor), style: StrokeStyle(lineWidth: armThickness, lineCap: .round))
        
        // Forearm
        var forearm = Path()
        forearm.move(to: elbow)
        forearm.addLine(to: hand)
        context.stroke(forearm, with: .color(baseColor), style: StrokeStyle(lineWidth: armThickness - 1.0, lineCap: .round))
        
        // Joint Caps
        context.fill(Path(ellipseIn: CGRect(x: shoulder.x - 4, y: shoulder.y - 4, width: 8, height: 8)), with: .color(AscendTheme.cyan))
        context.fill(Path(ellipseIn: CGRect(x: elbow.x - 3, y: elbow.y - 3, width: 6, height: 6)), with: .color(AscendTheme.cyan))
    }
    
    private func drawMuscularLeg(
        context: GraphicsContext,
        hip: CGPoint,
        knee: CGPoint,
        ankle: CGPoint,
        isForeground: Bool
    ) {
        let legColor: Color = isForeground ? Color(white: 0.85) : Color(white: 0.45)
        
        // Thigh (Quadriceps / Hamstring curve)
        var thigh = Path()
        thigh.move(to: hip)
        thigh.addLine(to: knee)
        context.stroke(thigh, with: .color(legColor), style: StrokeStyle(lineWidth: 9.0, lineCap: .round))
        
        // Calf & Shin
        var calf = Path()
        calf.move(to: knee)
        calf.addLine(to: ankle)
        context.stroke(calf, with: .color(legColor), style: StrokeStyle(lineWidth: 7.0, lineCap: .round))
        
        // Athletic lifting shoe / foot
        var foot = Path()
        foot.move(to: ankle)
        foot.addLine(to: CGPoint(x: ankle.x + 14, y: ankle.y))
        context.stroke(foot, with: .color(AscendTheme.cyan), style: StrokeStyle(lineWidth: 4.5, lineCap: .round))
    }
    
    private func drawOlympicBarbell(context: GraphicsContext, center: CGPoint, width: CGFloat, plateRadius: CGFloat = 16) {
        // Steel Olympic Bar with knurled silver finish
        var bar = Path()
        bar.move(to: CGPoint(x: center.x - (width / 2), y: center.y))
        bar.addLine(to: CGPoint(x: center.x + (width / 2), y: center.y))
        context.stroke(bar, with: .color(Color(white: 0.95)), lineWidth: 4)
        
        // Inner collar sleeves
        let leftCollarX = center.x - (width / 2) + 6
        let rightCollarX = center.x + (width / 2) - 12
        context.fill(Path(roundedRect: CGRect(x: leftCollarX, y: center.y - 4, width: 4, height: 8), cornerRadius: 1), with: .color(Color(white: 0.6)))
        context.fill(Path(roundedRect: CGRect(x: rightCollarX, y: center.y - 4, width: 4, height: 8), cornerRadius: 1), with: .color(Color(white: 0.6)))
        
        // Metallic Olympic Bumper Plates (20 KG)
        let leftPlate = CGRect(x: center.x - (width / 2) - 4, y: center.y - plateRadius, width: 8, height: plateRadius * 2)
        let rightPlate = CGRect(x: center.x + (width / 2) - 4, y: center.y - plateRadius, width: 8, height: plateRadius * 2)
        
        context.fill(Path(roundedRect: leftPlate, cornerRadius: 3), with: .color(AscendTheme.cyan))
        context.stroke(Path(roundedRect: leftPlate, cornerRadius: 3), with: .color(.white), lineWidth: 1.5)
        
        context.fill(Path(roundedRect: rightPlate, cornerRadius: 3), with: .color(AscendTheme.cyan))
        context.stroke(Path(roundedRect: rightPlate, cornerRadius: 3), with: .color(.white), lineWidth: 1.5)
    }
    
    private func drawGymFloor(context: GraphicsContext, midX: CGFloat, floorY: CGFloat) {
        var floor = Path()
        floor.move(to: CGPoint(x: midX - 85, y: floorY))
        floor.addLine(to: CGPoint(x: midX + 85, y: floorY))
        context.stroke(floor, with: .color(Color(white: 0.35)), lineWidth: 3)
    }
}

// Architectural Stage Grid
private struct GymStageGrid: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 20
            var grid = Path()
            var x: CGFloat = 0
            while x < size.width {
                grid.move(to: CGPoint(x: x, y: 0))
                grid.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            var y: CGFloat = 0
            while y < size.height {
                grid.move(to: CGPoint(x: 0, y: y))
                grid.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }
            context.stroke(grid, with: .color(Color.white), lineWidth: 0.5)
        }
    }
}
