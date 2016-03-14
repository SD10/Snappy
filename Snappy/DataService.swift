//
//  DataService.swift
//  Snappy
//
//  Created by Steven on 3/8/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://snappy-data.firebaseio.com"
let uID = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String

class DataService {
    static let dataService = DataService()
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_USERS = Firebase(url:"\(URL_BASE)/users")
    private var _REF_USER = Firebase(url:"\(URL_BASE)/users/")
    private var _REF_MSGS = Firebase(url: "\(URL_BASE)/messages")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_MSGS: Firebase {
        return _REF_MSGS
    }
    
    var REF_USER: Firebase {
        return _REF_USER
    }
    
    
    func createFirebaseUser(uid: String, user: [String: AnyObject]) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
    func updateFirebaseUser(uid: String, user: [String: AnyObject]) {
        REF_USER.childByAppendingPath(uid).updateChildValues(user)
    }
    
    func addFirebaseFriend(uid: String, friend: [String: Bool]) {
        REF_USER.childByAppendingPath(uid + "/friends").updateChildValues(friend)
    }
}