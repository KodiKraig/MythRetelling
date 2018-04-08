//
//  MythCard.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/1/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import Foundation

enum MythCardType {
    case character, sentence
}

// Class for the character and sentence card. Should use polymorphism in future
class MythCard: Equatable {
    
    var cardInfo = ""
    var matchInfo = ""
    var type = MythCardType.sentence
    var isSelected = false
    
    // MARK: init

    init(cardInfo: String) {
        self.cardInfo = cardInfo
        self.type = .character
    }

    convenience init(cardInfo: String, matchingInfo: String) {
        self.init(cardInfo: cardInfo)
        self.matchInfo = matchingInfo
        self.type = .sentence
    }
    
    // MARK: Equatable
    
    static func ==(lhs: MythCard, rhs: MythCard) -> Bool {
        return
            lhs === rhs ||
            (lhs.cardInfo == rhs.cardInfo &&
            lhs.matchInfo == rhs.matchInfo &&
            lhs.isSelected == rhs.isSelected &&
            lhs.type == rhs.type)
    }
}

