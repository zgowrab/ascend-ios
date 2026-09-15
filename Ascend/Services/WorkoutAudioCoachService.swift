import Foundation
import AVFoundation
import SwiftUI

@Observable
public final class WorkoutAudioCoachService: NSObject, AVSpeechSynthesizerDelegate {
    public static let shared = WorkoutAudioCoachService()
    
    public var isSpeaking: Bool = false
    public var isMuted: Bool = false
    public var currentSpokenText: String = ""
    public var audioWaveLevel: CGFloat = 0.0
    
    private let synthesizer = AVSpeechSynthesizer()
    private var waveTimer: Timer?
    private var isSessionConfigured: Bool = false
    
    override private init() {
        super.init()
        synthesizer.delegate = self
    }
    
    private func ensureAudioSessionConfigured() {
        guard !isSessionConfigured else { return }
        isSessionConfigured = true
        
        #if !targetEnvironment(simulator)
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers]
            )
        } catch {
            print("WorkoutAudioCoachService: AVAudioSession error: \(error.localizedDescription)")
        }
        #else
        // In iOS Simulator, avoid IPCAUClient IPC connection failures to Mac host audio
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        #endif
    }
    
    public func speak(text: String, rate: Float = 0.48, pitch: Float = 1.0) {
        guard !isMuted else { return }
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }
        
        ensureAudioSessionConfigured()
        
        #if !targetEnvironment(simulator)
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        #endif
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        currentSpokenText = cleanText
        isSpeaking = true
        startWaveAnimation()
        
        let utterance = AVSpeechUtterance(string: cleanText)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.preUtteranceDelay = 0.05
        utterance.postUtteranceDelay = 0.1
        
        // Pick best English voice available
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        synthesizer.speak(utterance)
    }
    
    public func speakExerciseOverview(
        name: String,
        muscleGroup: String,
        setup: String,
        execution: String
    ) {
        let script = """
        \(name). Target muscle: \(muscleGroup).
        Setup: \(setup)
        Movement: \(execution)
        """
        speak(text: script)
    }
    
    public func speakFormCues(name: String, cues: [String]) {
        guard !cues.isEmpty else { return }
        let cuesScript = cues.prefix(3).enumerated().map { index, cue in
            "Cue \(index + 1): \(cue)."
        }.joined(separator: " ")
        
        speak(text: "\(name) technique cues. \(cuesScript)")
    }
    
    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        currentSpokenText = ""
        stopWaveAnimation()
        
        #if !targetEnvironment(simulator)
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        #endif
    }
    
    public func toggleMute() {
        isMuted.toggle()
        if isMuted {
            stopSpeaking()
        }
    }
    
    // MARK: - Speech Delegate
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentSpokenText = ""
            self.stopWaveAnimation()
            #if !targetEnvironment(simulator)
            try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
            #endif
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentSpokenText = ""
            self.stopWaveAnimation()
            #if !targetEnvironment(simulator)
            try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
            #endif
        }
    }
    
    // MARK: - Animated Wave Meter
    private func startWaveAnimation() {
        waveTimer?.invalidate()
        waveTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            guard let self = self, self.isSpeaking else { return }
            self.audioWaveLevel = CGFloat.random(in: 0.3...1.0)
        }
    }
    
    private func stopWaveAnimation() {
        waveTimer?.invalidate()
        waveTimer = nil
        audioWaveLevel = 0.0
    }
}
