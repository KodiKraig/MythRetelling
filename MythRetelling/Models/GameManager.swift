//
//  GameManager.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/7/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import Foundation
import AVKit

class GameManager: NSObject {
    
    static var sI = GameManager()
    static let TimerDidUpdateNotification = Notification(name: Notification.Name.init("TimerDidUpdate"))
    var currentMode = Mode.medium
    var currentScore = 0
    var cards = [MythCard]()
    var selectedCards = [(card: MythCard, path: IndexPath)]()
    var timer = Time()
    fileprivate var audioPlayer: AVAudioPlayer?
    fileprivate var isPlayingSound = false
    fileprivate var isPlayingMainMenuSound = true
    fileprivate let mainMenuMusicName = (name: "Marimba_Boy", ext: "wav")
    fileprivate let gameplayMusicName = (name: "Shanghai_Action1", ext: "wav")

    enum Mode: String {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        static func getDifficulty(value: Int) -> Mode {
            switch value {
            case 1:
                return Mode.medium
            case 2:
                return Mode.hard
            default:
                return Mode.easy
            }
        }
        
        static func getDifficulty(value: Mode) -> Int {
            switch value {
            case .easy:
                return 0
            case .medium:
                return 1
            case .hard:
                return 2
            }
        }
    }
    
    struct Score {
        struct Hard {
            static let CorrectGuessScore = 10
            static let IncorrectGuessScore = -8
        }
        struct Medium {
            static let CorrectGuessScore = 7
            static let IncorrectGuessScore = -4
        }
        struct Easy {
            static let CorrectGuessScore = 5
            static let IncorrectGuessScore = -1
        }
    }
    
    // MARK: init
    
    override init() {
        super.init()
        setNewGame()
    }
    
    func setNewGame() {
        currentScore = 0
        timer = Time()
        selectedCards = [(card: MythCard, path: IndexPath)]()
        setCards()
        shuffleCards()
    }
    
    func upScore() {
        switch currentMode {
        case .easy:
            currentScore+=Score.Easy.CorrectGuessScore
        case .medium:
            currentScore+=Score.Medium.CorrectGuessScore
        case .hard:
            currentScore+=Score.Hard.CorrectGuessScore
        }
    }
    
    func dropScore() {
        switch currentMode {
        case .easy:
            currentScore+=Score.Easy.IncorrectGuessScore
        case .medium:
            currentScore+=Score.Medium.IncorrectGuessScore
        case .hard:
            currentScore+=Score.Hard.IncorrectGuessScore
        }
    }
    
    // MARK: Audio player
    
    func playMainMenuSound() {
        if audioPlayer == nil || !isPlayingMainMenuSound {
            if let url = Bundle.main.url(forResource: mainMenuMusicName.name, withExtension: mainMenuMusicName.ext) {
                if let sound = try? AVAudioPlayer(contentsOf: url) {
                    if audioPlayer != nil {
                        audioPlayer?.stop()
                    }
                    
                    sound.delegate = self
                    sound.prepareToPlay()
                    sound.play()
                    audioPlayer = sound
                }
            }
        } else {
            audioPlayer?.play()
        }
        
        if audioPlayer != nil {
            isPlayingSound = true
            isPlayingMainMenuSound = true
        }
    }
    
    func playGameplaySound() {
        if audioPlayer == nil || isPlayingMainMenuSound {
            if let url = Bundle.main.url(forResource: gameplayMusicName.name, withExtension: gameplayMusicName.ext) {
                if let sound = try? AVAudioPlayer(contentsOf: url) {
                    if audioPlayer != nil {
                        audioPlayer?.stop()
                    }
                    
                    sound.delegate = self
                    sound.prepareToPlay()
                    sound.play()
                    audioPlayer = sound
                }
            }
        } else {
            audioPlayer?.play()
        }
        
        if audioPlayer != nil {
            isPlayingSound = true
            isPlayingMainMenuSound = false
        }
    }
    
    func stopPlayingSound() {
        isPlayingSound = false
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    fileprivate func pauseSound() {
        isPlayingSound = false
        audioPlayer?.pause()
    }
    
    // MARK: Timer
    
    class Time {
        var seconds = 0
        var isPaused = false
        fileprivate var timer: Timer?
        
        deinit {
            timer?.invalidate()
        }
        
        func pauseTimer() {
            timer?.invalidate()
            timer = nil
            isPaused = true
        }
        
        func resetTimer() {
            timer?.invalidate()
            timer = nil
            seconds = 0
        }
        
        func runTimer() {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            isPaused = false
        }
        
        @objc fileprivate func updateTimer() {
            seconds+=1
            NotificationCenter.default.post(GameManager.TimerDidUpdateNotification)
        }
        
        class func timeString(time:Int) -> String {
            let time = TimeInterval(time)
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i:%02i", minutes, seconds)
        }
    }
    
    // MARK: Card handling
    
    func setCards() {
        if var myStrings = readInGameData() {
            cards.removeAll()
            while myStrings.count > 0 && myStrings[0] != "" {
                let characterString = myStrings[0]
                let sentence = myStrings[1]
                cards.append(MythCard(cardInfo: characterString))
                cards.append(MythCard(cardInfo: sentence, matchingInfo: characterString))
                myStrings = Array(myStrings.dropFirst(3))
            }
//            cards = Array(cards.dropLast(cards.count - 4))
        }
    }
    
    func shuffleCards() {
        if cards.count > 0 {
            for i in (0 ..< cards.count).reversed() {
                let j = Int(arc4random_uniform(UInt32(cards.count)))
                let temp = cards[i]
                cards[i] = cards[j]
                cards[j] = temp
            }
        }
    }
    
    func deselectAllCards() {
        for card in cards {
            card.isSelected = false
        }
    }
    
    func getSelectedCardFor(type: MythCardType) -> MythCard? {
        if let index = selectedCards.index(where: { $0.card.type == type }) {
            return selectedCards[index].card
        }
        return nil
    }
}

extension GameManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlayingSound = false
        if isPlayingMainMenuSound {
            playMainMenuSound()
        } else {
            playGameplaySound()
        }
    }
}

