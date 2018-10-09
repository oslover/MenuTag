//
//  CameraViewController.swift
//  MenuTag
//
//  Created by John David on 9/10/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class CameraViewController: BaseViewController {
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var device: AVCaptureDevice!
    var imageOutput: AVCaptureStillImageOutput!
    var preview: AVCaptureVideoPreviewLayer!
    
    let cameraQueue = dispatch_queue_create("com.camera.Queue", DISPATCH_QUEUE_SERIAL)
    var currentPosition = AVCaptureDevicePosition.Back

    override func viewDidLoad() {
        super.viewDidLoad()
        startSession()
        showCamera()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showAlarm("Snap your food", timeInterval: 3)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension CameraViewController { //Camera Capturing
    
    func startSession() {
        dispatch_async(cameraQueue) {
            self.createSession()
            self.session?.startRunning()
        }
    }
    
    func stopSession() {
        dispatch_async(cameraQueue) {
            self.session?.stopRunning()
            if self.preview != nil {
                self.preview?.removeFromSuperlayer()
                self.preview = nil
            }
            
            self.session = nil
            self.input = nil
            self.imageOutput = nil
            self.device = nil
        }
    }
    
    private func createSession() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        dispatch_async(dispatch_get_main_queue()) {
            self.createPreview()
            
        }
    }
    
    private func createPreview() {
        device = cameraWithPosition(currentPosition)
        if let device = device where device.hasFlash {
            do {
                try device.lockForConfiguration()
                device.flashMode = .Auto
                device.unlockForConfiguration()
            } catch _ {}
        }
        
        let outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            input = nil
            print("Error: \(error.localizedDescription)")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        imageOutput = AVCaptureStillImageOutput()
        imageOutput.outputSettings = outputSettings
        
        session.addOutput(imageOutput)
        
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = self.view.bounds
        self.view.layer.insertSublayer(preview, atIndex: 0)
        //addSublayer(preview)
    }
    
    private func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] else {
            return nil
        }
        return devices.filter { $0.position == position }.first
    }
    
    func capturePhoto() {
        dispatch_async(cameraQueue) {
            var i = 0
            
            if let device = self.device {
                while device.adjustingWhiteBalance || device.adjustingExposure || device.adjustingFocus {
                    i += 1 // this is strange but we have to do something while we wait
                }
            }
            
            guard let videoConnection: AVCaptureConnection = self.imageOutput.connectionWithMediaType(AVMediaTypeVideo) else {
                return
            }
            
            
            videoConnection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
            self.cameraIcon.enabled = false
            
            self.imageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { buffer, error in
                guard let buffer = buffer, imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer), image = UIImage(data: imageData) else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.cameraIcon.enabled = true
                    })
                    return
                }
                
                let newImage = image.resizeImage(self.view.frame.size.width)
                let pngData = UIImagePNGRepresentation(newImage)

                self.stopSession()

                SVProgressHUD.show()
                Manager.uploadImageToS3(pngData!, completion: { (response) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { 
                        SVProgressHUD.dismiss()
                        if let imageUrl = response {
                            Manager.sharedInstance.awsImageUrl = imageUrl as! String
                            Manager.sharedInstance.capturedImage = image
                            self.performSegueWithIdentifier("sid_rating", sender: nil)
                        }
                        else {
                            SVProgressHUD.showErrorWithStatus("Uploading Image has failed. Check your network, please.")
                            self.cameraIcon.enabled = true
                        }
                    })
                })
            })
        }
    }
    
    func focusCamera(toPoint: CGPoint) -> Bool {
        
        guard let device = device where device.isFocusModeSupported(.ContinuousAutoFocus) else {
            return false
        }
        
        do { try device.lockForConfiguration() } catch {
            return false
        }
        
        // focus points are in the range of 0...1, not screen pixels
        let focusPoint = CGPoint(x: toPoint.x / self.view.frame.width, y: toPoint.y / self.view.frame.height)
        
        device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
        device.exposurePointOfInterest = focusPoint
        device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
        device.unlockForConfiguration()
        
        return true
    }
    
    func swapCameraInput() {
        guard let session = session, input = input else {
            return
        }
        
        session.beginConfiguration()
        session.removeInput(input)
        
        if input.device.position == AVCaptureDevicePosition.Back {
            currentPosition = AVCaptureDevicePosition.Front
            device = cameraWithPosition(currentPosition)
        } else {
            currentPosition = AVCaptureDevicePosition.Back
            device = cameraWithPosition(currentPosition)
        }
        
        guard let i = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        self.input = i
        
        session.addInput(i)
        session.commitConfiguration()
    }
}

extension CameraViewController { //onCamera Event
    @IBAction func onMap(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func onCamera() {
        self.capturePhoto()
    }
}






