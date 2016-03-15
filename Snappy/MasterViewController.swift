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
        imageView.center = previewView.center
        previewView.insertSubview(imageView, atIndex: 0)
        hideEditInterface(true)
        
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
        hideCaptureInterface(false)
        hideEditInterface(true)
    }

    
    @IBAction func didPressCapturePhoto(sender: AnyObject) {
        cameraSession.captureImage( {
                (let image) in
            self.imageView.image = image
            self.hideCaptureInterface(true)
            self.hideEditInterface(false)
            } )
    }
    
    func hideCaptureInterface(hidden: Bool) {
        captureButton.hidden = hidden
        inboxButton.hidden = hidden
        friendsListButton.hidden = hidden
        flipButton.hidden = hidden
        cameraSession.previewLayer.hidden = hidden
    }
    
    func hideEditInterface(hidden: Bool) {
        cancelButton.hidden = hidden
        imageView.hidden = hidden
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

