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

class LoginViewController: UIViewController {
    
    // Initial commit

    @IBOutlet weak var loginBackground: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Format UIElements
        loginBackground.alpha = 0.72
        setAlphaZero()
        formatTextField(emailTextField)
        formatTextField(passwordTextField)
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
        
        // Check if user is already logged in, if so, proceed
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier("loggedIn", sender: self)
        }
    }
    
    // Formats the visual appearance of UITextField, refactor for MVC later
    func formatTextField(textField: UITextField) {
        let boneColor = UIColor(red: 255.0/255.0, green: 251.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        textField.borderStyle = .RoundedRect
        textField.clearButtonMode = .WhileEditing
        textField.textColor = boneColor
        textField.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        textField.layer.borderColor = boneColor.CGColor
        textField.layer.borderWidth = 2.0
        textField.layer.cornerRadius = 8.0
        textField.attributedPlaceholder = NSAttributedString(string: "\(textField.placeholder!)", attributes: [NSForegroundColorAttributeName: boneColor])
    }
    
    // Formats the visual appearance of UIButton, refactor for MVC later
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
    
    // Animation - Fade in UIElements
    func fadeInItems() {
        UITextField.animateWithDuration(2) { () -> Void in
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
            self.loginBackground.alpha = 0.72

            }, completion: { (done) -> Void in
                aView.removeFromSuperview()
        })
    }
    
    
    // Sign in with Facebook
    @IBAction func facebookPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: nil) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
                DataService.dataService.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged In! \(authData)")
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier("loggedIn", sender: nil)
                    }
                })
            }
        }
    }
    
    // Email-Password Login Attempt
    @IBAction func attemptLogin(sender: UIButton) {
        if let email = emailTextField.text where email != "", let pwd = passwordTextField.text where pwd != "" {
            
            DataService.dataService.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
                    print(error)
                    
                    // Handle Invalid Email
                    if error.code == STATUS_EMAIL_INVALID {
                        self.showErrorAlert("Invalid Email", message: "Please enter a valid email")
                    } else if error.code == STATUS_ACCOUNT_NONEXIST {
                        self.showErrorAlert("Email or Password Invalid", message: "Please enter a valid email and password")
                    }
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", message: "Please enter a valid email and password to continue")
        }
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Sign Up for New Account
    @IBAction func attemptSignUp(sender: UIButton) {
        if let email = emailTextField.text where email != "", let pwd = passwordTextField.text where pwd != "" {
            
            
            // Account aready exists, then log them in
            DataService.dataService.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
                    print(error)
                    
                    //Handle Invalid Email
                    if error.code == STATUS_EMAIL_INVALID {
                        self.showErrorAlert("Invalid Email", message: "Please enter a valid email to sign up")
                    // Account doesn't exist, create account
                    } else if error.code == STATUS_ACCOUNT_NONEXIST {
                        DataService.dataService.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            if error != nil {
                                print(error)
                                self.showErrorAlert("Could not create account", message: "Try something else?")
                            } else {
                                // Log In User After Creating Account
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                DataService.dataService.REF_BASE.authUser(email, password: pwd, withCompletionBlock: nil)
                                self.performSegueWithIdentifier("loggedIn", sender: nil)
                            }
                        })
                    }
                } else {
                    // No error so log the user in
                    self.performSegueWithIdentifier("loggedIn", sender: nil)
                }
            })
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
