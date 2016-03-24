//
//  MasterViewController.swift
//  Snappy
//
//  This is the main view controller, it displays the camera user-interface.
//
//  Created by Steven on 2/24/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import UIKit
import AVFoundation

class MasterViewController: UIViewController, LoginViewControllerDelegate {
    
    @IBOutlet var previewView: UIView!
    
    @IBOutlet var tapToFocus: UITapGestureRecognizer!
    var cameraSession: CameraSession!
    var capturedImage: UIImage?
    var imageView: UIImageView!
    
    // interface buttons //
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
        
        // initialing my custom camera interface //
        cameraSession = CameraSession()
        
        // initializing the image and preview views //
        imageView = UIImageView()
        imageView.frame = previewView.bounds
        imageView.center = previewView.center
        imageView.contentMode = .ScaleAspectFill
        previewView.addSubview(imageView)
        previewView.sendSubviewToBack(imageView)
        hideEditInterface(true)
        
        cameraSession.previewLayer.frame = previewView.frame
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
    
    // switches the input device in the camera session from front/back //
    // and vise-versa                                                  //
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
    
    // exits the edit interface, back to capture interface //
    @IBAction func didPressCancelEdit(sender: UIButton) {
        hideCaptureInterface(false)
        hideEditInterface(true)
    }

    // captures a photo, and enters edit interface //
    @IBAction func didPressCapturePhoto(sender: AnyObject) {
        cameraSession.captureImage( {
                (let image) in
            self.imageView.image = image
            self.hideCaptureInterface(true)
            self.hideEditInterface(false)
            } )
    }
    
    // will focus the camera at the point the user taps //
    @IBAction func tapToFocusCamera(sender: UITapGestureRecognizer) {
        // a bit redundant, refactor later //
        let currentDevice = cameraSession.device.device
        
        // FIX: the trashcan of dead kittens //
        do {
            try currentDevice!.lockForConfiguration()
            if currentDevice!.focusPointOfInterestSupported && currentDevice!.isFocusModeSupported(.AutoFocus) {
                currentDevice!.focusMode = .AutoFocus
                let focalPoint = cameraSession.previewLayer.captureDevicePointOfInterestForPoint(tapToFocus.locationInView(previewView))
                currentDevice!.focusPointOfInterest = focalPoint
                print(focalPoint)
            }
            currentDevice!.unlockForConfiguration()
        } catch {
            print("Error: did not obtain lock for device configuration.")
        }
    }

    
    // reveals/hides capture buttons //
    func hideCaptureInterface(hidden: Bool) {
        captureButton.hidden = hidden
        inboxButton.hidden = hidden
        friendsListButton.hidden = hidden
        flipButton.hidden = hidden
        cameraSession.previewLayer.hidden = hidden
    }
    
    // reveals/hides edit buttons //
    func hideEditInterface(hidden: Bool) {
        cancelButton.hidden = hidden
        imageView.hidden = hidden
    }
    
    
    // did Login Successfully //
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

