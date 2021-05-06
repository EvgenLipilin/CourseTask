//
//  CoreDataManager.swift
//  Course2FinalTask
//
//  Created by Евгений Липилин on 05.05.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol CoreDataProtocol {
    func getContext() -> NSManagedObjectContext
    func save(context: NSManagedObjectContext)
    func createObject<T: NSManagedObject>(from entity: T.Type) -> T
    func delete(object: NSManagedObject)
    func fetchData<T: NSManagedObject>(for entity: T.Type) -> [T]
}

protocol CoreDataInstagram {
    func saveFeedInCoreData(for entity: Feed.Type, posts: [Post])
    func saveCurrentUserInCoreData(for entity: CurrentUser.Type, user: User)
    func fetchFeed(for entity: Feed.Type) -> [Post]
    func fetchCurrentUser(for entity: CurrentUser.Type) -> [User]
    func deleteAllObjects(objects: [Feed])
    func deleteCurrentUser()
}

final class CoreDataManager: CoreDataProtocol, CoreDataInstagram {
    
    private let modelName: String
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { (storeDescriprion, error) in
            if let error = error as NSError? {
                fatalError("\(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                print(error.localizedDescription)
            }
        }
    }
    
    func createObject<T: NSManagedObject>(from entity: T.Type) -> T {
        let context = getContext()
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! T
        
        return object
    }
    
    func delete(object: NSManagedObject) {
        let context = getContext()
        context.delete(object)
        save(context: context)
    }
    
    func fetchData<T: NSManagedObject>(for entity: T.Type) -> [T] {
        let context = getContext()
        let request: NSFetchRequest<T>
        var fetchedResult = [T]()
        
        if #available(iOS 10.0, *) {
            request = entity.fetchRequest() as! NSFetchRequest<T>
        } else {
            let entityName = String(describing: entity)
            request = NSFetchRequest(entityName: entityName)
        }
        
        do {
            fetchedResult = try context.fetch(request)
        } catch {
            debugPrint("Could not fetch \(error.localizedDescription)")
        }
        
        return fetchedResult
    }
    
    func saveFeedInCoreData(for entity: Feed.Type, posts: [Post]) {
        
        let context = getContext()
        
        posts.forEach {
            let feed = createObject(from: entity)
            
            feed.likedByCount = Int16($0.likedByCount)
            feed.image = createImageData(from: $0.image)
            feed.id = $0.id
            feed.descrip = $0.description
            feed.currentUserlikesThisPost = $0.currentUserLikesThisPost
            feed.createdTime = $0.createdTime
            feed.authorUserName = $0.authorUsername
            feed.authorAvatar = createImageData(from: $0.authorAvatar)
            feed.author = $0.author
            
            save(context: context)
        }
    }
    
    func saveCurrentUserInCoreData(for entity: CurrentUser.Type, user: User) {
        
        let context = getContext()
        let currentUser = createObject(from: entity)
        
        currentUser.userName = user.username
        currentUser.id = user.id
        currentUser.fullName = user.fullName
        currentUser.followsCount = Int16(user.followsCount)
        currentUser.followedByCount = Int16(user.followedByCount)
        currentUser.avatar = createImageData(from: user.avatar)
        currentUser.currentUserFollowsThisUser = user.currentUserFollowsThisUser
        currentUser.currentUserIsFollowedByThisUser = user.currentUserIsFollowedByThisUser
        
        save(context: context)
    }
    
    func fetchFeed(for entity: Feed.Type) -> [Post] {
        let feedArray = fetchData(for: entity)
        
        return convertFromFeedToPost(feed: feedArray)
    }
    
    func fetchCurrentUser(for entity: CurrentUser.Type) -> [User] {
        
        let user = fetchData(for: entity)
        
        return convertFromCurrentUserToUser(users: user)
    }
    
    func deleteAllObjects(objects: [Feed]) {
        objects.forEach {
            delete(object: $0)
        }
    }
    
    func deleteCurrentUser() {
        if let user = fetchData(for: CurrentUser.self).first {
            delete(object: user)
        }
    }
    
    private func convertFromFeedToPost(feed: [Feed]) -> [Post] {
        
        var posts = [Post]()
        
        feed.forEach {
            let post = Post(id: $0.id ?? "",
                            description: $0.descrip ?? "" ,
                            image: "",
                            imageData: $0.image ?? Data(),
                            createdTime: $0.createdTime ?? Date(),
                            currentUserLikesThisPost: $0.currentUserlikesThisPost,
                            likedByCount: Int($0.likedByCount),
                            author: $0.author ?? "",
                            authorUsername: $0.authorUserName ?? "",
                            authorAvatar: "",
                            authorAvatarData: $0.authorAvatar ?? Data())
            
            posts.append(post)
        }
        
        return posts
    }
    
    private func convertFromCurrentUserToUser(users: [CurrentUser]) -> [User] {
        
        var usersArray = [User]()
        
        users.forEach({
            let user = User(id: $0.id ?? "",
                            username: $0.userName ?? "",
                            fullName: $0.fullName ?? "",
                            avatar: "",
                            avatarData: $0.avatar ?? Data(),
                            currentUserFollowsThisUser: $0.currentUserFollowsThisUser,
                            currentUserIsFollowedByThisUser: $0.currentUserIsFollowedByThisUser,
                            followsCount: Int($0.followsCount),
                            followedByCount: Int($0.followedByCount))
            
            usersArray.append(user)
        })
        
        return usersArray
    }
    
    private func createImageData(from url: String) -> Data {
        
        guard let url = URL(string: url),
              let imageData = try? Data(contentsOf: url) else { return Data() }
        
        return imageData
    }
}
