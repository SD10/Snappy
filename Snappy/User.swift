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
    private var _displayName: String?
    private var _profileImageURL: String?
    
    var userID: String {
        return _userID
    }
    
    var provider: String {
        return _provider
    }
    
    var email: String? {
        return _email
    }
    
    var displayName: String? {
        return _displayName
    }
    
    var profileImageURL: String? {
        return _profileImageURL
    }
    
    init(userID: String, dictionary: [String: AnyObject]) {
        self._userID = userID
        if let provider = dictionary["provider"] as? String {
            self._provider = provider
        }
        
        if let email = dictionary["email"] as? String {
            self._email = email
        }
        
        if let name = dictionary["displayName"] as? String {
            self._displayName = name
        }
        
        if let imageURL = dictionary["profileImageURL"] as? String {
            self._profileImageURL = imageURL
        }
    }
    
}