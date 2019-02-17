//
//  Comment.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-21.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import Foundation

class Comment {
    var user: User = User()
    var commentID: String = ""
    var text: String = ""
    var uid: String = ""
    var creationDate: Date = Date()
    
    var hasLiked: Bool = false
    var numberOfLikes: Int = 0
    
    init(commentID: String, user: User, dictionary: [String: Any]) {
        self.user = user
        self.commentID = commentID
        text = dictionary[FBKeyString.commentText] as? String ?? ""
        uid = dictionary[FBKeyString.userID] as? String ?? ""
        if let secondsFrom1970 = dictionary[FBKeyString.creationDate] as? Double {
            creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        } else {
            creationDate = Date()
        }
    }
}
