import Foundation
import SwiftUI

/// Inert stub for WorkoutAudioCoachService (Audio coach disabled)
@Observable
public final class WorkoutAudioCoachService: NSObject {
    public static let shared = WorkoutAudioCoachService()
    
    public var isSpeaking: Bool = false
    public var isMuted: Bool = true
    public var currentSpokenText: String = ""
    public var audioWaveLevel: CGFloat = 0.0
    public var activeVoiceName: String = "Disabled"
    
    override private init() {
        super.init()
    }
    
    public func speak(text: String, rate: Float = 0.51, pitch: Float = 1.01) {
        // Audio explanation feature disabled
    }
    
    public func speakExerciseOverview(
        name: String,
        muscleGroup: String,
        setup: String,
        execution: String
    ) {
        // Audio explanation feature disabled
    }
    
    public func speakFormCues(name: String, cues: [String]) {
        // Audio explanation feature disabled
    }
    
    public func stopSpeaking() {
        isSpeaking = false
        currentSpokenText = ""
        audioWaveLevel = 0.0
    }
    
    public func toggleMute() {
        isMuted.toggle()
    }
}
