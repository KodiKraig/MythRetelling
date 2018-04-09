//
//  HelpTableViewController.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/7/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    fileprivate var info = [[HelpInfo.gameplay], [HelpInfo.scoring], [HelpInfo.background]]
    fileprivate var sectionHeaders = ["Gameplay", "Scoring", "Background"]
    
    fileprivate struct LocalConstants {
        static let CenterCellID = "CenterLabelCell"
    }
    
    fileprivate struct HelpInfo {
        static let gameplay = "\tThe objective of the game is to match the character cards with the dialogue cards that would be spoken by the character till there are no more cards left. A incorrect guess results in points being subtracted from the score and the cards being turned back over. A correct guess results in points being added to your score and the cards being removed from the table. After all the cards are removed, the game is over and the story is revealed.\n"
        static let scoring = "\tEach game is uploaded to the global score board with the time and score that you received.\nThere are three different difficulties with different scoring breakdowns. When medium mode is enabled, the cards are reshuffled every 120 seconds. When hard mode is enabled, the cards are reshuffled every 60 seconds.\nEasy: Correct guess: \(GameManager.Score.Easy.CorrectGuessScore) Incorrect guess \(GameManager.Score.Easy.IncorrectGuessScore)\nMedium: Correct guess: \(GameManager.Score.Medium.CorrectGuessScore) Incorrect guess \(GameManager.Score.Medium.IncorrectGuessScore)\nHard: Correct guess: \(GameManager.Score.Hard.CorrectGuessScore) Incorrect guess \(GameManager.Score.Hard.IncorrectGuessScore)\n"
        static let background = "\tThe game was inspired from the book the Odyssey and is retelling of the end of the book where Odysseus comes back home from his journey. After slaying the suitors, he is faced with retaliation from the locals in Ithaca. A battle is avoided by Athena erasing their minds of the event. The retelling is meant to shed light on the fact that in the current day, many negative events in our society come and go as if they never happened. It is important that we don't forget these negative events affecting individuals and make a stand against those in power."
    }
    
    // MARK: IBOutlets
    
    @IBOutlet var helpTableView: UITableView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "paper_bg")!)
        helpTableView.backgroundColor = .clear
        helpTableView.separatorStyle = .none
    }
}

extension HelpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
        lbl.text = "\t\(sectionHeaders[section])"
        lbl.backgroundColor = Constants.SecondaryColor
        lbl.textColor = .white
        lbl.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        return lbl
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension HelpViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return info.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocalConstants.CenterCellID, for: indexPath) as! HelpLabelTableViewCell
        cell.backgroundColor = .clear
        cell.centerLabel.text = info[indexPath.section][indexPath.row]
        cell.centerLabel.font = indexPath.section == info.count - 1 ? UIFont(name: "ChalkboardSE-Regular", size: 16) : UIFont(name: "ChalkboardSE-Bold", size: 16)
        return cell
    }
}
