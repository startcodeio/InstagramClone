//
//  Post.swift
//  InstagramClone
//
//  Created by user on 18.11.2021.
//

import Foundation
import FirebaseFirestore

struct Post: Codable {
    let id: String
    let image: String
    let description: String
    let author: Author
    let counters: PostCounters = PostCounters()
    let users: PostUsers = PostUsers()
    let location: GeoPoint? = nil
    let publishDate: Timestamp
}

struct PostCounters: Codable {
    let likes: Int = 0
    let comments: Int = 0
}

struct PostUsers: Codable {
    let commented: [String] = []
    let saved: [String] = []
}

struct Author: Codable {
    let uid: String
    let username: String
    let avatar: String
}
