//
//  MainMenuViewController.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/7/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var difficultySegmentControl: UISegmentedControl!
    @IBOutlet var mainMenuToolbar: UIToolbar!
    
    // MARK: IBActions
    
    @IBAction func difficultySegmentControlPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            GameManager.sI.currentMode = .easy
            logoImageView.shake(distance: 5)
        case 1:
            GameManager.sI.currentMode = .medium
            logoImageView.shake(distance: 10)
        case 2:
            GameManager.sI.currentMode = .hard
            logoImageView.shake(distance: 15)
        default:
            break
        }
    }
    
    @IBAction func logoutBtnPressed(_ sender: UIBarButtonItem) {
        GameBackend.sI.logout()
        performSegue(withIdentifier: "GoToLogin", sender: nil)
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = Constants.PrimaryColor
        navigationController?.navigationBar.tintColor = UIColor.white
        mainMenuToolbar.barTintColor = Constants.PrimaryColor
        mainMenuToolbar.tintColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GameManager.sI.playMainMenuSound()
        switch GameManager.sI.currentMode {
        case .easy:
            difficultySegmentControl.selectedSegmentIndex = 0
        case .medium:
            difficultySegmentControl.selectedSegmentIndex = 1
        case .hard:
            difficultySegmentControl.selectedSegmentIndex = 2
        }
    }
}
