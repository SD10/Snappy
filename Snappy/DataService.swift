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
class DataService {
    static let dataService = DataService()
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_USERS = Firebase(url:"\(URL_BASE)/users")
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
    
    func createFirebaseUser(uid: String, user: [String:String]) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
}