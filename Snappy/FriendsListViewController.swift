//
//  FriendsListViewController.swift
//  Snappy
//
//  Created by Steven on 3/9/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class FriendsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var friendList = [User]()
    var friendsIDs = [String]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
    // Set tableview delegate and datasource
    tableView.delegate = self
    tableView.dataSource = self
        
        //Get users friends
        let uID = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as! String
        DataService.dataService.REF_USERS.childByAppendingPath("\(uID)/friends").observeEventType(.Value, withBlock: { friends in
            if let retrievedFriends = friends.children.allObjects as? [FDataSnapshot] {
                self.friendsIDs.removeAll()
                self.friendList.removeAll()
                for friend in retrievedFriends {
                    self.friendsIDs.append(friend.key)
                }
                
                for uID in self.friendsIDs {
                    DataService.dataService.REF_USERS.childByAppendingPath(uID).observeEventType(.Value, withBlock: { snapshot in
                        if let userDict = snapshot.value as? [String: AnyObject] {
                            let key = snapshot.key
                            let user = User(userID: key, dictionary: userDict)
                            self.friendList.append(user)
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Number of sections in tableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows in tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    // Add data to TableView Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as? UserCell {
            
            let user = friendList[indexPath.row]
            
            // If displayName exists use that for label, if not use email
            if let username = user.displayName {
                cell.username.text = username
            } else if let email = user.email {
                cell.username.text = email
            }
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    // Give the section a header of "Friends"
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Friends"
    }
    
    // MARK: - Navigation
    
    // Go back to Camera
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Add a friend
    @IBAction func addFriend(sender: AnyObject) {
        let alert = UIAlertController(title: "Add a Friend", message: "Who do you want to add?", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = "Enter a user's email..."
            
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(paramAction: UIAlertAction) -> Void in
            if let textFields = alert.textFields {
                let theTextFields = textFields as [UITextField]
                let userEmail = theTextFields[0].text
                DataService.dataService.REF_USERS.queryOrderedByChild("email").queryEqualToValue(userEmail).observeEventType(.ChildAdded, withBlock: { snapshot in
                    let uID = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
                    DataService.dataService.addFirebaseFriend(uID!, friend: ["\(snapshot.key)": true])
                    DataService.dataService.addFirebaseFriend("\(snapshot.key)", friend: [uID!: true])
                })
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)

    }
}
