//
//  Posts.swift
//  Course2FinalTask
//
//  Created by Евгений on 26.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

struct Post: Codable {
    var id: String
    var description: String
    var image: String
    var createdTime: Date
    var currentUserLikesThisPost: Bool
    var likedByCount: Int
    var author: String
    var authorUsername: String
    var authorAvatar: String
}
