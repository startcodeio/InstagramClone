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
    var users: PostUsers = PostUsers()
    var location: GeoPoint? = nil
    let publishDate: Timestamp
}

struct PostUsers: Codable {
    var liked: [String] = []
    var commented: [String] = []
    var saved: [String] = []
}
