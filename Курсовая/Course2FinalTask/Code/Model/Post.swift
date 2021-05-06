//
//  Posts.swift
//  Course2FinalTask
//
//  Created by Евгений on 26.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

final class Post: Codable {
    var id: String
    var description: String
    var image: String
    var imageData: Data?
    var createdTime: Date
    var currentUserLikesThisPost: Bool
    var likedByCount: Int
    var author: String
    var authorUsername: String
    var authorAvatar: String
    var authorAvatarData: Data?
    
    init(id: String, description: String, image: String, imageData: Data, createdTime: Date, currentUserLikesThisPost: Bool, likedByCount: Int, author: String, authorUsername: String, authorAvatar: String, authorAvatarData: Data) {
        self.id = id
        self.description = description
        self.image = image
        self.imageData = imageData
        self.createdTime = createdTime
        self.currentUserLikesThisPost = currentUserLikesThisPost
        self.likedByCount = likedByCount
        self.author = author
        self.authorUsername = authorUsername
        self.authorAvatar = authorAvatar
        self.authorAvatarData = authorAvatarData
    }
}
