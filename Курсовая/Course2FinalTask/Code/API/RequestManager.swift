//
//  RequestManager.swift
//  Course2FinalTask
//
//  Created by Евгений on 19.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
import UIKit

protocol RequestManager {
    func signinRequest(userName: String, password: String) -> URLRequest
}

extension RequestManager {
    
    //    Вход
    func signinRequest(userName: String, password: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/signin")!
        var request = URLRequest(url: url)
        
        let logPass = Sign(login: userName, password: password)
        
        let encoder = JSONEncoder()
        let data = try? encoder.encode(logPass)
        
        if let data = data {
            request.httpBody = data
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    //    Возвращаем массив постов (ленту)
    func feedRequest(token: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/posts/feed")!
        var request = URLRequest(url: url)
        
        let header = [
            "Content-Type" : "POST /data HTTP/1.1",
            "Token" : "\(token)"
        ]
        
        request.allHTTPHeaderFields = header
        
        return request
    }
    
    //    Выход
    func signoutRequest(token: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/signout")!
        var request = URLRequest(url: url)
        
        let header = [
            "Content-Type" : "POST /data HTTP/1.1",
            "Token" : "\(token)"
        ]
        
        request.allHTTPHeaderFields = header
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    //    Возвращает текущего пользователя
    func currentUserRequest(token: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/users/me")!
        var request = URLRequest(url: url)
        
        let header = [
            "Content-Type" : "POST /data HTTP/1.1",
            "Token" : "\(token)"
        ]
        
        request.allHTTPHeaderFields = header
        
        return request
    }
    
    //    Возвращает информацию о пользователе с запрошенным ID
    func userIDRequest(token: String, id: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/users/\(id)")!
        var request = URLRequest(url: url)
        
        let header = [
            "Content-Type" : "POST /data HTTP/1.1",
            "Token" : "\(token)"
        ]
        
        request.allHTTPHeaderFields = header
        
        return request
    }
    
    //    Возвращает публикации пользователя с запрошенным ID
    func userPostsRequest(token: String, id: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/users/\(id)/posts")!
        var request = URLRequest(url: url)
        
        let header = [
            "Content-Type" : "POST /data HTTP/1.1",
            "Token" : "\(token)"
        ]
        
        request.allHTTPHeaderFields = header
        
        return request
    }
    
    //    Возвращает пользователей, поставивших лайк на публикацию с запрошенным ID
    func usersLikedPostRequest(token: String, id: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/posts/\(id)/likes")!
        var request = URLRequest(url: url)
        
        let header = [
            "Content-Type" : "POST /data HTTP/1.1",
            "Token" : "\(token)"
        ]
        
        request.allHTTPHeaderFields = header
        
        return request
    }
    
    //    Ставит лайк от текущего пользователя на публикации с запрошенным ID
    func likePostRequest(token: String, id: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/posts/like")!
        var request = URLRequest(url: url)
        
        let header = ["Token" : "\(token)"]
        
        let postID = PostID(postID: id)
        
        let encoder = JSONEncoder()
        let data = try? encoder.encode(postID)
        
        if let data = data {
            request.allHTTPHeaderFields = header
            request.httpBody = data
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
    
    //    Удаляет лайк от текущего пользователя на публикации с запрошенным ID
    func unlikePostRequest(token: String, id: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/posts/unlike")!
        var request = URLRequest(url: url)
        
        let header = ["Token" : "\(token)"]
        
        let postID = PostID(postID: id)
        
        let encoder = JSONEncoder()
        let data = try? encoder.encode(postID)
        
        if let data = data {
            request.allHTTPHeaderFields = header
            request.httpBody = data
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
    
    //    Возвращает подписки пользователя с запрошенным ID
    func usersFollowingRequest(token: String, id: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/users/\(id)/following")!
        var request = URLRequest(url: url)
        
        let header = ["Token" : "\(token)"]
        
        request.allHTTPHeaderFields = header
        
        return request
    }
    
    //    Возвращает подписчиков пользователя с запрошенным ID
    func usersFollowersRequest(token: String, id: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/users/\(id)/followers")!
        var request = URLRequest(url: url)
        
        let header = ["Token" : "\(token)"]
        
        request.allHTTPHeaderFields = header
        
        return request
    }
    
    //    Подписывает текущего пользователя на пользователя с запрошенным ID
    func followRequest(token: String, id: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/users/follow")!
        var request = URLRequest(url: url)
        
        let header = ["Token" : "\(token)"]
        
        let userID = UserID(userID: id)
        
        let encoder = JSONEncoder()
        let data = try? encoder.encode(userID)
        
        if let data = data {
            request.allHTTPHeaderFields = header
            request.httpBody = data
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
    
    //    Отписывает текущего пользователя от пользователя с запрошенным ID
    func unfollowRequest(token: String, id: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/users/unfollow")!
        var request = URLRequest(url: url)
        
        let header = ["Token" : "\(token)"]
        
        let userID = UserID(userID: id)
        
        let encoder = JSONEncoder()
        let data = try? encoder.encode(userID)
        
        if let data = data {
            request.allHTTPHeaderFields = header
            request.httpBody = data
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
    
    //  Создает новую публикацию
    func newPostRequest(token: String, image: UIImage, description: String) -> URLRequest {
        let url = URL(string: "http://localhost:8080/posts/create")!
        var request = URLRequest(url: url)
        
        let header = ["Token" : "\(token)"]
        
        if let imageData = image.jpegData(compressionQuality: 1) {
            let imageBase64String = imageData.base64EncodedString()
            let newPost = NewPost(image: imageBase64String, description: description)
            
            let encoder = JSONEncoder()
            
            if let data = try? encoder.encode(newPost) {
                request.allHTTPHeaderFields = header
                request.httpBody = data
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        return request
    }
}
