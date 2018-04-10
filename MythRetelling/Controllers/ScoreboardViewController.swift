//
//  ScoreboardViewController.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/8/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit
import CoreData

class ScoreboardViewController: UIViewController {
    
    fileprivate var scores: [GameStat]?
    fileprivate let managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    fileprivate enum Sort {
        case name, mode, time, score
    }
    
    // MARK: Constants
    
    fileprivate struct LocalConstants {
        static let ScoreCellReuseID = "ScoreCell"
    }

    // MARK: IBOutlets

    @IBOutlet var nameBtn: UIButton!
    @IBOutlet var modeBtn: UIButton!
    @IBOutlet var scoreBtn: UIButton!
    @IBOutlet var timeBtn: UIButton!
    @IBOutlet var scoreSortBtns: [UIButton]!
    @IBOutlet var scoreTableView: UITableView!
    
    // MARK: IBActions
    
    @IBAction func nameBtnPressed(_ sender: UIButton) {
        sortTable(.name)
    }
    
    @IBAction func modeBtnPressed(_ sender: UIButton) {
        sortTable(.mode)
    }
    
    @IBAction func scoreBtnPressed(_ sender: UIButton) {
        sortTable(.score)
    }
    
    @IBAction func timeBtnPressed(_ sender: UIButton) {
        sortTable(.time)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "paper_bg")!)
        setScoreboardSortBtns()
        scoreTableView.backgroundColor = .clear
        scoreTableView.separatorStyle = .none
        setScoreTableData()
    }
    
    // MARK: Helpers
    
    fileprivate func setScoreTableData() {
        GameBackend.sI.getAllGameStats { (stats, error) in
            if error != nil {
                displayAlert(self, title: "Error retrieving scores", message: error!)
            } else if stats != nil {
                self.scores = stats
                self.sortTable(.score)
            }
        }
    }
    
    fileprivate func setScoreboardSortBtns() {
        for b in scoreSortBtns {
            b.tintColor = Constants.SecondaryColor
            b.setTitleColor(UIColor.white, for: .normal)
            b.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    fileprivate func sortTable(_ option: Sort) {
        if scores != nil {
            switch option {
            case .name:
                scores = scores!.sorted(by: {
                    guard let n1 = $0.userRelation?.getProperty("name") as? String, let n2 = $1.userRelation?.getProperty("name") as? String else {
                        return false
                    }
                    return n1 < n2
                })
                selectScoreBtn(btn: nameBtn)
            case .mode:
                scores = scores!.sorted(by: {
                    return $0.mode < $1.mode
                })
                selectScoreBtn(btn: modeBtn)
            case .time:
                scores = scores!.sorted(by: {
                    return $0.time < $1.time
                })
                selectScoreBtn(btn: timeBtn)
            case .score:
                scores = scores!.sorted(by: {
                    return $0.score > $1.score
                })
                selectScoreBtn(btn: scoreBtn)
            }
            scoreTableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }
    
    fileprivate func selectScoreBtn(btn: UIButton) {
        for b in scoreSortBtns {
            b.isSelected = b == btn ? true : false
        }
    }
}

extension ScoreboardViewController: UITableViewDelegate {
}

extension ScoreboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocalConstants.ScoreCellReuseID, for: indexPath) as! ScoreTableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        if scores == nil {
            cell.nameLbl.text = "No games found..."
            cell.difficultyLbl.text = ""
            cell.timeLbl.text = ""
            cell.scoreLbl.text = ""
            cell.nameLbl.textColor = .darkGray
        } else {
            let game = scores![indexPath.row]
            cell.nameLbl.text = game.userRelation?.getProperty("name") as? String
            cell.difficultyLbl.text = GameManager.Mode.getDifficulty(value: game.mode).rawValue
            cell.timeLbl.text = GameManager.Time.timeString(time: game.time)
            cell.scoreLbl.text = "\(game.score)"
            cell.nameLbl.textColor = .black
        }
        return cell
    }
    
    
}
