//
//  SpeechProcessor.swift
//  LeoLingo
//
//  Created by Sharnabh on 24/02/25.
//

import AVFoundation
import Speech

class SpeechProcessor: ObservableObject {
    @Published var isRecording = false
    @Published var userSpokenText = ""
    @Published var hinglishText = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-IN"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus != .authorized {
                    print("Speech recognition permission denied.")
                }
            }
        }
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if !granted {
                    print("Microphone access denied.")
                }
            }
        }
    }
    
    func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else { return }
        
        isRecording = true
        userSpokenText = ""
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            DispatchQueue.main.async { [self] in
                if let result = result {
                    self.userSpokenText = result.bestTranscription.formattedString
                    self.hinglishText = hindiToHinglish(userSpokenText)!
                }
                if error != nil {
                    self.stopRecording()
                }
            }
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stopRecording() {
        isRecording = false
        
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        if audioEngine.inputNode.inputFormat(forBus: 0).sampleRate != 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func hindiToHinglish(_ hindiText: String) -> String? {
        let mutableString = NSMutableString(string: hindiText)  // Convert to NSMutableString
        let success = CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        
        // Remove diacritics (e.g., "mujhē" → "mujhe")
        let hinglish = success ? (mutableString as String).applyingTransform(.stripDiacritics, reverse: false) : nil
        
        return hinglish
    }
    
    func levenshteinDistance(_ a: String, _ b: String) -> Int {
        if a.isEmpty || b.isEmpty {
            return max(a.count, b.count)
        }
        
        let aChars = Array(a)
        let bChars = Array(b)
        let aCount = aChars.count
        let bCount = bChars.count
        
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: bCount + 1), count: aCount + 1)
        
        for i in 0...aCount {
            matrix[i][0] = i
        }
        
        for j in 0...bCount {
            matrix[0][j] = j
        }
        
        for i in 1...aCount {
            for j in 1...bCount {
                let cost = aChars[i - 1] == bChars[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }
        
        return matrix[aCount][bCount]
    }
    
}
