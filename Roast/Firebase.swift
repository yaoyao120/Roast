//
//  Firebase.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-19.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

struct FBKeyString {
    
    /* Database */
    /////users
    static let users = "users"
    static let username = "name"
    static let profileImageUrl = "profileImageUrl"
    static let userID = "id"
    
    /////posts
    static let posts = "posts"
    static let creationDate = "creationDate"
    
    //post
    static let postTitle = "postTitle"
    static let postCoverImageUrls = "postCoverImageUrls"
    static let postCoverImageWidth = "postCoverImageWidth"
    static let postCoverImageHeight = "postCoverImageHeight"
    
    /////roast
    static let roastsByUser = "roastsByUser"
    static let roastsByPost = "roastByPost"
    //roast
    static let postID = "postID"
    static let roastImageUrl = "roastImageUrl"
    static let roastImageWidth = "roastImageWidth"
    static let roastImageHeight = "roastImageHeight"
    static let roastText = "roastText"
    
    /////comments
    static let comments = "comments"
    
    //comment
    static let commentText = "commentText"
    
    /////likes
    static let likes = "likes"
    
    /////following
    static let following = "following"
    
    /* Storage */
    static let profileImages = "profile_images"
    static let postImages = "post_images"
    static let roastImages = "roast_images"
}

extension FIRDatabase {
    
    static func uploadProfileImageData(imageData: Data, completion: @escaping () -> ()) {
        
        let filename = NSUUID().uuidString
        FIRStorage.storage().reference().child(FBKeyString.profileImages).child(filename).put(imageData, metadata: nil, completion: { (metadata, err) in
            
            if let err = err {
                print("Failed to upload profile image:", err)
                return
            }
            
            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            print("Successfully uploaded profile image:", profileImageUrl)
            
            guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
            
            let values = [FBKeyString.profileImageUrl: profileImageUrl]
            
            FIRDatabase.database().reference().child(FBKeyString.users).child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if let err = err {
                    print("Failed to save user info into db:", err)
                    return
                }
                print("Successfully saved user info to db")
                
                completion()
            })
            
        })
        
    }
    
//    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> () ) {
//        
//        FIRDatabase.database().reference().child(FBKeyString.users).child(uid).observeSingleEvent(of: .value, with: {
//            snapshot in
//            guard let dictionary = snapshot.value as? [String: Any] else { return }
//            let user = User(uid: uid, dictionary: dictionary)
//            
//            print("*** Successfully fetch user: \(uid)")
//            
//            completion(user)
//            
//        }, withCancel: {
//            error in
//            
//            print("*** Fail to fetch user. Error: \(error)")
//        })
//    }
    
}
