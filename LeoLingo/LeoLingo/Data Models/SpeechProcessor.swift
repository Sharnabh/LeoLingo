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
    private var currentWord: String = ""
    private var currentWordId: UUID?
    private var currentAttemptNumber: Int = 0
    
    // Audio recording properties
    private var audioRecorder: AVAudioRecorder?
    private let supabaseController = SupabaseDataController.shared
    
    init() {
        // Create recordings directory if it doesn't exist
        createRecordingsDirectory()
    }
    
    private func createRecordingsDirectory() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let recordingsDirectory = documentDirectory.appendingPathComponent("Recordings", isDirectory: true)
        
        do {
            // Create directory if it doesn't exist
            if !fileManager.fileExists(atPath: recordingsDirectory.path) {
                try fileManager.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
            }
        } catch {
            print("Error creating recordings directory: \(error.localizedDescription)")
        }
    }
    
    private func getRecordingsDirectory() -> URL? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentDirectory.appendingPathComponent("Recordings", isDirectory: true)
    }
    
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
    
    func startRecording(word: String, wordId: UUID, attemptNumber: Int) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else { return }
        
        // Stop any existing recording first
        stopRecording()
        
        self.currentWord = word
        self.currentWordId = wordId
        self.currentAttemptNumber = attemptNumber
        isRecording = true
        userSpokenText = ""
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Set up recording path in temporary directory
            let tempDir = FileManager.default.temporaryDirectory
            let recordingName = "\(currentWordId?.uuidString ?? "")_\(Date().timeIntervalSince1970)_temp.m4a"
            let recordingURL = tempDir.appendingPathComponent(recordingName)
            recordingPath = recordingURL.path
            
            // Configure audio settings for high-quality speech recording
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]
            
            // Initialize audio recorder
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.record()
            
            // Set up speech recognition
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            let inputNode = audioEngine.inputNode
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
            
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        isRecording = false
        
        // Stop audio recorder
        audioRecorder?.stop()
        audioRecorder = nil
        
        // Stop audio engine
        audioEngine.stop()
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
    
    func getRecordingURL() -> URL? {
        guard let path = recordingPath else { return nil }
        return URL(fileURLWithPath: path)
    }
    
    func updateWordProgress(accuracy: Double) async throws {
        guard let wordId = currentWordId,
              let recordingPath = self.recordingPath else {
            return
        }
        
        // Update word progress in Supabase
        try await supabaseController.updateWordProgress(
            wordId: wordId,
            accuracy: accuracy,
            recordingPath: recordingPath
        )
    }
    
    func getAllRecordings(for wordId: UUID) async throws -> [String] {
        return try await supabaseController.getRecordings(for: wordId)
    }
    
    func deleteRecording(url: String, for wordId: UUID) async throws {
        try await supabaseController.deleteRecording(url: url, for: wordId)
    }
}
