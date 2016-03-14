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
    var isDeleteEnabled = true
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
    // Set tableview delegate and datasource
    tableView.delegate = self
    tableView.dataSource = self
        
        /* Retrieve users friends
        DataService.dataService.REF_USER.childByAppendingPath("friends").observeEventType(.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.friendList.removeAll()
                var usersToUpdate = [User]()
                for snap in snapshots {
                    DataService.dataService.REF_USERS.childByAppendingPath(snap.key).observeEventType(.Value, withBlock: { snapshotUser in
                        if let userDict = snapshotUser.value as? [String: AnyObject] {
                            let key = snapshotUser.key
                            let user = User(userID: key, dictionary: userDict)
                            usersToUpdate.append(user)
                            usersToUpdate.removeAtIndex(0)
                        }
                        self.friendList += usersToUpdate
                        self.tableView.reloadData()
                    })
                    
                }
                
            }
        }) */

        /* Retrieve data from Firebase
        DataService.dataService.REF_USERS.observeEventType(.Value, withBlock: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.testUsers.removeAll()
                for snap in snapshots {
                    //print("SNAP: \(snap)")
                    
                    if let userDict = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let user = User(userID: key, dictionary: userDict)
                        self.testUsers.append(user)
                    }
                }
            }
            
            self.tableView.reloadData()
        })*/
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
    
    
    // Allow rows to be deleted by dragging left
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            friendList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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
                    print(snapshot.key)
                    DataService.dataService.addFirebaseFriend(["\(snapshot.key)": true])
                })
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)

    }

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
