import UIKit

//var levelIndex = 0
//var currentIndex = 0
var mojoImageData = ["mojo2", "mojoHearing"]

class PracticeScreenViewController: UIViewController {
    
    var levels = DataController.shared.allLevels()
    
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var mojoImage: UIImageView!
    @IBOutlet var wordImage: UIImageView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var wrongButton: UIButton!
    
    var levelIndex = 0
    var currentIndex = 0
    var consecutiveWrongAttempts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        directionLabel.adjustsFontSizeToFitWidth = true
        
        
    }
    
    func getDirection(for index: Int, at levelIndex: Int) -> String {
        let data = levels[levelIndex].words[index]
        return "This is \(data.wordTitle). Say \(data.wordTitle)."
    }
    
    func updateUI() {
        let currentData = levels[levelIndex].words[currentIndex]
        directionLabel.text = ""
        wordImage.image = UIImage(named: currentData.wordImage!)
        mojoImage.image = UIImage(named: "mojo2")
        
        let direction = "This is \(currentData.wordTitle). Say \(currentData.wordTitle)."
        animateWordImage()
        typeEffect(text: direction, label: directionLabel)
        nextButton.layer.cornerRadius = 21
        
    }
    
    func animateWordImage() {
        wordImage.transform = CGAffineTransform(translationX: 0, y: -500)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.wordImage.transform = .identity
        }, completion: nil)
    }
    
    func typeEffect(text: String, label: UILabel) {
        label.text = ""
        var characterIndex = 0.0
        for letter in text {
            Timer.scheduledTimer(withTimeInterval: 0.05 * characterIndex, repeats: false) { _ in
                label.text?.append(letter)
            }
            characterIndex += 1
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        consecutiveWrongAttempts = 0
        generateAccuracy(between: 70, and: 100)
        if currentIndex == levels[levelIndex].words.count - 1 {
            showPopover(isCorrect: true, levelChange: true)
        } else {
            showPopover(isCorrect: true, levelChange: false)
        }
        
        moveToNextWord()
    }
    
    @IBAction func wrongButtonTapped(_ sender: UIButton) {
        consecutiveWrongAttempts += 1
        generateAccuracy(between: 0, and: 69)
        if consecutiveWrongAttempts == 3 {
            showFunLearningPopOver()
        } else {
            showPopover(isCorrect: false, levelChange: false)
            moveToNextWord()
        }
    }
    
    func generateAccuracy(between min: Double, and max: Double) {
        let maxAttempts = 5
        let attempts = Int.random(in: 1...maxAttempts)
        let accuracies = (0..<attempts).map { _ in Double.random(in: min...max) }
        
        if levels[levelIndex].words[currentIndex].record == nil {
            levels[levelIndex].words[currentIndex].record = Record(attempts: 0, accuracy: [], recording: [])
        }
        
        levels[levelIndex].words[currentIndex].isPracticed = true
        levels[levelIndex].words[currentIndex].record?.accuracy?.append(contentsOf: accuracies)
        levels[levelIndex].words[currentIndex].record?.attempts += attempts
    }

    
    func moveToNextWord() {
        currentIndex += 1
        
        if currentIndex >= levels[levelIndex].words.count {
            currentIndex = 0
            levelIndex = (levelIndex + 1) % levels.count
            
            DataController.shared.updateLevels(levels)
            showLevelChangePopover()
            showConfettiEffect()
        } else {
            DataController.shared.updateLevels(levels)
            updateUI()
        }
    }
    
    func showFunLearningPopOver() {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            popoverVC.modalPresentationStyle = .overFullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            popoverVC.configurePopover(message: "Lets Play Some Games!", image: "mojo2")
            popoverVC.onProceed = { [weak self] in
                self?.navigateToFunLearning()
            }
            present(popoverVC, animated: true, completion: nil)
        }
    }
    
    func showLevelChangePopover() {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            popoverVC.modalPresentationStyle = .overFullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            popoverVC.configurePopover(message: "Congratulations!! You have completed this level. Would you like to proceed to the next level? ", image: levels[levelIndex].levelImage)
            popoverVC.onProceed = { [weak self] in
                self?.updateUI()
            }
            present(popoverVC, animated: true, completion: nil)
        }
    }
    
    func showPopover(isCorrect: Bool, levelChange: Bool) {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            popoverVC.modalPresentationStyle = .overFullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            if isCorrect && !levelChange {
                popoverVC.configurePopover(message: "Great job!", image: "mojo2")
            } else if isCorrect && levelChange {
                showLevelChangePopover()
            }
            else {
                popoverVC.configurePopover(message: "Oops! Try again.", image: "SadMojo")
            }
            present(popoverVC, animated: true, completion: nil)
        }
    }
    
    func navigateToFunLearning() {
        let storyboard = UIStoryboard(name: "FunLearning", bundle: nil)
        if let funLearningVC = storyboard.instantiateViewController(withIdentifier: "FunLearningVC") as? FunLearningViewController {
            funLearningVC.modalPresentationStyle = .fullScreen
            present(funLearningVC, animated: true)
        }
    }
    
    func showConfettiEffect() {
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        let colors: [UIColor] = [.red, .green, .blue, .yellow, .purple, .orange]
        let shapes: [UIImage] = [UIImage(named: "confetti1")!, UIImage(named: "confetti2")!, UIImage(named: "confetti3")!]
        
        var cells: [CAEmitterCell] = []
        for color in colors {
            for shape in shapes {
                let cell = CAEmitterCell()
                cell.birthRate = 6
                cell.lifetime = 5.0
                cell.velocity = CGFloat.random(in: 150...200)
                cell.velocityRange = 50
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4
                cell.spin = 2
                cell.spinRange = 3
                cell.scale = 0.1
                cell.scaleRange = 0.2
                cell.contents = shape.cgImage
                cell.color = color.cgColor
                cells.append(cell)
            }
        }
        confettiLayer.emitterCells = cells
        view.layer.addSublayer(confettiLayer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            confettiLayer.removeFromSuperlayer()
        }
    }
}
