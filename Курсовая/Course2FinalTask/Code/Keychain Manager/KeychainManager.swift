//
//  KeychainManager.swift
//  Course2FinalTask
//
//  Created by Евгений Липилин on 05.05.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

protocol KeychainProtocol {
    func saveToken(token: String, userName: String)
    func readToken(userName: String) -> String?
    func deleteToken(userName: String)
}

final class KeychainManager: KeychainProtocol {
    
    // MARK: - Private Methods
    private func keychainQuery(userName: String? = nil) -> [String : AnyObject] {
        
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        
        if let userName = userName {
            query[kSecAttrAccount as String] = userName as AnyObject
        }
        return query
    }
    
    // MARK: - Public Methods
    func saveToken(token: String, userName: String) {
        
        let tokenData = token.data(using: .utf8)
        
        if readToken(userName: userName) != nil {
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = tokenData as AnyObject
            
            let query = keychainQuery(userName: userName)
            let _ = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        }
        
        var item = keychainQuery(userName: userName)
        item[kSecValueData as String] = tokenData as AnyObject
        let _ = SecItemAdd(item as CFDictionary, nil)
    }
    
    func readToken(userName: String) -> String? {
        
        var query = keychainQuery(userName: userName)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(&queryResult))
        if status != noErr {
            return nil
        }
        
        guard let item = queryResult as? [String : AnyObject],
              let tokenData = item[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    func deleteToken(userName: String) {
        let item = keychainQuery(userName: userName)
        let _ = SecItemDelete(item as CFDictionary)
    }
}
