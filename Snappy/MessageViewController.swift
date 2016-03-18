//
//  MessageViewController.swift
//  Snappy
//
//  Created by Steven on 3/17/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    var receiver: User?
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func handleKeyboardDidShow(notification: NSNotification) {
        // Get the frame of the keyboard
        let keyboardRectAsObject = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        // Place it in a CGRect
        var keyboardRect = CGRectZero
        keyboardRectAsObject.getValue(&keyboardRect)
        //Give a bottom margin to our text field that makes it reach to the top of the keyboard
        inputTextField.center.x = view.center.x
        inputTextField.frame.size = CGSize(width: view.frame.size.width, height: 30.0)
        inputTextField.center.y = keyboardRect.height + 138
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func sendMessageButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}
