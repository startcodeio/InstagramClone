//
//  Helpers.swift
//  InstagramClone
//
//  Created by user on 18.11.2021.
//

import Foundation
import FirebaseAuth

enum Helpers {

    static var uid: String {
        Auth.auth().currentUser?.uid ?? "uidNotFound"
    }
    
    static var username: String {
        Auth.auth().currentUser?.displayName ?? "usernameNotFound"
    }
    
    static var avatar: String {
        Auth.auth().currentUser?.photoURL?.absoluteString ?? "avatarNotFound"
    }
    
    static var author: Author {
        Author(uid: Helpers.uid,
               username: Helpers.username,
               avatar: Helpers.avatar)
    }
    
}
