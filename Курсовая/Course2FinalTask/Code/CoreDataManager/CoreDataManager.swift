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

