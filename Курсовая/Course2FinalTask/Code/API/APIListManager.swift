//
//  APIListManager.swift
//  Course2FinalTask
//
//  Created by Евгений on 19.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
import UIKit

final class APIListManager: APIManager, RequestManager {
    
    let sessionConfiguration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration)
    }()
    
    static var token = ""
    
    init(sessionConfiguration: URLSessionConfiguration) {
        self.sessionConfiguration = sessionConfiguration
    }
    
    convenience init () {
        self.init(sessionConfiguration: URLSessionConfiguration.default)
    }
    
    
    func signin(login: String, password: String, completion: @escaping (APIResult<Token>) -> Void) {
        let request = signinRequest(userName: login, password: password)
        fetch(request: request, completionHandler: completion)
    }
    
    func signout(token: String, completion: @escaping (APIResult<Bool>) -> Void) {
        let request = signoutRequest(token: token)
        fetch(request: request, completionHandler: completion)
    }
    
    func feed(token: String, completion: @escaping (APIResult<[Post]>) -> Void) {
        let request = feedRequest(token: token)
        fetch(request: request, completionHandler: completion)
    }
    
    func currentUser(token: String, completion: @escaping (APIResult<User>) -> Void) {
        let request = currentUserRequest(token: token)
        fetch(request: request, completionHandler: completion)
    }
    
    func userID(token: String, id: String, completion: @escaping (APIResult<User>) -> Void) {
        let request = userIDRequest(token: token, id: id)
        fetch(request: request, completionHandler: completion)
    }
    
    func userPosts(token: String, id: String, completion: @escaping (APIResult<[Post]>) -> Void) {
        let request = userPostsRequest(token: token, id: id)
        fetch(request: request, completionHandler: completion)
    }
    
    func usersLikedPost(token: String, id: String, completion: @escaping (APIResult<[User]>) -> Void) {
        let request = usersLikedPostRequest(token: token, id: id)
        fetch(request: request, completionHandler: completion)
    }
    
    func likePost(token: String, id: String, completion: @escaping (APIResult<Post>) -> Void) {
        let request = likePostRequest(token: token, id: id)
        fetch(request: request, completionHandler: completion)
    }
    
    func unlikePost(token: String, id: String, completion: @escaping (APIResult<Post>) -> Void) {
        let request = unlikePostRequest(token: token, id: id)
        fetch(request: request, completionHandler: completion)
    }
    
    func usersFollowing(token: String, id: String, completion: @escaping (APIResult<[User]>) -> Void) {
        let request = usersFollowingRequest(token: token, id: id)
        fetch(request: request, completionHandler: completion)
    }
    
    func usersFollowers(token: String, id: String, completion: @escaping (APIResult<[User]>) -> Void) {
        let request = usersFollowersRequest(token: token, id: id)
        fetch(request: request, completionHandler: completion)
    }
    
    func follow(token: String, id: String, completion: @escaping (APIResult<User>) -> Void) {
        let request = followRequest(token: token, id: id)
        fetch(request: request, completionHandler: completion)
    }
    
    func unfollow(token: String, id: String, completion: @escaping (APIResult<User>) -> Void) {
        let request = unfollowRequest(token: token, id: id)
        fetch(request: request, completionHandler: completion)
    }
    
    func newPost(token: String, image: UIImage, description: String, completion: @escaping (APIResult<Post>) -> Void) {
        let request = newPostRequest(token: token, image: image, description: description)
        fetch(request: request, completionHandler: completion)
    }
}
