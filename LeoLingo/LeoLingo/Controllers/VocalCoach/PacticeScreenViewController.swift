import UIKit



let mojoData1: [Word] = [
    Word(wordTitle: "Rabbit", wordImage: "bunny"),
    Word(wordTitle: "Cat", wordImage: "cat"),
    Word(wordTitle: "Dog", wordImage: "dog"),
    Word(wordTitle: "Elephant", wordImage: "elephant"),
    Word(wordTitle: "Bee", wordImage: "bee"),
    Word(wordTitle: "Owl", wordImage: "owl")
]

let mojoData2: [Word] = [
    Word(wordTitle: "Rabbit", wordImage: "bunny"),
    Word(wordTitle: "Cat", wordImage: "cat"),
    Word(wordTitle: "Dog", wordImage: "dog"),
    Word(wordTitle: "Elephant", wordImage: "elephant"),
    Word(wordTitle: "Bee", wordImage: "bee"),
    Word(wordTitle: "Owl", wordImage: "owl")
]

let mojoData3: [Word] = [
    Word(wordTitle: "Rabbit", wordImage: "bunny"),
    Word(wordTitle: "Cat", wordImage: "cat"),
    Word(wordTitle: "Dog", wordImage: "dog"),
    Word(wordTitle: "Elephant", wordImage: "elephant"),
    Word(wordTitle: "Bee", wordImage: "bee"),
    Word(wordTitle: "Owl", wordImage: "owl")
]

let mojoData4: [Word] = [
    Word(wordTitle: "Rabbit", wordImage: "bunny"),
    Word(wordTitle: "Cat", wordImage: "cat"),
    Word(wordTitle: "Dog", wordImage: "dog"),
    Word(wordTitle: "Elephant", wordImage: "elephant"),
    Word(wordTitle: "Bee", wordImage: "bee"),
    Word(wordTitle: "Owl", wordImage: "owl")
]

let mojoData5: [Word] = [
    Word(wordTitle: "Rabbit", wordImage: "bunny"),
    Word(wordTitle: "Cat", wordImage: "cat"),
    Word(wordTitle: "Dog", wordImage: "dog"),
    Word(wordTitle: "Elephant", wordImage: "elephant"),
    Word(wordTitle: "Bee", wordImage: "bee"),
    Word(wordTitle: "Owl", wordImage: "owl")
]

let Data: [[Word]] = [mojoData1, mojoData2, mojoData3, mojoData4, mojoData5]

func getDirection(for index: Int, at levelIndex: Int) -> String {
    let data = Data[levelIndex][index]
    return "This is \(data.wordTitle). Say \(data.wordTitle)."
}
var levelIndex = 0
var currentIndex = 0
var mojoImageData = ["mojo2", "mojoHearing"]

class PracticeScreenViewController: UIViewController {
    
    
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var mojoImage: UIImageView!
    @IBOutlet var wordImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        let currentData = Data[0][currentIndex]
        directionLabel.text = ""
        wordImage.image = UIImage(named: currentData.wordImage!)
        mojoImage.image = UIImage(named: "mojo2") // Update as needed
        
        
        let direction = getDirection(for: currentIndex, at: levelIndex)
        animateWordImage()
        typeEffect(text: direction, label: directionLabel)
    }
    
    func animateWordImage() {
        // Anvil effect animation
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
        // Move to the next word
        currentIndex += 1
        
        // Check if the end of the current level is reached
        if currentIndex >= Data[levelIndex].count {
            // Move to the next level
            currentIndex = 0
            levelIndex = (levelIndex + 1) % Data.count
            
            
            if levelIndex >= Data.count {
                levelIndex = 0 // Restart levels if all are completed
            }
            showLevelChangePopover()
            showConfettiEffect()
            
            
        }else {
            updateUI()
        }
        
        func showLevelChangePopover() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
                popoverVC.modalPresentationStyle = .overFullScreen
                popoverVC.modalTransitionStyle = .crossDissolve
                popoverVC.message = "Congratulations!! You have completed this level. Would you like to proceed to the next level? "
                popoverVC.onProceed = { [weak self] in
                    self?.updateUI()
                }
                present(popoverVC, animated: true, completion: nil)
            }
        }
        
        // for confetti effect
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
            
            // Remove the confetti after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                confettiLayer.removeFromSuperlayer()
            }
        }
    }
}
