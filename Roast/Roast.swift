//
//  Roast.swift
//  Roast
//
//  Created by Xiang Li on 2017-06-27.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import Foundation

class Roast {
    
    var roastId: String = ""
    var user: User = User()
    var roastText: String = ""
    var uid: String = ""
    var creationDate: Date = Date()
    var roastImageUrl: String = ""
    var roastImageWidth: Double = 0
    var roastImageHeight: Double = 0
    
    var comments = [Comment]()
    var numberOfComments: Int = 0
    
    var hasLiked: Bool = false
    var numberOfLikes: Int = 0
    
    init(roastId: String, user: User, dictionary: [String: Any]) {
        self.roastId = roastId
        self.user = user
        roastText = dictionary[FBKeyString.roastText] as? String ?? ""
        uid = dictionary[FBKeyString.userID] as? String ?? ""
        
        if let secondsFrom1970 = dictionary[FBKeyString.creationDate] as? Double {
            creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        } else {
            creationDate = Date()
        }
        roastImageUrl = dictionary[FBKeyString.roastImageUrl] as? String ?? ""
        roastImageWidth = dictionary[FBKeyString.roastImageWidth] as? Double ?? 0
        roastImageHeight = dictionary[FBKeyString.roastImageHeight] as? Double ?? 0
    }
}
