//
//  User.swift
//  Snappy
//
//  Created by Steven on 3/10/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import Foundation

class User {
    private var _userID: String!
    private var _provider: String!
    private var _email: String?
    
    var userID: String {
        return _userID
    }
    
    var provider: String {
        return _provider
    }
    
    var email: String? {
        return _email
    }
    
    init(userID: String, dictionary: [String: AnyObject]) {
        self._userID = userID
        if let provider = dictionary["provider"] as? String {
            self._provider = provider
        }
        
        if let email = dictionary["email"] as? String {
            self._email = email
        }
    }
    
}