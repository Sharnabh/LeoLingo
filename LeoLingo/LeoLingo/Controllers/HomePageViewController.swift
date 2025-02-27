//
//  HomePageViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 15/01/25.
//

import UIKit

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var levelImageView: UIImageView!
    
    @IBOutlet var remainingTimeView: UIView!
    @IBOutlet var timeLeft: UILabel!
    @IBOutlet var timeLeftBar: UIProgressView!
    
    @IBOutlet var practicesView: UIView!
    @IBOutlet var badgesView: UIView!
    @IBOutlet var levelProgress: UIProgressView!
    @IBOutlet var levelView: UIView!

    @IBOutlet weak var badgesEarnedCollectionView: UICollectionView!
    @IBOutlet weak var recentPracticesCollectionView: UICollectionView!
    
    var badgesLayout: UICollectionViewFlowLayout?
    var practicesLayout: UICollectionViewFlowLayout?
    var sortedWords: [Word]?
    
    var timer: Timer?
        var selectedDuration: TimeInterval = 1800 // Default 30 minutes
        var startTime: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLevelView()
        generateCollectionViewLayout()
        let words = DataController.shared.getAllLevels().flatMap { $0.words }
        let newWords = words.filter { $0.record != nil }
        sortedWords = Array(newWords.reversed().prefix(3))
        setupTimeView()
        updateLevelImage()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateLevelImage() {
        let levels = DataController.shared.getAllLevels()
        var currentLevel: Level? = nil
        
        // Find the first incomplete level
        for level in levels {
            let totalWords = level.words.count
            let completedWords = level.words.filter { $0.isPassed }.count
            
            if completedWords < totalWords {
                currentLevel = level
                break
            }
        }
        
        // Update level image and progress
        if let level = currentLevel {
            // Get AppLevel using the existing getLevel method
            if let appLevel = DataController.shared.getLevel(by: level.id) {
                levelImageView.image = UIImage(named: appLevel.levelImage)
            }
            
            let totalWords = level.words.count
            let completedWords = level.words.filter { $0.isPassed }.count
            let progress = Float(completedWords) / Float(totalWords)
            levelProgress.progress = progress
        } else {
            // All levels completed, show the final level image
            if let lastLevel = levels.last,
               let lastAppLevel = DataController.shared.getLevel(by: lastLevel.id) {
                levelImageView.image = UIImage(named: lastAppLevel.levelImage)
                levelProgress.progress = 1.0
            }
        }
    }

    func setupTimeView() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDurationPicker))
            remainingTimeView.addGestureRecognizer(tapGesture)
            remainingTimeView.isUserInteractionEnabled = true
            startTimer()
        }
        
        @objc func showDurationPicker() {
            let popoverVC = UIViewController()
            popoverVC.preferredContentSize = CGSize(width: 250, height: 180)
            
            let tableView = UITableView(frame: .zero, style: .plain)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DurationCell")
            
            popoverVC.view = tableView
            
            popoverVC.modalPresentationStyle = .popover
            if let presentationController = popoverVC.popoverPresentationController {
                presentationController.sourceView = remainingTimeView
                presentationController.sourceRect = remainingTimeView.bounds
                presentationController.permittedArrowDirections = .any
                presentationController.delegate = self
            }
            
            present(popoverVC, animated: true)
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 3
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath)
            let durations = ["30 minutes", "45 minutes", "60 minutes"]
            cell.textLabel?.text = durations[indexPath.row]
            cell.textLabel?.textColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0)
            cell.backgroundColor = .white
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let durations: [TimeInterval] = [1800, 2700, 3600] // 30, 45, 60 minutes in seconds
            selectedDuration = durations[indexPath.row]
            startTimer()
            dismiss(animated: true)
        }
        
        func startTimer() {
            timer?.invalidate()
            startTime = Date()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateTimeDisplay()
            }
        }
        
    func updateTimeDisplay() {
            guard let startTime = startTime else { return }
            let elapsedTime = Date().timeIntervalSince(startTime)
            let remainingTime = max(selectedDuration - elapsedTime, 0)
            
            let minutes = Int(ceil(remainingTime / 60)) // Rounding up to nearest minute
            
            timeLeft.text = "\(minutes) min"
            timeLeftBar.progress = Float(1 - (elapsedTime / selectedDuration))
            
            if remainingTime <= 0 {
                timer?.invalidate()
            }
        }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesEarnedCollectionView {
            return DataController.shared.countEarnedBadges()
        }
        return sortedWords?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesEarnedCollectionView {
            let cell = badgesEarnedCollectionView.dequeueReusableCell(withReuseIdentifier: BadgesEarnedCollectionViewCell.identifier, for: indexPath) as! BadgesEarnedCollectionViewCell
            
            cell.configure(with: DataController.shared.getEarnedBadges()[indexPath.row].badgeImage)
            
            return cell
        }
        let cell = recentPracticesCollectionView.dequeueReusableCell(withReuseIdentifier: WordReportCollectionViewCell.identifier, for: indexPath) as! WordReportCollectionViewCell
        
        guard let word = sortedWords else { return cell }
        cell.updateLabel(with: word[indexPath.item])
        cell.accuracyLabel.isHidden = true
        cell.attemptsLabel.isHidden = true
        cell.accuracy.isHidden = true
        cell.attempts.isHidden = true
        
        return cell
    }
    
    func generateCollectionViewLayout() {
        badgesLayout = UICollectionViewFlowLayout()
        if let layout = badgesLayout {
            layout.itemSize = CGSize(width: 90, height: 90)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            badgesEarnedCollectionView.collectionViewLayout = layout
            badgesEarnedCollectionView.delegate = self
            badgesEarnedCollectionView.dataSource = self
            badgesEarnedCollectionView.layer.cornerRadius = 21
            
            let nib = UINib(nibName: "BadgesEarnedCollectionViewCell", bundle: nil)
            badgesEarnedCollectionView.register(nib, forCellWithReuseIdentifier: BadgesEarnedCollectionViewCell.identifier)
        }
        
        practicesLayout = UICollectionViewFlowLayout()
        if let layout = practicesLayout {
            layout.itemSize = CGSize(width: 126, height: 126)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0
            
            recentPracticesCollectionView.collectionViewLayout = layout
            recentPracticesCollectionView.delegate = self
            recentPracticesCollectionView.dataSource = self
            recentPracticesCollectionView.layer.cornerRadius = 21
            
            let nib = UINib(nibName: "WordReportCollectionViewCell", bundle: nil)
            recentPracticesCollectionView.register(nib, forCellWithReuseIdentifier: WordReportCollectionViewCell.identifier)
        }
    }
    
  
    func updateLevelView() {
        // Corner radius and border
          
        levelView.layer.cornerRadius = 21
        levelView.layer.borderWidth = 3
        levelView.layer.borderColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0).cgColor
        levelView.clipsToBounds = false

        // Drop shadow
        levelView.layer.shadowColor = UIColor.black.cgColor
        levelView.layer.shadowOpacity = 0.6
        levelView.layer.shadowOffset = CGSize(width: 0, height: 10)  //
        levelView.layer.shadowRadius = 20


        // Level progress
        levelProgress.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)

        // remaining time
        remainingTimeView.layer.cornerRadius = 25
        remainingTimeView.layer.borderWidth = 3
        remainingTimeView.layer.borderColor = UIColor(red: 222/255, green: 168/255, blue: 62/255, alpha: 1.0).cgColor
        timeLeftBar.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)

        // badges
        badgesView.layer.cornerRadius = 21
        badgesView.layer.borderWidth = 3
        badgesView.layer.borderColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0).cgColor
        badgesView.clipsToBounds = false

        badgesView.layer.shadowColor = UIColor.black.cgColor
        badgesView.layer.shadowOpacity = 0.4
        badgesView.layer.shadowOffset = CGSize(width: 0, height: 1)
        badgesView.layer.shadowRadius = 5

        //recent practices
        practicesView.layer.cornerRadius = 21  // Rounded corners
        practicesView.layer.borderWidth = 3    // Border thickness
        practicesView.layer.borderColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0).cgColor
        practicesView.clipsToBounds = false  // Clips content to rounded corners

        practicesView.layer.shadowColor = UIColor.black.cgColor
        practicesView.layer.shadowOpacity = 0.4  // 62% opacity
        practicesView.layer.shadowOffset = CGSize(width: 0, height: 1)  // Offset of 16pt downward
        practicesView.layer.shadowRadius = 5  // Blur radius of 43pt

       
    }
     
    @IBAction func kidsModeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ParentMode", bundle: nil)
        if let parentHomeVC = storyboard.instantiateViewController(withIdentifier: "ParentModeLockScreen") as? LockScreenViewController {
            parentHomeVC.modalPresentationStyle = .fullScreen
            self.present(parentHomeVC, animated: true, completion: nil)
            
        }
    }
    @IBAction func vocalCoachButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        
        if SupabaseDataController.shared.isFirstTime {
            // Show greeting for first-time users
            if let greetVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachGreeting") as? GreetViewController {
                greetVC.modalPresentationStyle = .fullScreen
                present(greetVC, animated: true)
                // Reset the first time status after showing greeting
                SupabaseDataController.shared.isFirstTime = false
            }
        } else {
            // Directly show VocalCoach for returning users
            if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
                vocalCoachVC.modalPresentationStyle = .fullScreen
                present(vocalCoachVC, animated: true, completion: nil)
            }
        }
    }
    @IBAction func funLearningButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "FunLearning", bundle: nil)
        if let funLearningVC = storyboard.instantiateViewController(withIdentifier: "FunLearningNavBar") as? UINavigationController {
            funLearningVC.modalPresentationStyle = .fullScreen
            present(funLearningVC, animated: true)
        }
    }
    
}
extension HomePageViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
