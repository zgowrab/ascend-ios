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
    public var activeVoiceName: String = "Coach Voice"
    
    private let synthesizer = AVSpeechSynthesizer()
    private var waveTimer: Timer?
    private var isSessionConfigured: Bool = false
    
    override private init() {
        super.init()
        synthesizer.delegate = self
        updateActiveVoiceName()
    }
    
    private func updateActiveVoiceName() {
        let voice = selectOptimalVoice()
        activeVoiceName = voice?.name ?? "Natural Coach"
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
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        #endif
    }
    
    /// Selects the highest quality neural or natural human voice available on the device
    private func selectOptimalVoice() -> AVSpeechSynthesisVoice? {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // 1. Premium Neural Voices (e.g. Ava Premium, Zoe Premium, Evan Premium)
        if let premium = allVoices.first(where: { $0.language.hasPrefix("en") && $0.quality == .premium }) {
            return premium
        }
        
        // 2. Enhanced Quality Voices (e.g. Siri Neural, Samantha Enhanced, Ava Enhanced)
        if let enhanced = allVoices.first(where: { $0.language.hasPrefix("en") && $0.quality == .enhanced }) {
            return enhanced
        }
        
        // 3. High-inflection British English voice (Daniel / Oliver) which provides superior natural prosody
        if let british = AVSpeechSynthesisVoice(language: "en-GB") {
            return british
        }
        
        // 4. Australian English voice (Karen / Lee)
        if let australian = AVSpeechSynthesisVoice(language: "en-AU") {
            return australian
        }
        
        // 5. Default US English
        return AVSpeechSynthesisVoice(language: "en-US")
    }
    
    public func speak(text: String, rate: Float = 0.51, pitch: Float = 1.01) {
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
        utterance.preUtteranceDelay = 0.08
        utterance.postUtteranceDelay = 0.15
        
        if let voice = selectOptimalVoice() {
            utterance.voice = voice
            activeVoiceName = voice.name
        }
        
        synthesizer.speak(utterance)
    }
    
    // MARK: - Conversational Athletic Coaching Scripts
    public func speakExerciseOverview(
        name: String,
        muscleGroup: String,
        setup: String,
        execution: String
    ) {
        let cleanSetup = setup
            .replacingOccurrences(of: "Step 1:", with: "")
            .replacingOccurrences(of: "Setup:", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let cleanExecution = execution
            .replacingOccurrences(of: "Step 2:", with: "")
            .replacingOccurrences(of: "Execution:", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let script = """
        Alright, let's lock in for the \(name)... Target muscle: \(muscleGroup).
        For your setup... \(cleanSetup).
        Now for the movement... \(cleanExecution)...
        Control the negative, breathe through the rep, and drive with power.
        """
        speak(text: script)
    }
    
    public func speakFormCues(name: String, cues: [String]) {
        guard !cues.isEmpty else { return }
        let formattedCues = cues.prefix(3).map { cue in
            cue.trimmingCharacters(in: .punctuationCharacters)
        }.joined(separator: "... Next cue: ")
        
        let script = "Key form cues for the \(name)... First, \(formattedCues)... Focus on that mind-muscle connection."
        speak(text: script)
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
        waveTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isSpeaking else { return }
            self.audioWaveLevel = CGFloat.random(in: 0.35...1.0)
        }
    }
    
    private func stopWaveAnimation() {
        waveTimer?.invalidate()
        waveTimer = nil
        audioWaveLevel = 0.0
    }
}
