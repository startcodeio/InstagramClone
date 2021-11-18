//
//  Activity.swift
//  InstagramClone
//
//  Created by user on 18.11.2021.
//

import Foundation
import FirebaseFirestore

struct Activity: Codable {
    let id: String
    let author: Author
    let linkId: String
    let toUid: String
    let type: Int
    let isRead: Bool
    let publishDate: Timestamp
}
