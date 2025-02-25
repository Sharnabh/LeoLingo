//
//  SpeechProcessor.swift
//  LeoLingo
//
//  Created by Sharnabh on 24/02/25.
//

import AVFoundation
import Speech
import Combine

class SpeechProcessor: ObservableObject {
    @Published var isRecording = false
    @Published var userSpokenText = ""
    
    private let synthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recordingPath: String?
    
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
        
        // Stop any existing recording first
        stopRecording()
        
        isRecording = true
        userSpokenText = ""
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            let inputNode = audioEngine.inputNode
            
            // Make sure there's no existing tap
            inputNode.removeTap(onBus: 0)
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let result = result {
                        self.userSpokenText = result.bestTranscription.formattedString
                    }
                    if error != nil {
                        self.stopRecording()
                    }
                }
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            // Set up recording path
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let recordingName = "recording_\(Date().timeIntervalSince1970).m4a"
            let recordingURL = documentsPath.appendingPathComponent(recordingName)
            recordingPath = recordingURL.path
            
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        isRecording = false
        
        // Stop audio engine
        audioEngine.stop()
        
        // Remove tap if it exists
        if audioEngine.inputNode.inputFormat(forBus: 0).sampleRate != 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error deactivating audio session: \(error.localizedDescription)")
        }
        
        // Clear recording path
        recordingPath = nil
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
    
    func getRecordingPath() -> String? {
        return recordingPath
    }
}
