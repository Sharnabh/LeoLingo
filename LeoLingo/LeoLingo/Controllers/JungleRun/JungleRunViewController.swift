import UIKit

class JungleRunViewController: UIViewController {
    @IBOutlet var backgroundImage1: UIImageView!
    @IBOutlet var backgroundImage2: UIImageView!
    @IBOutlet var lionImageView: UIImageView!
    @IBOutlet var coinLabel: UILabel!
    @IBOutlet var diamondLabel: UILabel!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet var controlsView: UIView!
    
    
    var hearts: [UIImageView] = []
    var coins: [UIImageView] = []
    
    var coinValue: Int = 0
    var diamondValue: Int = 0
    var remainingHearts: Int = 5
    
    var wordCoinTimer: Timer?
    var wordCoin: UIImageView?
    var gameTimer: CADisplayLink?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupLion()
        setupLabels()
        setupHearts()
        setupTapGesture()
        startBackgroundAnimation()
        startGameLoop()
        controlsView.layer.borderWidth = 5
        controlsView.layer.cornerRadius = 21
        controlsView.layer.borderColor  = UIColor(red: 36/255, green: 61/255, blue: 35/255, alpha: 1).cgColor
        
    }
    
    // MARK: - Background Setup
    func setupBackground() {
        // Set up the first background image
        backgroundImage1 = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        backgroundImage1.image = UIImage(named: "JungleRunBackground1")
        backgroundImage1.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage1)
        
        // Set up the second background image, positioned to the right of the first
        backgroundImage2 = UIImageView(frame: CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
        backgroundImage2.image = UIImage(named: "JungleRunBackground2")
        backgroundImage2.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage2)
    }


    func startBackgroundAnimation() {
           // Animate the background for infinite scrolling
           let animationDuration: TimeInterval = 10.0
           UIView.animate(withDuration: animationDuration, delay: 0, options: [.repeat, .curveLinear], animations: {
               self.backgroundImage1.frame.origin.x -= self.view.bounds.width
               self.backgroundImage2.frame.origin.x -= self.view.bounds.width
           }, completion: { _ in
               // Reset positions for infinite scrolling
               self.backgroundImage1.frame.origin.x = 0
               self.backgroundImage2.frame.origin.x = self.view.bounds.width
           })
       }
//    func startBackgroundAnimation() {
//        let screenWidth = view.bounds.width
//        let animationDuration: TimeInterval = 10 // Adjust for desired speed
//        
//        // Animate both background images
//        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear, .repeat], animations: {
//            self.backgroundImage1.frame.origin.x -= screenWidth
//            self.backgroundImage2.frame.origin.x -= screenWidth
//        }, completion: nil)
//        
//        // Use a timer to reset positions when images move out of view
//        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
//            if self.backgroundImage1.frame.maxX <= 0 {
//                self.backgroundImage1.frame.origin.x = self.backgroundImage2.frame.maxX
//            }
//            if self.backgroundImage2.frame.maxX <= 0 {
//                self.backgroundImage2.frame.origin.x = self.backgroundImage1.frame.maxX
//            }
//        }
//    }
//    
    // MARK: - Lion Setup
    func setupLion() {
            let lionSize = CGSize(width: 150, height: 150) // Updated lion size
            lionImageView = UIImageView(frame: CGRect(x: 100, y: view.bounds.height - 250, width: lionSize.width, height: lionSize.height))
            lionImageView.image = UIImage(named: "JungleLion")
            lionImageView.contentMode = .scaleAspectFit
            view.addSubview(lionImageView)
        }
    
    // MARK: - UI Setup
    func setupLabels() {
        coinLabel.text = "🪙 0"
        coinLabel.textColor = .white
        
        diamondLabel.text = "💎 0"
        diamondLabel.textColor = .white
    }
    
    func setupHearts() {
        for i in 0..<5 {
            let heart = UIImageView(frame: CGRect(x: 20 + (i * 30), y: 90, width: 25, height: 25))
            heart.image = UIImage(named: "heart")
            view.addSubview(heart)
            hearts.append(heart)
        }
    }
    
    // MARK: - Game Logic
    func startGameLoop() {
            gameTimer = CADisplayLink(target: self, selector: #selector(updateGame))
            gameTimer?.add(to: .main, forMode: .default)
            spawnCoins()
        }
        
        @objc func updateGame() {
            detectCollisions()
        }
        
    func spawnCoins() {
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                let isWordCoin = Bool.random()
                let coinImageName = isWordCoin ? "wordCoin" : "valueCoin"
                let coin = UIImageView(image: UIImage(named: coinImageName))
                let randomY = self.view.bounds.height - CGFloat.random(in: 300...400) // Random height for variety
                coin.frame = CGRect(x: self.view.bounds.width, y: randomY, width: 100, height: 100) // Updated coin size
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
                if let coinFrame = coin.layer.presentation()?.frame,
                   let lionFrame = lionImageView.layer.presentation()?.frame,
                   lionFrame.intersects(coinFrame) {
                    if coin.image == UIImage(named: "valueCoin") {
                        coinValue += 100
                        updateCoinLabel()
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
    
    func updateCoinLabel() {
        
        coinLabel.text = "🪙 \(String(describing: coinValue))"
    }
    
    func updateDiamondLevel() {
        diamondLabel.text = "💎 \(String(describing: coinValue))"
    }
    
    func loseHeart() {
        if remainingHearts > 0 {
            remainingHearts -= 1
            hearts[remainingHearts].isHidden = true
        }
        if remainingHearts == 0 {
            gameOver()
        }
    }
    
    func gameOver() {
        print("Game Over")
        gameTimer?.invalidate()
        wordCoinTimer?.invalidate()
    }
    
    // MARK: - Gesture Handling
    func setupTapGesture() {
           // Add tap gesture to detect screen taps
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
           view.addGestureRecognizer(tapGesture)
       }
       
       @objc func handleTap() {
           // Animate the lion's jump
           let jumpHeight: CGFloat = 150
           let jumpDuration: TimeInterval = 0.5
           
           UIView.animate(withDuration: jumpDuration / 2, animations: {
               self.lionImageView.frame.origin.y -= jumpHeight
           }, completion: { _ in
               UIView.animate(withDuration: jumpDuration / 2, animations: {
                   self.lionImageView.frame.origin.y += jumpHeight
               })
           })
       }
   }
