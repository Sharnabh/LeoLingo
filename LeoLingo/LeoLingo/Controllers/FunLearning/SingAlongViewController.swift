import UIKit
import AVFoundation
import Speech

class SingAlongViewController: UIViewController {
    
    // MARK: - Properties
    private var poems: [Poem] = [
        Poem(title: "Twinkle Twinkle", lyrics: "Twinkle, twinkle, little star\nHow I wonder what you are\nUp above the world so high\nLike a diamond in the sky", audioFile: "twinkle_twinkle"),
        Poem(title: "Incy Wincy Spider", lyrics: "Incy wincy spider\nClimbed up the water spout\nDown came the rain\nAnd washed the spider out", audioFile: "incy_wincy"),
        Poem(title: "Baa Baa Black Sheep", lyrics: "Baa, baa, black sheep\nHave you any wool?\nYes sir, yes sir\nThree bags full", audioFile: "baa_baa"),
        Poem(title: "Row Row Row", lyrics: "Row, row, row your boat\nGently down the stream\nMerrily, merrily, merrily, merrily\nLife is but a dream", audioFile: "row_row"),
        Poem(title: "Old MacDonald", lyrics: "Old MacDonald had a farm\nE-I-E-I-O\nAnd on that farm he had a cow\nE-I-E-I-O", audioFile: "old_macdonald"),
        Poem(title: "Humpty Dumpty", lyrics: "Humpty Dumpty sat on a wall\nHumpty Dumpty had a great fall\nAll the king's horses and all the king's men\nCouldn't put Humpty together again", audioFile: "humpty_dumpty")
    ]
    
    private var currentPoemIndex = 0
    private var isRecording = false
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - UI Elements
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "jungle_background")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var poemCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: view.bounds.width * 0.8, height: view.bounds.height * 0.6)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PoemCardCell.self, forCellWithReuseIdentifier: "PoemCardCell")
        return collectionView
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "mic.circle.fill")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 60)), for: .normal)
        button.tintColor = .systemGreen
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Score: 0%"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowRadius = 4
        label.layer.shadowOpacity = 0.5
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.circle.fill")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 60)), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestSpeechAuthorization()
        setupAudioSession()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(poemCollectionView)
        view.addSubview(recordButton)
        view.addSubview(scoreLabel)
        view.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            poemCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            poemCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            poemCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            poemCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 50),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                default:
                    self.recordButton.isEnabled = false
                }
            }
        }
    }
    
    // MARK: - Action Methods
    @objc private func recordButtonTapped() {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @objc private func playButtonTapped() {
        playCurrentPoem()
    }
    
    private func startRecording() {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                self.calculateScore(spokenText: spokenText)
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            recordButton.tintColor = .systemRed
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recordButton.tintColor = .systemGreen
    }
    
    private func playCurrentPoem() {
        guard let path = Bundle.main.path(forResource: poems[currentPoemIndex].audioFile, ofType: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    private func calculateScore(spokenText: String) {
        let poemLyrics = poems[currentPoemIndex].lyrics.lowercased()
        let spokenWords = Set(spokenText.lowercased().split(separator: " ").map(String.init))
        let poemWords = Set(poemLyrics.split(separator: " ").map(String.init))
        
        let matchingWords = spokenWords.intersection(poemWords)
        let score = Double(matchingWords.count) / Double(poemWords.count) * 100
        
        DispatchQueue.main.async {
            self.scoreLabel.text = "Score: \(Int(score))%"
            
            if score >= 80 {
                self.showSuccessAnimation()
            }
        }
    }
    
    private func showSuccessAnimation() {
        // Add confetti effect
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        let colors: [UIColor] = [.systemRed, .systemGreen, .systemBlue, .systemYellow, .systemPurple]
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.birthRate = 4
            cell.lifetime = 5
            cell.velocity = 150
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.scale = 0.05
            cell.scaleRange = 0.02
            cell.contents = UIImage(named: "confetti")?.cgImage
            cell.color = color.cgColor
            cells.append(cell)
        }
        
        confettiLayer.emitterCells = cells
        view.layer.addSublayer(confettiLayer)
        
        // Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettiLayer.removeFromSuperlayer()
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension SingAlongViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return poems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PoemCardCell", for: indexPath) as? PoemCardCell else {
            return UICollectionViewCell()
        }
        
        let poem = poems[indexPath.item]
        cell.configure(with: poem)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        currentPoemIndex = page
        scoreLabel.text = "Score: 0%"
    }
}

// MARK: - Poem Model
struct Poem {
    let title: String
    let lyrics: String
    let audioFile: String
}

// MARK: - PoemCardCell
class PoemCardCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let lyricsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 18)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.textAlignment = .center
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layer.cornerRadius = 20
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(lyricsTextView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            lyricsTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            lyricsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lyricsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            lyricsTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with poem: Poem) {
        titleLabel.text = poem.title
        lyricsTextView.text = poem.lyrics
    }
} 