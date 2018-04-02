//
//  GameViewController.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/1/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    fileprivate var cards = [MythCard]()
    fileprivate var selectedCards = [(card: MythCard, path: IndexPath)]()
    
    // MARK: Constants
    
    fileprivate struct LocalConstants {
        static let CardReuseID = "CardCell"
        static let SegueToStoryID = "showStory"
        static let SelectBtnGameModeText = "Guess"
        static let SelectBtnStoryModeText = "View Story"
        static let HCardCount: CGFloat = 4
        static let HSpacing: CGFloat = 1
        static let VCardCount: CGFloat = 4
        static let VSpacing: CGFloat = 3
    }
    
    // MARK: Outlets
    
    @IBOutlet var cardCollectionView: UICollectionView!
    @IBOutlet var selectBtn: UIBarButtonItem!
    @IBOutlet var helpBtn: UIBarButtonItem!
    
    // MARK: IBActions
    
    @IBAction func newGameBtnPressed(_ sender: UIBarButtonItem) {
        setNewGame()
    }
    
    @IBAction func selectBtnPressed(_ sender: UIBarButtonItem) {
        if selectBtn.title == LocalConstants.SelectBtnGameModeText {
            handleGuess()
        } else {
            self.performSegue(withIdentifier: LocalConstants.SegueToStoryID, sender: nil)
        }
    }
    
    @IBAction func helpBtnPressed(_ sender: UIBarButtonItem) {
        presentHelpScreen()
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setNewGame()
    }
    
    // MARK: Game state
    
    fileprivate func handleGuess() {
        if selectedCards.count == 2 {
            // Checking match like this allows for duplicate character cards to match to a single sentence
            let characterCard = selectedCards[selectedCards.index(where: { $0.card.type == .character })!].card
            let sentenceCard = selectedCards[selectedCards.index(where: { $0.card.type == .sentence })!].card
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
        cards.remove(at: cards.index(where: { $0 == selectedCards[0].card })!)
        cards.remove(at: cards.index(where: { $0 == selectedCards[1].card })!)
        cardCollectionView.deleteItems(at: [selectedCards[0].path, selectedCards[1].path])
        
        if cards.count == 0 {
            endGame()
        } else {
            let alert = UIAlertController(title: "You found a match!", message: "", preferredStyle: .alert)
            present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            selectBtn.isEnabled = false
            selectedCards.removeAll()
        }
    }
    
    fileprivate func handleIncorrectGuess() {
        displayAlert(self, title: "Cards do not match!", message: "Please try again")
        deselectAllCards()
        selectBtn.isEnabled = false
        selectedCards.removeAll()
        cardCollectionView.reloadData()
    }
    
    fileprivate func endGame() {
        let alert = UIAlertController(title: "Congratulations!", message: "You have found all the matches! Press continue to view the story.", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { (action) in
            self.performSegue(withIdentifier: LocalConstants.SegueToStoryID, sender: nil)
        }
        alert.addAction(continueAction)
        present(alert, animated: true, completion: nil)
        selectBtn.title = LocalConstants.SelectBtnStoryModeText
    }
    
    fileprivate func setNewGame() {
        selectBtn.title = LocalConstants.SelectBtnGameModeText
        selectBtn.isEnabled = false
        selectedCards.removeAll()
        setCards()
        shuffleCards()
        cardCollectionView.reloadData()
    }

    // MARK: Card handling
    
    fileprivate func setCards() {
        if var myStrings = readInGameData() {
            cards.removeAll()
            while myStrings.count > 0 && myStrings[0] != "" {
                let characterString = myStrings[0]
                let sentence = myStrings[1]
                cards.append(MythCard(cardInfo: characterString, type: MythCardType.character))
                cards.append(MythCard(cardInfo: sentence, matchingInfo: characterString, type: MythCardType.sentence))
                myStrings = Array(myStrings.dropFirst(3))
            }
        } else {
            displayAlert(self, title: "ERROR", message: "Could not read in game data")
        }
    }

    fileprivate func shuffleCards() {
        for i in (0 ..< cards.count).reversed() {
            let j = Int(arc4random_uniform(UInt32(cards.count)))
            let temp = cards[i]
            cards[i] = cards[j]
            cards[j] = temp
        }
    }
    
    fileprivate func deselectAllCards() {
        for card in cards {
            card.isSelected = false
        }
    }
    
    fileprivate func presentHelpScreen() {
        // TODO
    }
}

extension GameViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedCard = cards[indexPath.row]
        if selectedCards.contains(where: { return $0.card == selectedCard && $0.path == indexPath }) {
            cards[indexPath.row].isSelected = !selectedCard.isSelected
            selectedCards.remove(at: selectedCards.index(where: { return $0.card == selectedCard && $0.path == indexPath })!)
            selectBtn.isEnabled = false
            cardCollectionView.reloadData()
        } else {
            handleGameStateChange(selectedCard: selectedCard, path: indexPath)
        }
    }
    
    fileprivate func handleGameStateChange(selectedCard: MythCard, path: IndexPath) {
        if selectedCards.count == 0 {
            cards[path.row].isSelected = !selectedCard.isSelected
            selectedCards.append((selectedCard, path))
            selectBtn.isEnabled = false
            cardCollectionView.reloadData()
            
        } else if selectedCards.count == 1 {
            
            if selectedCards[0].card.type == selectedCard.type {
                // Incorrect state
                if selectedCards[0].card.type == .character {
                    displayAlert(self, title: "Wrong Card Type", message: "Must select a sentence card when a character card is selected. Press help for directions.")
                } else {
                    displayAlert(self, title: "Wrong Card Type", message: "Must select a character card when a sentence card is selected. Press help for directions.")
                }
                
            } else {
                // Add second card
                cards[path.row].isSelected = !selectedCard.isSelected
                selectedCards.append((selectedCard, path))
                selectBtn.isEnabled = true
                cardCollectionView.reloadData()
            }
            
        } else {
            // Prevent user from selected more than 2 cards
            if selectedCards.count == 2 {
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
        return CGSize(width: collectionView.bounds.width / CGFloat(LocalConstants.HCardCount) - spacing,
                      height: collectionView.bounds.height / CGFloat(LocalConstants.VCardCount) - spacing)
    }
}

extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocalConstants.CardReuseID, for: indexPath) as! MythCardCollectionCell
        formatCell(cell, card: cards[indexPath.row])
        return cell
    }
    
    fileprivate func formatCell(_ cell: MythCardCollectionCell, card: MythCard) {
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.layer.borderWidth = 2
        cell.layer.borderColor = card.type == .character ? UIColor.black.cgColor : UIColor.red.cgColor
        
        if card.isSelected {
            cell.backgroundColor = UIColor.cyan
            cell.cardInfoLbl.text = "\(card.cardInfo), \(card.matchInfo)"
        } else {
            cell.backgroundColor = UIColor.blue
            cell.cardInfoLbl.text = "\(card.cardInfo), \(card.matchInfo)"
        }
    }
}
