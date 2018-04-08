//
//  GameBackend.swift
//  MythRetelling
//
//  Created by Cody Craig on 4/8/18.
//  Copyright © 2018 Cody Craig. All rights reserved.
//

import UIKit

class GameBackend {
    static var sI = GameBackend()
    fileprivate let backendless = Backendless.sharedInstance()!

    func checkIfUserLoggedIn() -> Bool {
        return backendless.userService.isValidUserToken() == 1 ? true : false
    }
    
    func logout() {
        backendless.userService.logout()
        GameBackend.sI = GameBackend()
        GameManager.sI = GameManager()
    }
    
    func getAllGameStats(completionHandler: @escaping ([GameStat]?, String?) -> Swift.Void) {
        let dataStore = self.backendless.data.of(GameStat.ofClass())
        let request = DataQueryBuilder()!
        request.setPageSize(100)
        dataStore?.find(request, response: { (result) in
            let stats = result as! [GameStat]
            if stats.count > 0 {
                completionHandler(stats, nil)
            } else {
                completionHandler(nil, nil)
            }
        }, error: { (fault) in
            completionHandler(nil, fault?.message)
        })
    }
    
    func saveGameStat(mode: GameManager.Mode, time: Int, score: Int) {
        let newStat = GameStat()
        newStat.mode = GameManager.Mode.getDifficulty(value: mode)
        newStat.time = time
        newStat.score = score
        if let backendStatObj = backendless.data.of(GameStat.ofClass())?.save(newStat) as? GameStat {
            _ = backendless.data.of(GameStat.ofClass())?.setRelation("userRelation", parentObjectId: backendStatObj.objectId, childObjects: [backendless.userService.currentUser.objectId])
        }
    }
}
