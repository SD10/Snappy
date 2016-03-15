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
        
        // Prepare Camera Sound Effect
        let audioPath = NSBundle.mainBundle().pathForResource("cameraShutter", ofType: "wav")!
        
        do {
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
        } catch let error as NSError {
            print(error.debugDescription)
        }
        
        //Set UITextField Delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //Format UIElements
        loginBackground.alpha = 0.72
        setAlphaZero()
        formatButton(loginButton)
        formatButton(facebookButton)
        formatButton(signupButton)
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
    
    // Set Alpha of UIElements to zero
    func setAlphaZero() {
        loginButton.alpha = 0
        signupButton.alpha = 0
        facebookButton.alpha = 0
        emailTextField.alpha = 0
        passwordTextField.alpha = 0
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
    
    // MARK: - Login In / Sign Up

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
                        /* This is very bad but would need more error handling to avoid this force unwrap.
                             Create a firebase user */
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
        if let email = emailTextField.text where email != "", let pwd = passwordTextField.text where pwd != "" {
            DataService.dataService.REF_USERS.authUser(email, password: pwd, withCompletionBlock: { error, authData in
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
                    self.delegate?.didLoginSuccessfully()
                }
            })
        } else {
            showErrorAlert("Email and Password Required", message: "Please enter a valid email and password to continue")
        }
    }
    
    // Sign Up for New Account
    @IBAction func attemptSignUp(sender: UIButton) {
        if let email = emailTextField.text where email != "", let pwd = passwordTextField.text where pwd != "" {
            
            // Account aready exists, then log them in
            DataService.dataService.REF_USERS.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
                    switch error.code {
                        //Handle Invalid Email
                        case STATUS_EMAIL_INVALID:
                            self.showErrorAlert("Invalid Email", message: "Please enter a valid email to sign up")
                        case STATUS_ACCOUNT_NONEXIST:
                            DataService.dataService.REF_USERS.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                                if error != nil {
                                    self.showErrorAlert("Could not create account", message: "Try something else?")
                                } else {
                                    // Log In User After Creating Account
                                    NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                    DataService.dataService.REF_USERS.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                                        let user = ["provider": authData.provider!, "password": "\(pwd)", "email": "\(email)"]
                                        DataService.dataService.createFirebaseUser(authData.uid, user: user)
                                        self.performSegueWithIdentifier("addInformation", sender: nil)
                                    })
                                }
                            })
                        default: break
                    }
                } else {
                    // No error so log the user in
                    self.delegate?.didLoginSuccessfully()
                }
            })
        }
    }
    
    // Create and Display Error Alert
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
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
