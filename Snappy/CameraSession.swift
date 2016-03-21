//
//  CameraSession.swift
//  Snappy
//
//  MY CUSTOM CAMERA SESSION
//
//  Created by Misha on 3/11/16.
//  Copyright © 2016 SwiftSyndicate. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraSession {
    
    var device: CameraDevice
    let captureSession: AVCaptureSession
    let stillImageOutput: AVCaptureStillImageOutput
    let previewLayer: AVCaptureVideoPreviewLayer
    
    // defaults to back-camera, jpeg, still photo presets //
    init() {
        // device: default back-camera //
        device = CameraDevice(position: .Back)
        
        // captureSession //
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        if captureSession.canAddInput(device.input) {
            captureSession.addInput(device.input)
        }
        
        // stillImageOutput //
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        // previewLayer //
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
    // begins running the capture session in a separate thread //
    func startRunning() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.captureSession.startRunning()
        }
    }
    
    // captures a UIImage //
    func captureImage(completion: ((UIImage?) -> ()) ) {
        
        let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
            (let buffer, let error) in
            if error != nil {
                print("Error occured when capturing image: \(error)")
            } else {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                let image = UIImage(data: imageData)
                completion(image)
                print("Image captured successfully!")
            }
        }
    }
    
    // updates the camera session device, and swaps capture session input //
    func updateCameraDevice(to newDevice: CameraDevice) {
        if captureSession.canAddInput(newDevice.input) {
            captureSession.beginConfiguration()
            captureSession.removeInput(device.input)
            captureSession.addInput(newDevice.input)
            captureSession.commitConfiguration()
            self.device = newDevice
        }
    }
}

// puts together AVCaptureDevice and AVCaptureDeviceInput classes for convinience //
struct CameraDevice {
    var device: AVCaptureDevice?
    let input: AVCaptureDeviceInput?
    let position: AVCaptureDevicePosition

    init(position: AVCaptureDevicePosition) {
        self.position = position
        self.device = nil
        
        // finds available device of proper position //
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        for device in devices {
            if device.position == position {
                self.device = device
            }
        }
        
        if device != nil {
            do {
                self.input = try AVCaptureDeviceInput(device: device)
            } catch {
                self.input = nil
                print("Error: occured when creating input from device.")
            }
        } else {
            self.input = nil
        }
    }
    
}
