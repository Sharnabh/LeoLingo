import AVFoundation

class VoiceManager: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = VoiceManager()
    private let synthesizer = AVSpeechSynthesizer()
    private var completionHandler: (() -> Void)?
    
    private override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ text: String, rate: Float = 0.35, completion: (() -> Void)? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        
        // Set female Siri voice
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_en-US_compact") {
            utterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            // Fallback to standard US voice
            utterance.voice = voice
        }
        
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        completionHandler = completion
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        completionHandler = nil
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if let completion = completionHandler {
            completion()
            completionHandler = nil
        }
    }
} 