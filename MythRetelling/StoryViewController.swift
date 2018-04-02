//
//  StoryViewController.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/2/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var storyTextView: UITextView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStoryTextView()
    }
    
    // MARK: Story handling
    
    fileprivate func setStoryTextView() {
        if var myStrings = readInGameData() {
            storyTextView.text = ""
            while myStrings.count > 0 && myStrings[0] != "" {
                let characterString = myStrings[0]
                let sentence = myStrings[1]
                storyTextView.text = "\(storyTextView.text!)\n\n\(characterString): \"\(sentence)\""
                myStrings = Array(myStrings.dropFirst(3))
            }
        } else {
            displayAlert(self, title: "ERROR", message: "Story data could not be read")
        }
    }
}
