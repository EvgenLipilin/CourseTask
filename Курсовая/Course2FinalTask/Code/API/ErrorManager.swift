//
//  ErrorManager.swift
//  Course2FinalTask
//
//  Created by Евгений on 19.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation

enum ErrorManager: String, Error {
    case badRequest = "Bad request"
    case unauthorized = "Unauthorized"
    case notFound = "Not found"
    case notAcceptable = "Not acceptable"
    case unprocessable = "Unprocessable"
    case transferError = "Transfer error"
}
