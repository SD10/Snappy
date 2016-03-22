//
//  ViewController.swift
//  Snappy
//
//  Created by Steven on 3/7/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AVFoundation

protocol LoginViewControllerDelegate {
    func didLoginSuccessfully()
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var loginBackground: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    var delegate: LoginViewControllerDelegate?
    var player = AVAudioPlayer()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set UITextField Delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //Format UIElements
        setInitialAlphas()
        formatButton(loginButton)
        formatButton(facebookButton)
        formatButton(signupButton)
        
        prepareCameraSound()
        let _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "flashEffect", userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fadeInItems()
    }
    
    // MARK: - UI Formatting
    
    // Formats the visual appearance of UIButton
    func formatButton(button: UIButton) {
        button.layer.cornerRadius = 12.0
    }
    
    // Set initial alpha values of UIElements
    func setInitialAlphas() {
        loginButton.alpha = 0
        signupButton.alpha = 0
        facebookButton.alpha = 0
        emailTextField.alpha = 0
        passwordTextField.alpha = 0
        loginBackground.alpha = 0.72
    }
    
    // MARK: - Login In / Sign Up
    
    // Create and Display Error Alert
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkTextFields() -> Bool {
        if !emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty {
            return true
        } else {
            showErrorAlert("Empty text field", message: "Please fill out all fields to continue")
            return false
        }
    }
    
    func logUserIn() {
        if checkTextFields() {
            DataService.dataService.REF_USERS.authUser(emailTextField.text!, password: passwordTextField.text!, withCompletionBlock: { error, authData in
                if error != nil {
                    switch error.code {
                    case STATUS_EMAIL_INVALID:
                        self.showErrorAlert("Invalid Email", message: "Please enter a valid email")
                    case STATUS_ACCOUNT_NONEXIST:
                        self.showErrorAlert("Email or Password Invalid", message: "Please enter a valid email and password")
                    default: break
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                }
            })
        }
    }

    // Sign in with Facebook
    @IBAction func facebookPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: nil) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
                DataService.dataService.REF_USERS.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged In! \(authData)")
                        //FIXME: - Fix force unwrap provider
                        let user = ["provider": authData.provider!, "displayName": authData.providerData["displayName"]!, "email": authData.providerData["email"]!, "profileImage": authData.providerData["profileImageURL"]!]
                        DataService.dataService.createFirebaseUser(authData.uid, user: user)
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.delegate?.didLoginSuccessfully()
                    }
                })
            }
        }
    }
    
    // Email-Password Login Attempt
    @IBAction func attemptLogin(sender: UIButton) {
        logUserIn()
        self.delegate?.didLoginSuccessfully()
    }
    
    
    // Sign Up for New Account
    @IBAction func attemptSignUp(sender: UIButton) {
        if checkTextFields() {
            DataService.dataService.REF_USERS.createUser(emailTextField.text!, password: passwordTextField.text!, withValueCompletionBlock: { error, result in
                if error != nil {
                    self.showErrorAlert("Could not create account", message: "Try something else?")
                } else {
                    self.logUserIn()
                    let result = result as! [String: String]
                    let user = ["provider": "password", "email": "\(self.emailTextField.text!)", "password": "\(self.passwordTextField.text!)"]
                    DataService.dataService.createFirebaseUser(result["uid"]!, user: user)
                    self.performSegueWithIdentifier("addInformation", sender: nil)
                }
            })
        }
    }

    
    // MARK: - Keyboard Management
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Animations
    
    // Animation - Fade in UIElements
    func fadeInItems() {
        LoginTextField.animateWithDuration(2) { () -> Void in
            self.emailTextField.alpha = 1.0
            self.passwordTextField.alpha = 1.0
        }
        UIButton.animateWithDuration(2) { () -> Void in
            self.loginButton.alpha = 1.0
            self.facebookButton.alpha = 1.0
            self.signupButton.alpha = 1.0
        }
    }
    
    // Animation - Flash Effect
    func flashEffect() {
        let aView = UIView(frame: self.view.frame)
        aView.backgroundColor = UIColor.whiteColor()
        aView.alpha = 1.0
        self.loginBackground.alpha = 1.0
        self.loginBackground.addSubview(aView)
        
        UIView.animateWithDuration(1.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            aView.alpha = 0.0
            self.player.play()
            self.loginBackground.alpha = 0.72
            
            }, completion: { (done) -> Void in
                aView.removeFromSuperview()
        })
    }
    
    // MARK: - Sound Effects
    func prepareCameraSound() {
        let audioPath = NSBundle.mainBundle().pathForResource("cameraShutter", ofType: "wav")!
        
        do {
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
}
