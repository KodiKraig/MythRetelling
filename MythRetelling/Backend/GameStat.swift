//
//  GameStat.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/8/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import Foundation

@objcMembers
class GameStat: NSObject {
    var mode = 0
    var time = 0
    var score = 0
    var userRelation: BackendlessUser?
    var objectId: String?
}
