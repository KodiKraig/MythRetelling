//
//  MythCard.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/1/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import Foundation

class MythCard {
    var cardInfo = ""
    var isSelected = false
    
    convenience init(info: String) {
        self.init()
        cardInfo = info
    }
}
