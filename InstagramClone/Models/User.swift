//
//  User.swift
//  InstagramClone
//
//  Created by user on 16.11.2021.
//

import Foundation

struct User: Codable {
    let uid: String
    let username: String
    var bio: String = ""
    let email: String
    let avatar: String
    var counters: UserCounters = UserCounters()
    var followingUsers: [String] = []
}

struct UserCounters: Codable {
    var followers: Int = 0
    var followings: Int = 0
    var posts: Int = 0
}
