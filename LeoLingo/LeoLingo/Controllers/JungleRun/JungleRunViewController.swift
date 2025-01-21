import UIKit

class JungleRunViewController: UIViewController {
    
    var backgroundImage1: UIImageView!
    var backgroundImage2: UIImageView!
    var lionImageView: UIImageView!
    @IBOutlet var coinLabel: UILabel!
    @IBOutlet var diamondLabel: UILabel!
    
   
    var hearts: [UIImageView] = []
    var coins: [UIImageView] = []
    
    var coinLevel: Int = 0
    var diamondLevel: Int = 0
    var remainingHearts: Int = 5
    
    var wordCoinTimer: Timer?
    var wordCoin: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupLion()
        setupLabels()
        setupHearts()
        startBackgroundAnimation()
        setupTapGesture()
        spawnCoins()
    }
    
    func setupBackground() {
        // Set up the first background image
        backgroundImage1 = UIImageView(frame: view.bounds)
        backgroundImage1.image = UIImage(named: "JungleBackground1")
        view.addSubview(backgroundImage1)
        
        // Set up the second background image, positioned to the right of the first
        backgroundImage2 = UIImageView(frame: view.bounds)
        backgroundImage2.image = UIImage(named: "JungleBackground2")
        backgroundImage2.frame.origin.x = view.bounds.width
        view.addSubview(backgroundImage2)
        
        // Start the infinite scrolling animation
        startBackgroundAnimation()
    }

    func startBackgroundAnimation() {
        let screenWidth = view.bounds.width
        let animationDuration: TimeInterval = 5.0 // Adjust for desired scrolling speed
        
        // Animate the backgrounds
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear, .repeat], animations: {
            // Move both backgrounds to the left
            self.backgroundImage1.frame.origin.x -= screenWidth
            self.backgroundImage2.frame.origin.x -= screenWidth
        }, completion: nil)
        
        // Schedule a timer to reposition the images when they move out of view
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
            if self.backgroundImage1.frame.origin.x + screenWidth <= 0 {
                self.backgroundImage1.frame.origin.x = self.backgroundImage2.frame.maxX
            }
            if self.backgroundImage2.frame.origin.x + screenWidth <= 0 {
                self.backgroundImage2.frame.origin.x = self.backgroundImage1.frame.maxX
            }
        }
    }

    
    func setupLion() {
        let lionSize = CGSize(width: 100, height: 100)
        lionImageView = UIImageView(frame: CGRect(x: 100, y: view.bounds.height - 200, width: lionSize.width, height: lionSize.height))
        lionImageView.image = UIImage(named: "JungleLion")
        view.addSubview(lionImageView)
    }
    
    func setupLabels() {
        coinLabel = UILabel(frame: CGRect(x: 20, y: 50, width: 150, height: 30))
        coinLabel.text = "🪙 0"
        coinLabel.textColor = .white
        view.addSubview(coinLabel)
        
        diamondLabel = UILabel(frame: CGRect(x: 200, y: 50, width: 150, height: 30))
        diamondLabel.text = "💎 0"
        diamondLabel.textColor = .white
        view.addSubview(diamondLabel)
    }
    
    func setupHearts() {
        for i in 0..<5 {
            let heart = UIImageView(frame: CGRect(x: 20 + (i * 30), y: 90, width: 25, height: 25))
            heart.image = UIImage(named: "heart")
            view.addSubview(heart)
            hearts.append(heart)
        }
    }
    
    
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        if let wordCoin = wordCoin {
            // Handle word coin tap
            wordCoinTimer?.invalidate()
            wordCoin.removeFromSuperview()
            self.wordCoin = nil
            diamondLevel += 1
            updateDiamondLevel()
        }
    }
    
    func spawnCoins() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            let isWordCoin = Bool.random()
            let coinImageName = isWordCoin ? "wordCoin" : "valueCoin"
            let coin = UIImageView(image: UIImage(named: coinImageName))
            coin.frame = CGRect(x: self.view.bounds.width, y: self.view.bounds.height - 250, width: 50, height: 50)
            self.view.addSubview(coin)
            self.coins.append(coin)
            
            UIView.animate(withDuration: 5.0, delay: 0, options: .curveLinear, animations: {
                coin.frame.origin.x = -50
            }, completion: { _ in
                if let index = self.coins.firstIndex(of: coin) {
                    self.coins.remove(at: index)
                }
                coin.removeFromSuperview()
            })
        }
    }
    
    func detectCollisions() {
        for coin in coins {
            if lionImageView.frame.intersects(coin.frame) {
                if coin.image == UIImage(named: "valueCoin") {
                    coinLevel += 100
                    updateCoinLevel()
                } else if coin.image == UIImage(named: "wordCoin") {
                    handleWordCoin(coin)
                }
                coin.removeFromSuperview()
                if let index = coins.firstIndex(of: coin) {
                    coins.remove(at: index)
                }
            }
        }
    }
    
    func handleWordCoin(_ coin: UIImageView) {
        wordCoin = coin
        wordCoinTimer?.invalidate()
        wordCoinTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            self.wordCoin?.removeFromSuperview()
            self.wordCoin = nil
            self.loseHeart()
        }
    }
    
    func updateCoinLevel() {
        coinLabel.text = "🪙 \(coinLevel)"
    }
    
    func updateDiamondLevel() {
        diamondLabel.text = "💎 \(diamondLevel)"
    }
    
    func loseHeart() {
        if remainingHearts > 0 {
            remainingHearts -= 1
            hearts[remainingHearts].removeFromSuperview()
        }
        if remainingHearts == 0 {
            gameOver()
        }
    }
    
    func gameOver() {
        // Handle game over logic
        print("Game Over")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        detectCollisions()
    }
}
