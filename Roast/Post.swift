//
//  Post.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-28.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import Foundation

enum PostType: String {
    case image
    case video
}

class Post {
    
    var id: String?
    var creationDate = Date()
    var user = User()
    var roasts = [Roast]()
    
    var caption: String = ""
    var coverImageUrl = String()
    var coverImageWidth = Double()
    var coverImageHeight = Double()
    
    var hasLiked: Bool = false
    var numberOfRoasts: Int = 0
    var numberOfLikes: Int = 0
    
    init(postId: String, user: User, dictionary: [String: Any]) {
        if let secondsFrom1970 = dictionary[FBKeyString.creationDate] as? Double {
            self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        }
        self.id = postId
        self.user = user
        
        if let caption = dictionary[FBKeyString.postTitle] as? String {
            self.caption = caption
        }
        if let url = dictionary[FBKeyString.postCoverImageUrls] as? String {
            self.coverImageUrl = url
        }
        if let width = dictionary[FBKeyString.postCoverImageWidth] as? Double {
            self.coverImageWidth = width
        }
        if let height = dictionary[FBKeyString.postCoverImageHeight] as? Double {
            self.coverImageHeight = height
        }
    }
}
