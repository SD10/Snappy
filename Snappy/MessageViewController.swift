//
//  MessageViewController.swift
//  Snappy
//
//  Created by Steven on 3/17/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var selectedImage: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = image {
            selectedImage.image = image
        } else {
            selectedImage.image = UIImage(named: "imagesplaceholder.png")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageViewController.handleKeyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // FIXME: - Works but looks terrible...
    func handleKeyboardDidShow(notification: NSNotification) {
        // Get the frame of the keyboard
        let keyboardRectAsObject = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        // Place it in a CGRect
        var keyboardRect = CGRectZero
        keyboardRectAsObject.getValue(&keyboardRect)
        //Give a bottom margin to our text field that makes it reach to the top of the keyboard
        inputTextField.center.x = view.center.x
        inputTextField.frame.size = CGSize(width: view.frame.size.width, height: 40.0)
        inputTextField.center.y = keyboardRect.height + 138
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func onCancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onSendPressed(sender: AnyObject) {
        if !inputTextField.text!.isEmpty {
            let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
            DataService.dataService.REF_BASE.childByAppendingPath("messages").childByAutoId().setValue(["message": inputTextField.text!, "sender": uid, "receiver": "receiverUID"])
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enter a message to send", preferredStyle: .Alert)
            let actionOk = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(actionOk)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

}
