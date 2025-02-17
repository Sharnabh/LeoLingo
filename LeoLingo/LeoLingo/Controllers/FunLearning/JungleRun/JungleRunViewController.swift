
import UIKit

class JungleRunViewController: UIViewController {
    
    @IBOutlet var backgroundImage1: UIImageView!
    @IBOutlet var backgroundImage2: UIImageView!
    @IBOutlet var lionImageView: UIImageView!
    @IBOutlet var coinLabel: UILabel!
    @IBOutlet var diamondLabel: UILabel!
    
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet var pauseMenu: UIView!
    
    
    var hearts: [UIImageView] = []
        var coins: [UIImageView] = []

        var coinValue: Int = 0
        var diamondValue: Int = 0
        var remainingHearts: Int = 5

        var wordCoinTimer: Timer?
        var wordCoin: UIImageView?
        var gameTimer: CADisplayLink?
        var isPaused: Bool = false
        var coinSpawnCount: Int = 0
        var gameData = JungleRun()

        override func viewDidLoad() {
            super.viewDidLoad()

            setupBackground()
            setupLion()
            setupLabels()
            setupHearts()
            setupTapGesture()

            startBackgroundAnimation()
            startGameLoop()

            pauseMenu.layer.borderWidth = 5
            pauseMenu.layer.cornerRadius = 21
            pauseMenu.layer.borderColor = UIColor(red: 36/255, green: 61/255, blue: 35/255, alpha: 1).cgColor
            pauseMenu.isHidden = true

            // Ensure the pause button is always in front
            view.bringSubviewToFront(pauseButton)
            view.bringSubviewToFront(pauseMenu)
        }

        // MARK: - Pause Button Action
        @IBAction func pauseButtonTapped(_ sender: UIButton) {
            isPaused = true
            gameTimer?.isPaused = true 
            wordCoinTimer?.invalidate()
            pauseMenu.isHidden = false
            stopBackgroundAnimation()
        }

        // MARK: - Resume Button Action
        @IBAction func resumeButtonTapped(_ sender: UIButton) {
            isPaused = false
            gameTimer?.isPaused = false
            startGameLoop()
            pauseMenu.isHidden = true
            startBackgroundAnimation()
        }

        // MARK: - Restart Button Action
        @IBAction func restartButtonTapped(_ sender: UIButton) {
            pauseMenu.isHidden = true // Hide the pause menu
            resetGameState()
            startGameLoop()
            startBackgroundAnimation()
        }

        // MARK: - Quit Button Action
        @IBAction func quitButtonTapped(_ sender: UIButton) {
            let homePageVC = JungleRunHomeViewController()

            homePageVC.updateScore(coin: gameData.coins, diamond: gameData.diamonds)
            
//             homePageVC.coinScore = gameData.coins
//             homePageVC.diamondScore = gameData.diamonds

//             let navigationController = UINavigationController(rootViewController: homePageVC)
             self.dismiss(animated: true)
          
        }

        // MARK: - Background Setup
        func setupBackground() {
           
            backgroundImage1 = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            backgroundImage1.image = UIImage(named: "JungleRunBackground1")
            backgroundImage1.contentMode = .scaleAspectFill
            view.addSubview(backgroundImage1)

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
            }, completion: nil)
        }

        func stopBackgroundAnimation() {
            // Stop the background animation by resetting the frames and removing animations
            backgroundImage1.layer.removeAllAnimations()
            backgroundImage2.layer.removeAllAnimations()
            backgroundImage1.frame.origin.x = 0
            backgroundImage2.frame.origin.x = self.view.bounds.width
        }

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
            coinLabel.text = "💰 0"
            coinLabel.textColor = .systemBrown
            view.addSubview(coinLabel)
            diamondLabel.text = "💎 0"
            diamondLabel.textColor = .systemBrown
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

        // MARK: - Game Logic
        func startGameLoop() {
            guard !isPaused else { return } // Prevent starting the game loop if paused

            gameTimer = CADisplayLink(target: self, selector: #selector(updateGame))
            gameTimer?.add(to: .main, forMode: .default)
            spawnCoins()
        }

        @objc func updateGame() {
            detectCollisions()
        }

        func generateRandomWord() -> String {
            let words = ["Cat", "Dog", "Lion", "Tree", "Car"]
            return words.randomElement() ?? "Word"
        }

        func spawnCoins() {
            wordCoinTimer?.invalidate() // Ensure no duplicate timers

            wordCoinTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
                if self.isPaused { timer.invalidate(); return } // Stop spawning when paused

                self.coinSpawnCount += 1
                let isWordCoin = self.coinSpawnCount % 2 == 0 // Spawn a word coin every 6th coin
                let coinImageName = isWordCoin ? "wordCoin" : "valueCoin"
                let coin = UIImageView(image: UIImage(named: coinImageName))

                if isWordCoin {
                    self.gameData.word = self.generateRandomWord()
                    // Optionally add a label inside the word coin
                }

                let randomY = self.view.bounds.height - CGFloat.random(in: 300...400)
                coin.frame = CGRect(x: self.view.bounds.width, y: randomY, width: 100, height: 100)
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
                        gameData.coins += 100
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
            UIView.animate(withDuration: 0.3, animations: {
               
                coin.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: { _ in
                self.gameData.isAccurate = Bool.random()
                if self.gameData.isAccurate {
                    
                    self.gameData.diamonds += 1
                    self.updateDiamondLabel()
                } else {
                    
                    self.loseHeart()
                }
                coin.removeFromSuperview()
                if let index = self.coins.firstIndex(of: coin) {
                    self.coins.remove(at: index)
                }
            })
        }

        func updateCoinLabel() {
            coinLabel.text = "🪙 \(gameData.coins)"
        }

        func updateDiamondLabel() {
            diamondLabel.text = "💎 \(gameData.diamonds)"
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
            gameTimer?.invalidate()
            wordCoinTimer?.invalidate()
            stopBackgroundAnimation()

            let alert = UIAlertController(title: "Game Over", message: "Your Score:\nCoins: \(gameData.coins)\nDiamonds: \(gameData.diamonds)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
                self.resetGameState()
                self.startGameLoop()
                self.startBackgroundAnimation()
            }))
            present(alert, animated: true, completion: nil)
        }

        // MARK: - Reset Game State
        func resetGameState() {
            gameData = JungleRun()
            for heart in hearts {
                heart.isHidden = false
            }
            updateCoinLabel()
            updateDiamondLabel()
            remainingHearts = 5
            coins.forEach { $0.removeFromSuperview() } // Clear existing coins
            coins.removeAll()
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
