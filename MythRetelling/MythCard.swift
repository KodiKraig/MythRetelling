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

    init(cardInfo: String, type: MythCardType) {
        self.cardInfo = cardInfo
        self.type = type
    }

    convenience init(cardInfo: String, matchingInfo: String, type: MythCardType) {
        self.init(cardInfo: cardInfo, type: type)
        self.matchInfo = matchingInfo
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

