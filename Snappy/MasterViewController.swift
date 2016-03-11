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
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCaptureStillImageOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!           // the video preview, subLayers previewView
    var capturedImage: UIImage!
    var currentCaptureDevice: AVCaptureDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO BE REFACTORED
        
        // Creating and initializing the capture session w/ photo preset
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Creating input devices for the front and back cameras
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        currentCaptureDevice = backCamera
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
            print("Assigned back camera input device.")
        } catch {
            print("Error: occured when assigning input device.")
        }
        
        // Specifying output as type JPEG
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)
        
        // Begins capture session on separate thread of high priority
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.captureSession.startRunning()
        }
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
    
    override func viewDidLayoutSubviews() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        // sets the preview to fill entire layer
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame = previewView.bounds
        previewView.layer.insertSublayer(previewLayer, atIndex: 0)
    }
    
    @IBAction func didPressFlipCamera(sender: UIButton) {
        var newDevice: AVCaptureDevice = currentCaptureDevice
        
        if currentCaptureDevice.position == .Back {
            // front camera device
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            for device in devices {
                if device.position == .Front {
                    newDevice = device as! AVCaptureDevice
                    currentCaptureDevice = newDevice
                }
            }
        } else if currentCaptureDevice.position == .Front {
            // back camera device
            newDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            currentCaptureDevice = newDevice
        }
        
        do {
            let newInput = try AVCaptureDeviceInput(device: newDevice)
            // FIX, FIX, FIX!!!
            let currentInput = captureSession.inputs[0] as! AVCaptureInput
            
            captureSession.beginConfiguration()
            captureSession.removeInput(currentInput)
            captureSession.addInput(newInput)
            captureSession.commitConfiguration()
            
            print("Successfully flipped the cameara!")
        } catch {
            print("Error: occured when assigning input device in flip camera.")
        }
    }
    
    @IBAction func didPressCapturePhoto(sender: AnyObject) {
        let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
            (let buffer, let error) in
            if error != nil {
                print("Error occured when capturing image: \(error)")
            } else {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                self.capturedImage = UIImage(data: imageData)
                UIImageWriteToSavedPhotosAlbum(self.capturedImage, nil, nil, nil)
                print("Image capture success!")
            }
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

