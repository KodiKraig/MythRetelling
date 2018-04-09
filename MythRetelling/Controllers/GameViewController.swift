//
//  GameViewController.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/1/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit
import CoreData

class GameViewController: UIViewController {
    
    fileprivate var pauseView = UIView()
    fileprivate var manager = GameManager.sI
    fileprivate let managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: Constants
    
    fileprivate struct LocalConstants {
        static let CardReuseID = "CardCell"
        static let SegueToStoryID = "showStory"
        static let SelectBtnGameModeText = "Guess"
        static let SelectBtnStoryModeText = "View Story"
        static let HCardCount: CGFloat = UIDevice.current.isIPhone() ? 2 : 4
        static let HSpacing: CGFloat = 1
        static let VCardCount: CGFloat = 4
        static let VSpacing: CGFloat = 3
    }
    
    // MARK: Outlets
    
    @IBOutlet var cardCollectionView: UICollectionView!
    @IBOutlet var selectBtn: UIBarButtonItem!
    @IBOutlet var helpBtn: UIBarButtonItem!
    @IBOutlet var cardToolbar: UIToolbar!
    @IBOutlet var pauseBtn: UIBarButtonItem!
    
    // MARK: IBActions
    
    @IBAction func newGameBtnPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func selectBtnPressed(_ sender: UIBarButtonItem) {
        if selectBtn.title == LocalConstants.SelectBtnGameModeText {
            handleGuess()
        } else {
            self.performSegue(withIdentifier: LocalConstants.SegueToStoryID, sender: nil)
        }
    }
    
    @IBAction func pauseGameBtnPressed(_ sender: UIBarButtonItem) {
        if manager.timer.isPaused {
            startGame()
        } else {
            pauseGame()
        }
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimer), name: GameManager.TimerDidUpdateNotification.name, object: nil)
        cardCollectionView.backgroundColor = UIColor(patternImage: UIImage(named: "paper_bg")!)
        view.backgroundColor = cardCollectionView.backgroundColor
        cardToolbar.barTintColor = navigationController?.navigationBar.barTintColor
        cardToolbar.tintColor = navigationController?.navigationBar.tintColor
        setPauseView()
        setNewGame()
        startGame()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseGame()
    }
    
    fileprivate func setPauseView() {
        pauseView.backgroundColor = .black
        pauseView.alpha = 0.3
        view.addSubview(pauseView)
        pauseView.translatesAutoresizingMaskIntoConstraints = false
        let top = pauseView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottom = pauseView.bottomAnchor.constraint(equalTo: cardToolbar.topAnchor)
        let left = pauseView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let right = pauseView.rightAnchor.constraint(equalTo: view.rightAnchor)
        view.addConstraints([top, bottom, left, right])
        pauseView.isHidden = true
    }
    
    // MARK: Game state
    
    fileprivate func handleGuess() {
        if manager.selectedCards.count == 2 {
            // Checking match like this allows for duplicate character cards to match to a single sentence
            let characterCard = manager.getSelectedCardFor(type: .character)!
            let sentenceCard = manager.getSelectedCardFor(type: .sentence)!
            if characterCard.cardInfo == sentenceCard.matchInfo {
                handleCorrectGuess()
            } else {
                handleIncorrectGuess()
            }
        } else {
            displayAlert(self, title: "ERROR", message: "2 cards were not found for selection")
        }
    }
    
    fileprivate func handleCorrectGuess() {
        manager.upScore()
        updateScoreboard()
        manager.cards.remove(at: manager.cards.index(where: { $0 == manager.selectedCards[0].card })!)
        manager.cards.remove(at: manager.cards.index(where: { $0 == manager.selectedCards[1].card })!)
        cardCollectionView.deleteItems(at: [manager.selectedCards[0].path, manager.selectedCards[1].path])
        
        if manager.cards.count == 0 {
            endGame()
        } else {
            let alert = UIAlertController(title: "You found a match!", message: "", preferredStyle: .alert)
            present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            selectBtn.isEnabled = false
            manager.selectedCards.removeAll()
        }
    }
    
    fileprivate func handleIncorrectGuess() {
        manager.dropScore()
        updateScoreboard()
        displayAlert(self, title: "Cards do not match!", message: "Please try again")
        manager.deselectAllCards()
        selectBtn.isEnabled = false
        manager.selectedCards.removeAll()
        cardCollectionView.reloadData()
    }
    
    fileprivate func endGame() {
        GameBackend.sI.saveGameStat(mode: manager.currentMode, time: manager.timer.seconds, score: manager.currentScore)
        let alert = UIAlertController(title: "Congratulations!",
                                      message: "You have found all the matches in \(GameManager.Time.timeString(time: manager.timer.seconds))! Press continue to view the story.", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { (action) in
            self.performSegue(withIdentifier: LocalConstants.SegueToStoryID, sender: nil)
        }
        alert.addAction(continueAction)
        present(alert, animated: true, completion: nil)
        selectBtn.title = LocalConstants.SelectBtnStoryModeText
        manager.timer.resetTimer()
        pauseBtn.isEnabled = false
    }
    
    fileprivate func setNewGame() {
        selectBtn.title = LocalConstants.SelectBtnGameModeText
        selectBtn.isEnabled = false
        manager.selectedCards.removeAll()
        manager.setNewGame()
        cardCollectionView.reloadData()
    }
    
    fileprivate func pauseGame() {
        manager.timer.pauseTimer()
        pauseView.isHidden = false
        pauseBtn.title = "Resume"
    }
    
    fileprivate func startGame() {
        manager.timer.runTimer()
        pauseView.isHidden = true
        pauseBtn.title = "Pause"
        pauseBtn.isEnabled = true
    }
    
    fileprivate func updateScoreboard() {
        navigationItem.title = "\(GameManager.Time.timeString(time: manager.timer.seconds)), \(manager.currentScore)"
    }
    
    // MARK: Timer
    
    @objc fileprivate func updateTimer() {
        updateScoreboard()
        
        if (manager.currentMode == .medium && manager.timer.seconds % 120 == 0) || (manager.currentMode == .hard && manager.timer.seconds % 60 == 0) {
            manager.shuffleCards()
            
            // Need to update the current selected cards
            if manager.selectedCards.count > 0 {
                for i in 0..<manager.cards.count {
                    if manager.cards[i] == manager.selectedCards[0].card {
                        manager.selectedCards[0].card = manager.cards[i]
                        manager.selectedCards[0].path = IndexPath(row: i, section: 0)
                    }
                }
            }
            if manager.selectedCards.count > 1 {
                for i in 0..<manager.cards.count {
                    if manager.cards[i] == manager.selectedCards[1].card {
                        manager.selectedCards[1].card = manager.cards[i]
                        manager.selectedCards[1].path = IndexPath(row: i, section: 0)
                    }
                }
            }
            cardCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
}

extension GameViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedCard = manager.cards[indexPath.row]
        if manager.selectedCards.contains(where: { return $0.card == selectedCard && $0.path == indexPath }) {
            manager.cards[indexPath.row].isSelected = !selectedCard.isSelected
            manager.selectedCards.remove(at: manager.selectedCards.index(where: { return $0.card == selectedCard && $0.path == indexPath })!)
            selectBtn.isEnabled = false
            cardCollectionView.reloadData()
        } else {
            handleGameStateChange(selectedCard: selectedCard, path: indexPath)
        }
    }
    
    fileprivate func handleGameStateChange(selectedCard: MythCard, path: IndexPath) {
        if manager.selectedCards.count == 0 {
            manager.cards[path.row].isSelected = !selectedCard.isSelected
            manager.selectedCards.append((selectedCard, path))
            selectBtn.isEnabled = false
            cardCollectionView.reloadData()
            
        } else if manager.selectedCards.count == 1 {
            
            if manager.selectedCards[0].card.type == selectedCard.type {
                // Incorrect state
                if manager.selectedCards[0].card.type == .character {
                    displayAlert(self, title: "Wrong Card Type", message: "Must select a sentence card when a character card is selected. Press help for directions.")
                } else {
                    displayAlert(self, title: "Wrong Card Type", message: "Must select a character card when a sentence card is selected. Press help for directions.")
                }
                
            } else {
                // Add second card
                manager.cards[path.row].isSelected = !selectedCard.isSelected
                manager.selectedCards.append((selectedCard, path))
                selectBtn.isEnabled = true
                cardCollectionView.reloadData()
            }
            
        } else {
            // Prevent user from selected more than 2 cards
            if manager.selectedCards.count == 2 {
                displayAlert(self, title: "Two cards already selected", message: "Deselect a card to select a different one or make guess!")
            } else {
                displayAlert(self, title: "ERROR", message: "Multiple cards selected")
            }
        }
    }
    
    // MARK: Flow
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return LocalConstants.HSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return LocalConstants.VSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = LocalConstants.HSpacing * (LocalConstants.HCardCount - 1)
        let width = collectionView.bounds.width / CGFloat(LocalConstants.HCardCount) - spacing
        var height = collectionView.bounds.height / CGFloat(LocalConstants.VCardCount) - spacing
        
        if height < 150 {
            height = 150
        }
        return CGSize(width: width, height: height)
    }
}

extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocalConstants.CardReuseID, for: indexPath) as! MythCardCollectionCell
        
        let card = manager.cards[indexPath.row]
        cell.layer.borderColor = card.type == .character ? UIColor.red.cgColor : UIColor.blue.cgColor
        if card.isSelected {
            cell.backgroundColor = UIColor.white
            cell.cardInfoLbl.isHidden = false
            cell.cardInfoLbl.text = "\(card.cardInfo)"
            cell.imageView.isHidden = true
        } else {
            cell.backgroundColor = UIColor(patternImage: UIImage(named: "rustic_bg.jpg")!)
            cell.cardInfoLbl.isHidden = true
            cell.imageView.isHidden = false
            cell.imageView.image = UIImage(named: "boat.png")
        }

        formatCell(cell)
        return cell
    }
    
    fileprivate func formatCell(_ cell: MythCardCollectionCell) {
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.layer.borderWidth = 2
    }
}
