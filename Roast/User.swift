//
//  User.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-07.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.username = dictionary[FBKeyString.username] as? String ?? ""
        self.profileImageUrl = dictionary[FBKeyString.profileImageUrl]  as? String ?? ""
        self.uid = uid
    }
    
    init() {
        self.uid = ""
        self.username = ""
        self.profileImageUrl = ""
    }
}
