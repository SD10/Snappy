//
//  MasterViewController.swift
//  Snappy
//
//  This is the main view controller, it displays the camera user interface.
//
//  Created by Steven on 2/24/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit
import AVFoundation

class MasterViewController: UIViewController, LoginViewControllerDelegate {
    
    @IBOutlet var previewView: UIView!
    
    var cameraSession: CameraSession!
    var capturedImage: UIImage?
    var imageView: UIImageView!
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var inboxButton: UIButton!
    @IBOutlet weak var friendsListButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.hidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraSession = CameraSession()
        
        imageView = UIImageView()
        imageView.bounds = previewView.bounds
        previewView.addSubview(imageView)
        
        cameraSession.previewLayer.frame = previewView.bounds
        previewView.layer.insertSublayer(cameraSession.previewLayer, atIndex: 0)
        
        cameraSession.startRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Check if user is already logged in, if so, proceed
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) == nil {
            performSegueWithIdentifier("presentLogin", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didPressFlipCamera(sender: UIButton) {
        let position = cameraSession.device.position
        var newDevice: CameraDevice?
        
        switch position {
        case .Front: newDevice = CameraDevice(position: .Back)
        case .Back: newDevice = CameraDevice(position: .Front)
        default: newDevice = nil
        }
        
        if newDevice != nil {
            cameraSession.updateCameraDevice(to: newDevice!)
        }
    }
    
    @IBAction func didPressCancelEdit(sender: UIButton) {
 
    }

    
    @IBAction func didPressCapturePhoto(sender: AnyObject) {
        capturedImage = cameraSession.captureImage()
        if capturedImage != nil {
            print("Image capture successful! :D :D :D")
            imageView.image = capturedImage
            imageView.hidden = false
            cameraSession.previewLayer.hidden = true
        }
    }
    
    
    // Did Login Successfully
    func didLoginSuccessfully() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentLogin" {
            let loginViewController = segue.destinationViewController as! LoginViewController
            loginViewController.delegate = self
        }
    }
}

