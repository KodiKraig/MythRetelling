//
//  Utilities.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/2/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit

func displayAlert(_ vc: UIViewController, title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Continue", style: .cancel, handler: nil)
    alert.addAction(okAction)
    vc.present(alert, animated: true, completion: nil)
}


func readInGameData() -> [String]? {
    if let path = Bundle.main.path(forResource: "game_cards", ofType: "txt") {
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            return data.components(separatedBy: .newlines)
        } catch {
            print(error)
        }
    }
    return nil
}
