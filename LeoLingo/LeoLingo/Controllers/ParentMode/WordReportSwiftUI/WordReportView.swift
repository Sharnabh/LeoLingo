import SwiftUI
import AVFoundation

struct WordData: Identifiable {
    let id = UUID()
    let word: String
    let accuracy: Double
}

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    private var currentlyPlayingPath: String?
    
    override init() {
        super.init()
    }
    
    func play(recordingPath: String) {
        // If the same recording is playing, toggle pause/play
        if currentlyPlayingPath == recordingPath {
            if isPlaying {
                audioPlayer?.pause()
                isPlaying = false
            } else {
                audioPlayer?.play()
                isPlaying = true
            }
            return
        }
        
        // Stop current playback if different recording
        stop()
        
        // Start playing new recording
        do {
            let url = URL(fileURLWithPath: recordingPath)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            currentlyPlayingPath = recordingPath
        } catch {
            isPlaying = false
            currentlyPlayingPath = nil
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentlyPlayingPath = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentlyPlayingPath = nil
        }
    }
}

struct WordReportView: View {
    @State private var selectedWord: Word? = nil
    @State private var shouldReloadProgress: Bool = false
    @State private var isLoading = false
    @State private var rotation: Double = 0
    private let dataController = SupabaseDataController.shared
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    // Left section with filter and word cards
                    VStack {
                        FilterOptionsView(
                            selectedWord: $selectedWord,
                            shouldReloadProgress: $shouldReloadProgress,
                            isLoading: $isLoading
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 143/255, green: 91/255, blue: 66/255))
                    
                    Divider()
                        .frame(width: 1)
                        .background(Color(red: 143/255, green: 91/255, blue: 66/255))
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 4)
                    
                    // Right section with progress details
                    ProgressDetailSection(
                        selectedWord: selectedWord,
                        shouldReloadProgress: shouldReloadProgress
                    )
                }
            }
            
            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                Circle()
                    .trim(from: 0.2, to: 0.9)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .rotationEffect(Angle(degrees: rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
            }
        }
        .background(Color(UIColor.white))
        .task {
            // Load user data when view appears
            if let phoneNumber = dataController.phoneNumber {
                isLoading = true
                do {
                    _ = try await dataController.getUser(byPhone: phoneNumber)
                } catch {
                    print("Error loading user data: \(error)")
                }
                isLoading = false
            }
        }
    }
}

// MARK: - Subviews

private struct ProgressDetailSection: View {
    let selectedWord: Word?
    let shouldReloadProgress: Bool
    private let dataController = SupabaseDataController.shared
    
    private var averageAccuracy: Double {
        guard let word = selectedWord else { return 0 }
        return word.avgAccuracy
    }
    
    var body: some View {
        VStack {
            // Average accuracy header
            VStack(spacing: 8) {
                Text("\(String(format: "%.1f%", averageAccuracy))%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(red: 83/255, green: 183/255, blue: 53/255))
                Text("Average Accuracy")
                    .foregroundColor(Color(red: 83/255, green: 88/255, blue: 95/255))
            }
            .padding(.vertical, 32)
            
            Divider()
                .frame(height: 1)
            
                .background(Color(red: 143/255, green: 91/255, blue: 66/255))
                .shadow(color: .black.opacity(0.4), radius: 2, y: 2)
            
            // Attempts list
            ScrollView {
                VStack(spacing: 16) {
                    if let word = selectedWord,
                       let record = word.record,
                       let accuracies = record.accuracy,
                       !accuracies.isEmpty {
                        ForEach(Array(accuracies.enumerated()), id: \.offset) { index, accuracy in
                            let recordingPath = record.recording?[safe: index]
                            ProgressBarView(
                                attempt: index + 1,
                                progress: accuracy / 100,
                                isSelected: false,
                                recordingPath: recordingPath
                            )
                            .id("\(index)-\(shouldReloadProgress)")
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                            .animation(.easeInOut(duration: 0.3), value: index)
                        }
                    } else {
                        Text("No attempts recorded")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .padding()
            }
        }
       // .frame(height: 20)
        .frame(width: 564)
        .background(Color.white)
    }
}

// Extension to safely access array elements
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    WordReportView()
}
