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
    
    fileprivate struct LocalConstants {
        static let CardReuseID = "CardCell"
        static let SelectedCardColor = UIColor.red
        static let UnselectedCardColor = UIColor.blue
    }
    
    @IBOutlet var cardCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        cards = [MythCard(),MythCard()]
    }
}

extension GameViewController: UICollectionViewDelegate {
    
}

extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocalConstants.CardReuseID, for: indexPath)
        cell.backgroundColor = LocalConstants.UnselectedCardColor
        return cell
    }
    
    
}
