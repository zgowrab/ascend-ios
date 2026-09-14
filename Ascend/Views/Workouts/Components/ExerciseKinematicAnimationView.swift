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
    var height: CGFloat = 220
    
    @State private var isPlaying: Bool = true
    @State private var animationTime: Double = 0.0
    
    private var pattern: MovementPattern {
        MovementPattern.detect(for: exerciseName, muscleGroup: muscleGroup)
    }
    
    public init(exerciseName: String, muscleGroup: MuscleGroup, height: CGFloat = 220) {
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.height = height
    }
    
    public var body: some View {
        TimelineView(.animation(paused: !isPlaying)) { timeline in
            let date = timeline.date.timeIntervalSinceReferenceDate
            // 4.0 second loop: 2.2s eccentric, 0.4s bottom pause, 1.4s concentric
            let cyclePeriod: Double = 4.0
            let phaseProgress = (date.truncatingRemainder(dividingBy: cyclePeriod)) / cyclePeriod
            
            // Calculate movement factor from 0.0 (top/start) to 1.0 (bottom/deepest)
            let depthFactor: CGFloat = {
                if phaseProgress < 0.55 {
                    // Eccentric descent
                    let p = phaseProgress / 0.55
                    return CGFloat(sin(p * .pi / 2))
                } else if phaseProgress < 0.65 {
                    // Isometric bottom stretch
                    return 1.0
                } else {
                    // Concentric ascent / drive
                    let p = (phaseProgress - 0.65) / 0.35
                    return CGFloat(cos(p * .pi / 2))
                }
            }()
            
            let phaseText: String = {
                if phaseProgress < 0.55 {
                    return "ECCENTRIC • 3s DESCENT"
                } else if phaseProgress < 0.65 {
                    return "STRETCH • 1s PAUSE"
                } else {
                    return "CONCENTRIC • 1s DRIVE"
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
                // Background dark blueprint stage
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AscendTheme.bgSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AscendTheme.cardBorder, lineWidth: 1)
                    )
                
                // Subtle blueprint grid
                GridBackground()
                    .opacity(0.12)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                
                // Animated Biomechanical Kinetic Canvas
                Canvas { context, size in
                    drawKinematics(
                        context: context,
                        size: size,
                        pattern: pattern,
                        depth: depthFactor
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
                    
                    // Bottom Movement Label & Tempo Meter
                    HStack {
                        Text(pattern.rawValue)
                            .font(.caption2.bold())
                            .foregroundStyle(AscendTheme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        Spacer()
                        
                        // Tempo Bar Progress
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
    
    // MARK: - Procedural Kinematic Rendering
    private func drawKinematics(
        context: GraphicsContext,
        size: CGSize,
        pattern: MovementPattern,
        depth: CGFloat
    ) {
        let midX = size.width / 2
        let midY = size.height / 2
        
        switch pattern {
        case .horizontalPress:
            drawBenchPress(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .verticalPress:
            drawOverheadPress(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .squat:
            drawSquat(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .hinge:
            drawDeadlift(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .verticalPull:
            drawPullUp(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .horizontalPull:
            drawBentOverRow(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .curl:
            drawBicepCurl(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .tricepExtension:
            drawTricepPushdown(context: context, size: size, midX: midX, midY: midY, depth: depth)
        case .coreFlexion:
            drawCoreHangingLegRaise(context: context, size: size, midX: midX, midY: midY, depth: depth)
        }
    }
    
    // MARK: - 1. Bench Press
    private func drawBenchPress(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        // Bench surface
        var bench = Path()
        bench.move(to: CGPoint(x: midX - 70, y: midY + 25))
        bench.addLine(to: CGPoint(x: midX + 60, y: midY + 25))
        context.stroke(bench, with: .color(AscendTheme.textMuted.opacity(0.6)), lineWidth: 6)
        
        // Bench legs
        var legs = Path()
        legs.move(to: CGPoint(x: midX - 50, y: midY + 25))
        legs.addLine(to: CGPoint(x: midX - 50, y: midY + 65))
        legs.move(to: CGPoint(x: midX + 40, y: midY + 25))
        legs.addLine(to: CGPoint(x: midX + 40, y: midY + 65))
        context.stroke(legs, with: .color(AscendTheme.textMuted.opacity(0.4)), lineWidth: 3)
        
        // Torso lying flat
        let headPos = CGPoint(x: midX - 55, y: midY + 14)
        let shoulderPos = CGPoint(x: midX - 25, y: midY + 16)
        let hipPos = CGPoint(x: midX + 25, y: midY + 16)
        
        // Head
        context.fill(Path(ellipseIn: CGRect(x: headPos.x - 9, y: headPos.y - 9, width: 18, height: 18)), with: .color(AscendTheme.textPrimary))
        
        // Torso
        var torso = Path()
        torso.move(to: headPos)
        torso.addLine(to: shoulderPos)
        torso.addLine(to: hipPos)
        context.stroke(torso, with: .color(AscendTheme.textPrimary), lineWidth: 5)
        
        // Legs to floor
        let kneePos = CGPoint(x: midX + 45, y: midY + 35)
        let footPos = CGPoint(x: midX + 45, y: midY + 65)
        var legPath = Path()
        legPath.move(to: hipPos)
        legPath.addLine(to: kneePos)
        legPath.addLine(to: footPos)
        context.stroke(legPath, with: .color(AscendTheme.textSecondary), lineWidth: 4)
        
        // Barbell position moving vertically
        // top: midY - 45, bottom: midY + 6
        let barY = (midY - 45) + (depth * 51)
        let barX = midX - 10
        
        // Arms: Shoulder -> Elbow -> Hand (at bar)
        let elbowY = (midY - 15) + (depth * 32)
        let elbowX = (midX - 35) + (depth * 6)
        let handPos = CGPoint(x: barX, y: barY)
        
        var arm = Path()
        arm.move(to: shoulderPos)
        arm.addLine(to: CGPoint(x: elbowX, y: elbowY))
        arm.addLine(to: handPos)
        context.stroke(arm, with: .color(AscendTheme.emerald), lineWidth: 4)
        
        // Joint markers
        context.fill(Path(ellipseIn: CGRect(x: elbowX - 4, y: elbowY - 4, width: 8, height: 8)), with: .color(AscendTheme.cyan))
        
        // Barbell
        var bar = Path()
        bar.move(to: CGPoint(x: barX - 45, y: barY))
        bar.addLine(to: CGPoint(x: barX + 45, y: barY))
        context.stroke(bar, with: .color(Color.white), lineWidth: 4)
        
        // Plates on sides
        context.fill(Path(roundedRect: CGRect(x: barX - 48, y: barY - 14, width: 6, height: 28), cornerRadius: 2), with: .color(AscendTheme.cyan))
        context.fill(Path(roundedRect: CGRect(x: barX + 42, y: barY - 14, width: 6, height: 28), cornerRadius: 2), with: .color(AscendTheme.cyan))
        
        // Vertical path line
        var pathLine = Path()
        pathLine.move(to: CGPoint(x: barX, y: midY - 45))
        pathLine.addLine(to: CGPoint(x: barX, y: midY + 6))
        context.stroke(pathLine, with: .color(AscendTheme.emerald.opacity(0.3)), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
    }
    
    // MARK: - 2. Overhead Press
    private func drawOverheadPress(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        // Ground
        var floor = Path()
        floor.move(to: CGPoint(x: midX - 60, y: midY + 70))
        floor.addLine(to: CGPoint(x: midX + 60, y: midY + 70))
        context.stroke(floor, with: .color(AscendTheme.textMuted.opacity(0.4)), lineWidth: 2)
        
        // Standing body
        let headPos = CGPoint(x: midX, y: midY - 25)
        let shoulderPos = CGPoint(x: midX, y: midY - 10)
        let hipPos = CGPoint(x: midX, y: midY + 25)
        
        context.fill(Path(ellipseIn: CGRect(x: headPos.x - 9, y: headPos.y - 9, width: 18, height: 18)), with: .color(AscendTheme.textPrimary))
        
        var spine = Path()
        spine.move(to: shoulderPos)
        spine.addLine(to: hipPos)
        context.stroke(spine, with: .color(AscendTheme.textPrimary), lineWidth: 5)
        
        // Legs
        var legs = Path()
        legs.move(to: hipPos)
        legs.addLine(to: CGPoint(x: midX - 16, y: midY + 70))
        legs.move(to: hipPos)
        legs.addLine(to: CGPoint(x: midX + 16, y: midY + 70))
        context.stroke(legs, with: .color(AscendTheme.textSecondary), lineWidth: 4)
        
        // Bar position: depth = 0 is overhead lockout (midY - 65), depth = 1 is at collarbone (midY - 10)
        let barY = (midY - 65) + (depth * 55)
        
        // Arms
        let elbowY = (midY - 35) + (depth * 40)
        let elbowXLeft = midX - 18 - (depth * 10)
        let elbowXRight = midX + 18 + (depth * 10)
        
        var leftArm = Path()
        leftArm.move(to: shoulderPos)
        leftArm.addLine(to: CGPoint(x: elbowXLeft, y: elbowY))
        leftArm.addLine(to: CGPoint(x: midX - 22, y: barY))
        context.stroke(leftArm, with: .color(AscendTheme.emerald), lineWidth: 3.5)
        
        var rightArm = Path()
        rightArm.move(to: shoulderPos)
        rightArm.addLine(to: CGPoint(x: elbowXRight, y: elbowY))
        rightArm.addLine(to: CGPoint(x: midX + 22, y: barY))
        context.stroke(rightArm, with: .color(AscendTheme.emerald), lineWidth: 3.5)
        
        // Barbell
        var bar = Path()
        bar.move(to: CGPoint(x: midX - 45, y: barY))
        bar.addLine(to: CGPoint(x: midX + 45, y: barY))
        context.stroke(bar, with: .color(.white), lineWidth: 4)
        
        context.fill(Path(roundedRect: CGRect(x: midX - 48, y: barY - 12, width: 6, height: 24), cornerRadius: 2), with: .color(AscendTheme.cyan))
        context.fill(Path(roundedRect: CGRect(x: midX + 42, y: barY - 12, width: 6, height: 24), cornerRadius: 2), with: .color(AscendTheme.cyan))
    }
    
    // MARK: - 3. Squat
    private func drawSquat(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        // Floor
        var floor = Path()
        floor.move(to: CGPoint(x: midX - 70, y: midY + 70))
        floor.addLine(to: CGPoint(x: midX + 70, y: midY + 70))
        context.stroke(floor, with: .color(AscendTheme.textMuted.opacity(0.4)), lineWidth: 2)
        
        // Depth-dependent coordinates
        // Standing: hip at midY + 15, knee at midY + 45, ankle at midY + 70
        // Squatting: hip at midY + 44, pushed back to midX - 30; knee pushed forward to midX + 15
        let hipX = midX - 5 - (depth * 25)
        let hipY = (midY + 12) + (depth * 34)
        
        let shoulderX = midX + 2 - (depth * 10)
        let shoulderY = (midY - 25) + (depth * 34)
        
        let kneeX = midX + 8 + (depth * 10)
        let kneeY = (midY + 45) + (depth * 4)
        
        let footX = midX + 5
        let footY = midY + 70
        
        // Head
        let headPos = CGPoint(x: shoulderX + 4, y: shoulderY - 16)
        context.fill(Path(ellipseIn: CGRect(x: headPos.x - 9, y: headPos.y - 9, width: 18, height: 18)), with: .color(AscendTheme.textPrimary))
        
        // Torso / Spine
        var torso = Path()
        torso.move(to: CGPoint(x: shoulderX, y: shoulderY))
        torso.addLine(to: CGPoint(x: hipX, y: hipY))
        context.stroke(torso, with: .color(AscendTheme.textPrimary), lineWidth: 5.5)
        
        // Thigh
        var thigh = Path()
        thigh.move(to: CGPoint(x: hipX, y: hipY))
        thigh.addLine(to: CGPoint(x: kneeX, y: kneeY))
        context.stroke(thigh, with: .color(AscendTheme.emerald), lineWidth: 5)
        
        // Shin
        var shin = Path()
        shin.move(to: CGPoint(x: kneeX, y: kneeY))
        shin.addLine(to: CGPoint(x: footX, y: footY))
        context.stroke(shin, with: .color(AscendTheme.textSecondary), lineWidth: 4.5)
        
        // Barbell across shoulders
        let barY = shoulderY - 2
        var bar = Path()
        bar.move(to: CGPoint(x: shoulderX - 40, y: barY))
        bar.addLine(to: CGPoint(x: shoulderX + 40, y: barY))
        context.stroke(bar, with: .color(.white), lineWidth: 4)
        
        context.fill(Path(roundedRect: CGRect(x: shoulderX - 44, y: barY - 16, width: 8, height: 32), cornerRadius: 3), with: .color(AscendTheme.cyan))
        context.fill(Path(roundedRect: CGRect(x: shoulderX + 36, y: barY - 16, width: 8, height: 32), cornerRadius: 3), with: .color(AscendTheme.cyan))
        
        // Joint pivots
        context.fill(Path(ellipseIn: CGRect(x: hipX - 4, y: hipY - 4, width: 8, height: 8)), with: .color(AscendTheme.cyan))
        context.fill(Path(ellipseIn: CGRect(x: kneeX - 4, y: kneeY - 4, width: 8, height: 8)), with: .color(AscendTheme.cyan))
    }
    
    // MARK: - 4. Deadlift
    private func drawDeadlift(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        var floor = Path()
        floor.move(to: CGPoint(x: midX - 70, y: midY + 70))
        floor.addLine(to: CGPoint(x: midX + 70, y: midY + 70))
        context.stroke(floor, with: .color(AscendTheme.textMuted.opacity(0.4)), lineWidth: 2)
        
        // Hinge motion: depth = 0 is standing tall, depth = 1 is bent at bottom
        let hipX = midX - 2 - (depth * 32)
        let hipY = (midY + 15) + (depth * 15)
        
        let shoulderX = midX + 5 + (depth * 5)
        let shoulderY = (midY - 25) + (depth * 45)
        
        let kneeX = midX + 4 + (depth * 6)
        let kneeY = midY + 44
        
        let footX = midX + 4
        let footY = midY + 70
        
        let barX = midX + 16
        let barY = (midY + 15) + (depth * 50)
        
        // Head
        let headPos = CGPoint(x: shoulderX + (depth * 8), y: shoulderY - 14)
        context.fill(Path(ellipseIn: CGRect(x: headPos.x - 9, y: headPos.y - 9, width: 18, height: 18)), with: .color(AscendTheme.textPrimary))
        
        // Flat Spine
        var spine = Path()
        spine.move(to: CGPoint(x: shoulderX, y: shoulderY))
        spine.addLine(to: CGPoint(x: hipX, y: hipY))
        context.stroke(spine, with: .color(AscendTheme.emerald), lineWidth: 5.5)
        
        // Legs
        var legPath = Path()
        legPath.move(to: CGPoint(x: hipX, y: hipY))
        legPath.addLine(to: CGPoint(x: kneeX, y: kneeY))
        legPath.addLine(to: CGPoint(x: footX, y: footY))
        context.stroke(legPath, with: .color(AscendTheme.textSecondary), lineWidth: 4.5)
        
        // Arms straight hanging to bar
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
        arm.addLine(to: CGPoint(x: barX, y: barY))
        context.stroke(arm, with: .color(.white), lineWidth: 3.5)
        
        // Barbell & big plates
        var bar = Path()
        bar.move(to: CGPoint(x: barX - 35, y: barY))
        bar.addLine(to: CGPoint(x: barX + 35, y: barY))
        context.stroke(bar, with: .color(.white), lineWidth: 4)
        
        context.fill(Path(ellipseIn: CGRect(x: barX - 42, y: barY - 18, width: 10, height: 36)), with: .color(AscendTheme.cyan))
        context.fill(Path(ellipseIn: CGRect(x: barX + 32, y: barY - 18, width: 10, height: 36)), with: .color(AscendTheme.cyan))
    }
    
    // MARK: - 5. Pull-Up
    private func drawPullUp(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        // Pull-Up Bar at top
        var bar = Path()
        bar.move(to: CGPoint(x: midX - 60, y: midY - 60))
        bar.addLine(to: CGPoint(x: midX + 60, y: midY - 60))
        context.stroke(bar, with: .color(.white), lineWidth: 5)
        
        // Body hangs and moves up: depth = 0 is at bottom (dead hang), depth = 1 is chin over bar
        // Note: in pull-up, concentric brings body UP towards bar
        let bodyYOffset = (1.0 - depth) * 45
        
        let headPos = CGPoint(x: midX, y: (midY - 45) + bodyYOffset)
        let shoulderPos = CGPoint(x: midX, y: (midY - 28) + bodyYOffset)
        let hipPos = CGPoint(x: midX, y: (midY + 15) + bodyYOffset)
        
        context.fill(Path(ellipseIn: CGRect(x: headPos.x - 9, y: headPos.y - 9, width: 18, height: 18)), with: .color(AscendTheme.textPrimary))
        
        var torso = Path()
        torso.move(to: shoulderPos)
        torso.addLine(to: hipPos)
        context.stroke(torso, with: .color(AscendTheme.textPrimary), lineWidth: 5)
        
        // Legs with slight knee bend
        var legs = Path()
        legs.move(to: hipPos)
        legs.addLine(to: CGPoint(x: midX - 4, y: (midY + 45) + bodyYOffset))
        legs.addLine(to: CGPoint(x: midX - 10, y: (midY + 68) + bodyYOffset))
        context.stroke(legs, with: .color(AscendTheme.textSecondary), lineWidth: 4)
        
        // Arms to bar
        let handLeft = CGPoint(x: midX - 35, y: midY - 60)
        let handRight = CGPoint(x: midX + 35, y: midY - 60)
        
        let elbowLeftY = shoulderPos.y + (depth * 5)
        let elbowRightY = shoulderPos.y + (depth * 5)
        let elbowLeftX = midX - 25 - (depth * 8)
        let elbowRightX = midX + 25 + (depth * 8)
        
        var armLeft = Path()
        armLeft.move(to: shoulderPos)
        armLeft.addLine(to: CGPoint(x: elbowLeftX, y: elbowLeftY))
        armLeft.addLine(to: handLeft)
        context.stroke(armLeft, with: .color(AscendTheme.emerald), lineWidth: 3.5)
        
        var armRight = Path()
        armRight.move(to: shoulderPos)
        armRight.addLine(to: CGPoint(x: elbowRightX, y: elbowRightY))
        armRight.addLine(to: handRight)
        context.stroke(armRight, with: .color(AscendTheme.emerald), lineWidth: 3.5)
    }
    
    // MARK: - 6. Bent-Over Row
    private func drawBentOverRow(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        var floor = Path()
        floor.move(to: CGPoint(x: midX - 60, y: midY + 70))
        floor.addLine(to: CGPoint(x: midX + 60, y: midY + 70))
        context.stroke(floor, with: .color(AscendTheme.textMuted.opacity(0.4)), lineWidth: 2)
        
        // Fixed 45-degree hinge torso
        let hip = CGPoint(x: midX - 25, y: midY + 15)
        let shoulder = CGPoint(x: midX + 15, y: midY - 15)
        let head = CGPoint(x: midX + 28, y: midY - 26)
        
        context.fill(Path(ellipseIn: CGRect(x: head.x - 9, y: head.y - 9, width: 18, height: 18)), with: .color(AscendTheme.textPrimary))
        
        var spine = Path()
        spine.move(to: shoulder)
        spine.addLine(to: hip)
        context.stroke(spine, with: .color(AscendTheme.textPrimary), lineWidth: 5)
        
        // Legs
        var legs = Path()
        legs.move(to: hip)
        legs.addLine(to: CGPoint(x: midX - 10, y: midY + 45))
        legs.addLine(to: CGPoint(x: midX - 5, y: midY + 70))
        context.stroke(legs, with: .color(AscendTheme.textSecondary), lineWidth: 4.5)
        
        // Row bar motion: depth = 0 is arms hanging (midY + 35), depth = 1 is bar pulled to ribs (midY - 2)
        let barX = midX + 5
        let barY = (midY + 35) - (depth * 37)
        
        let elbowX = (midX + 5) - (depth * 25)
        let elbowY = (midY + 10) - (depth * 20)
        
        var arm = Path()
        arm.move(to: shoulder)
        arm.addLine(to: CGPoint(x: elbowX, y: elbowY))
        arm.addLine(to: CGPoint(x: barX, y: barY))
        context.stroke(arm, with: .color(AscendTheme.emerald), lineWidth: 3.5)
        
        // Barbell
        var bar = Path()
        bar.move(to: CGPoint(x: barX - 35, y: barY))
        bar.addLine(to: CGPoint(x: barX + 35, y: barY))
        context.stroke(bar, with: .color(.white), lineWidth: 4)
        context.fill(Path(roundedRect: CGRect(x: barX - 38, y: barY - 12, width: 6, height: 24), cornerRadius: 2), with: .color(AscendTheme.cyan))
        context.fill(Path(roundedRect: CGRect(x: barX + 32, y: barY - 12, width: 6, height: 24), cornerRadius: 2), with: .color(AscendTheme.cyan))
    }
    
    // MARK: - 7. Bicep Curl
    private func drawBicepCurl(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        let headPos = CGPoint(x: midX, y: midY - 40)
        let shoulderPos = CGPoint(x: midX, y: midY - 20)
        let elbowPos = CGPoint(x: midX + 8, y: midY + 10)
        
        context.fill(Path(ellipseIn: CGRect(x: headPos.x - 9, y: headPos.y - 9, width: 18, height: 18)), with: .color(AscendTheme.textPrimary))
        
        var torso = Path()
        torso.move(to: shoulderPos)
        torso.addLine(to: CGPoint(x: midX, y: midY + 30))
        context.stroke(torso, with: .color(AscendTheme.textPrimary), lineWidth: 5)
        
        // Upper arm stays pinned
        var upperArm = Path()
        upperArm.move(to: shoulderPos)
        upperArm.addLine(to: elbowPos)
        context.stroke(upperArm, with: .color(AscendTheme.textSecondary), lineWidth: 4)
        
        // Forearm curls up: depth = 0 is hanging down, depth = 1 is curled to shoulder
        let angle: CGFloat = (.pi / 2) - (depth * 2.4)
        let forearmLength: CGFloat = 36
        let handX = elbowPos.x + (cos(angle) * forearmLength)
        let handY = elbowPos.y + (sin(angle) * forearmLength)
        
        var forearm = Path()
        forearm.move(to: elbowPos)
        forearm.addLine(to: CGPoint(x: handX, y: handY))
        context.stroke(forearm, with: .color(AscendTheme.emerald), lineWidth: 4)
        
        // Dumbbell
        context.fill(Path(roundedRect: CGRect(x: handX - 10, y: handY - 7, width: 20, height: 14), cornerRadius: 3), with: .color(AscendTheme.cyan))
    }
    
    // MARK: - 8. Tricep Pushdown
    private func drawTricepPushdown(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        // Cable top
        var cableTop = Path()
        cableTop.move(to: CGPoint(x: midX + 22, y: midY - 60))
        cableTop.addLine(to: CGPoint(x: midX + 22, y: midY - 10))
        context.stroke(cableTop, with: .color(AscendTheme.textMuted), lineWidth: 2)
        
        let headPos = CGPoint(x: midX - 15, y: midY - 35)
        let shoulderPos = CGPoint(x: midX - 8, y: midY - 15)
        let elbowPos = CGPoint(x: midX + 5, y: midY + 8)
        
        context.fill(Path(ellipseIn: CGRect(x: headPos.x - 9, y: headPos.y - 9, width: 18, height: 18)), with: .color(AscendTheme.textPrimary))
        
        var torso = Path()
        torso.move(to: shoulderPos)
        torso.addLine(to: CGPoint(x: midX - 18, y: midY + 35))
        context.stroke(torso, with: .color(AscendTheme.textPrimary), lineWidth: 5)
        
        var upperArm = Path()
        upperArm.move(to: shoulderPos)
        upperArm.addLine(to: elbowPos)
        context.stroke(upperArm, with: .color(AscendTheme.textSecondary), lineWidth: 4)
        
        // Pushdown: depth = 0 is bent 90 degrees, depth = 1 is locked out straight down
        let angle: CGFloat = (-0.2) + (depth * 1.7)
        let handX = elbowPos.x + (cos(angle) * 35)
        let handY = elbowPos.y + (sin(angle) * 35)
        
        var forearm = Path()
        forearm.move(to: elbowPos)
        forearm.addLine(to: CGPoint(x: handX, y: handY))
        context.stroke(forearm, with: .color(AscendTheme.emerald), lineWidth: 4)
        
        // Rope handle
        var handle = Path()
        handle.move(to: CGPoint(x: handX - 8, y: handY + 4))
        handle.addLine(to: CGPoint(x: handX + 8, y: handY - 4))
        context.stroke(handle, with: .color(AscendTheme.cyan), lineWidth: 4)
    }
    
    // MARK: - 9. Core Hanging Leg Raise
    private func drawCoreHangingLegRaise(context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, depth: CGFloat) {
        var bar = Path()
        bar.move(to: CGPoint(x: midX - 50, y: midY - 60))
        bar.addLine(to: CGPoint(x: midX + 50, y: midY - 60))
        context.stroke(bar, with: .color(.white), lineWidth: 4.5)
        
        let handPos = CGPoint(x: midX, y: midY - 60)
        let shoulderPos = CGPoint(x: midX, y: midY - 30)
        let hipPos = CGPoint(x: midX, y: midY + 15)
        
        context.fill(Path(ellipseIn: CGRect(x: midX - 8, y: midY - 48, width: 16, height: 16)), with: .color(AscendTheme.textPrimary))
        
        var arms = Path()
        arms.move(to: handPos)
        arms.addLine(to: shoulderPos)
        context.stroke(arms, with: .color(.white), lineWidth: 4)
        
        var torso = Path()
        torso.move(to: shoulderPos)
        torso.addLine(to: hipPos)
        context.stroke(torso, with: .color(AscendTheme.emerald), lineWidth: 5)
        
        // Legs hinge up: depth = 0 is straight down, depth = 1 is horizontal 90 degrees
        let legAngle: CGFloat = (.pi / 2) - (depth * (.pi / 2))
        let footX = hipPos.x + (cos(legAngle) * 55)
        let footY = hipPos.y + (sin(legAngle) * 55)
        
        var legs = Path()
        legs.move(to: hipPos)
        legs.addLine(to: CGPoint(x: footX, y: footY))
        context.stroke(legs, with: .color(AscendTheme.cyan), lineWidth: 4.5)
    }
}

// Subtle futuristic background grid
private struct GridBackground: View {
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
