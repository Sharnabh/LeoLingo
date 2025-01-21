import UIKit



//let mojoData1: [Word] = [
//    Word(wordName: "Rabbit", wordImage: "bunny"),
//    Word(wordName: "Cat", wordImage: "cat"),
//    Word(wordName: "Dog", wordImage: "dog"),
//    Word(wordName: "Elephant", wordImage: "elephant"),
//    Word(wordName: "Bee", wordImage: "bee"),
//    Word(wordName: "Owl", wordImage: "owl")
//]
//
//let mojoData2: [Word] = [
//    Word(wordName: "Rabbit", wordImage: "bunny"),
//    Word(wordName: "Cat", wordImage: "cat"),
//    Word(wordName: "Dog", wordImage: "dog"),
//    Word(wordName: "Elephant", wordImage: "elephant"),
//    Word(wordName: "Bee", wordImage: "bee"),
//    Word(wordName: "Owl", wordImage: "owl")
//]
//
//let mojoData3: [Word] = [
//    Word(wordName: "Rabbit", wordImage: "bunny"),
//    Word(wordName: "Cat", wordImage: "cat"),
//    Word(wordName: "Dog", wordImage: "dog"),
//    Word(wordName: "Elephant", wordImage: "elephant"),
//    Word(wordName: "Bee", wordImage: "bee"),
//    Word(wordName: "Owl", wordImage: "owl")
//]
//
//let mojoData4: [Word] = [
//    Word(wordName: "Rabbit", wordImage: "bunny"),
//    Word(wordName: "Cat", wordImage: "cat"),
//    Word(wordName: "Dog", wordImage: "dog"),
//    Word(wordName: "Elephant", wordImage: "elephant"),
//    Word(wordName: "Bee", wordImage: "bee"),
//    Word(wordName: "Owl", wordImage: "owl")
//]
//
//let mojoData5: [Word] = [
//    Word(wordName: "Rabbit", wordImage: "bunny"),
//    Word(wordName: "Cat", wordImage: "cat"),
//    Word(wordName: "Dog", wordImage: "dog"),
//    Word(wordName: "Elephant", wordImage: "elephant"),
//    Word(wordName: "Bee", wordImage: "bee"),
//    Word(wordName: "Owl", wordImage: "owl")
//]

//let Data: [[Word]] = [mojoData1, mojoData2, mojoData3, mojoData4, mojoData5]
//
//func getDirection(for index: Int, at levelIndex: Int) -> String {
//    let data = Data[levelIndex][index]
//    return "This is \(data.wordName). Say \(data.wordName)."
//}
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
        wordImage.image = UIImage(named: currentData.wordImage)
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
               }

               updateUI()
    }
}
