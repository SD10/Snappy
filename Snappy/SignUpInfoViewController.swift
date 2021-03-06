//
//  SignUpInfoViewController.swift
//  Snappy
//
//  Created by Steven on 3/11/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit
import Foundation

class SignUpInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var penguinImage: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    var animationsPlayed = 0
    
    var imagePicker: UIImagePickerController!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set imagePicker delegates
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // Set textField delegate
        usernameField.delegate = self
        usernameField.clearButtonMode = .Always
        
        // Round selectedImage into circle
        selectedImage.layer.cornerRadius = selectedImage.frame.size.width / 2.0
        selectedImage.clipsToBounds = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Play animation
        if animationsPlayed >= 1 {
            playAnimationTwo()
        } else {
            playAnimationOne()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Animations
    
    // Initial animation when view appears
    func playAnimationOne() {
        var imageArray = [UIImage]()
        
        for x in 1...4 {
            let image = UIImage(named: "penguin\(x)")
            imageArray.append(image!)
        }
        penguinImage.animationImages = imageArray
        penguinImage.animationDuration = 0.7
        penguinImage.animationRepeatCount = 1
        penguinImage.startAnimating()
        self.animationsPlayed += 1
        
        let _ = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(SignUpInfoViewController.updateMessageLabel), userInfo: nil, repeats: false)
    }
    
    // Animation after
    func playAnimationTwo() {
        var imageArray = [UIImage]()
        
        for x in 5...7 {
            let image = UIImage(named: "penguin\(x)")
            imageArray.append(image!)
        }
        
        penguinImage.animationImages = imageArray
        penguinImage.animationDuration = 0.7
        penguinImage.animationRepeatCount = 1
        penguinImage.startAnimating()
        
        let _ = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(SignUpInfoViewController.updateMessageLabelTwo), userInfo: nil, repeats: false)
    }
    
    // MARK: - UILabel Formatting
    
    // Display label after first animation ends
    func updateMessageLabel() {
        self.messageLabel.text = "Hey! Let us know a bit more about you..."
    }
    
    // Generate random message for label after second animation ends
    func updateMessageLabelTwo() {

        let messages = ["WHOA! Bad hair day!", "Looking good! \nWhat's your name?", "You almost look \nas good as me!"]
        func getRandomMessage() -> String {
            let randomNumber = Int(arc4random_uniform(UInt32(messages.count)))
            return messages[randomNumber]
        }
        self.messageLabel.text = getRandomMessage()
    }
    
    // Display characters remaining
    func calculateAndDisplayRemainingCharacters(text: String) {
        
        // If only one character remaining, add an "s"
        var characterOrCharacters = "Character"
        if text.characters.count != 19 {
            characterOrCharacters += "s"
        }
        let stringLength = text.characters.count
        
        if 20 - stringLength <= 0 {
            characterCountLabel.text = "No Characters Remain"
        } else {
            characterCountLabel.text = "\(20 - stringLength) \(characterOrCharacters) Remaining"
        }
    }
    
    // Called when textfield is being changed
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let wholeText = text.stringByReplacingCharactersInRange(range, withString: string)
        calculateAndDisplayRemainingCharacters(wholeText)
        checkTextFieldLength()
        //checkForInvalidChar()
        return true
    }
    
    // Disable button of textField has more than 20 characters
    func checkTextFieldLength() {
        let buttonStatus = usernameField.text?.characters.count > 20 ? false : true
        finishButton.userInteractionEnabled = buttonStatus
        finishButton.enabled = buttonStatus
    }
    
    /* NOT WORKING
    // Disable textField if invalid characters present
    func checkForInvalidChar() {
        let bannedCharacters = [" ", "@", "_", "!", "#", "$", "%", "^", "&", "*", "(", ")", "-", "+", "=", "[", "]", "\\", "|", "'", "\"", "<", ">", "?", "/", ",", ":", ";", "`", "~"]
        
        if let text = usernameField.text where text != "" {
            for char in bannedCharacters {
                print("starting check")
                let buttonStatus = text.containsString(char)
                if buttonStatus {
                    finishButton.enabled = !buttonStatus
                    finishButton.userInteractionEnabled = !buttonStatus
                    characterCountLabel.text = "Please enter valid characters"
                    view.endEditing(true)
                    return
                } else {
                    finishButton.enabled = true
                    finishButton.userInteractionEnabled = true
                }
            }
        }
    } */

    // MARK: - ImagePicker Management
    
    // ImagePicker Controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        selectedImage.image = image
        self.messageLabel.text = ""
        dismissViewControllerAnimated(true) { () -> Void in
            self.playAnimationTwo()
        }
    }
    
    // Add an image from imagePicker
    @IBAction func addImagePressed(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // Finished button pressed
    @IBAction func finishedButtonPressed(sender: AnyObject) {
        let userID = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as! String
        let userInfo = ["displayName": "\(usernameField.text!)"]
        DataService.dataService.updateFirebaseUser(userID, user: userInfo)
    }

   // MARK: - Keyboard Management
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
}
