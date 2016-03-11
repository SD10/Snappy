//
//  FriendsListViewController.swift
//  Snappy
//
//  Created by Steven on 3/9/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit
import Firebase

class FriendsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var testUsers = [User]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    // Set tableview delegate and datasource
    tableView.delegate = self
    tableView.dataSource = self
        
        DataService.dataService.REF_USERS.observeEventType(.Value, withBlock: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.testUsers.removeAll()
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let userDict = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let user = User(userID: key, dictionary: userDict)
                        self.testUsers.append(user)
                    }
                }
            }
            
            self.tableView.reloadData()
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as? UserCell {
            let user = testUsers[indexPath.row]
            cell.username.text = user.email
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            testUsers.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Friends"
    }
    

    @IBAction func cameraButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
