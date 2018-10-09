//
//  BaseViewController.swift
//  Revur
//
//  Created by John David on 8/26/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
//Alarm bar
    var alarmBar: UIView!
    var alarmLabel: UILabel!
    var alarmBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
    var alarmTextColor = UIColor.whiteColor()
    var alarmText = "" {
        didSet {
            alarmLabel.text = alarmText
        }
    }
    
//CameraIcon
    var cameraIcon: UIButton!
    var vwLine: UIView!
    
//ViewController methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAlarmBar()
        initCamera()
    }
}

extension BaseViewController { //Camera Button
    internal func onCamera() {
        
    }
    
    func initCamera() {
        vwLine = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 4))
        let whiteline = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 2))
        whiteline.backgroundColor = UIColor.whiteColor()
        vwLine.addSubview(whiteline)
        let blackline = UIView(frame: CGRect(x: 0, y: 2, width: 1000, height: 2))
        blackline.backgroundColor = UIColor.blackColor()
        vwLine.addSubview(blackline)
        vwLine.alpha = 0
        self.view.addSubview(vwLine)
            
        cameraIcon = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        cameraIcon.alpha = 0.0
        cameraIcon.setBackgroundImage(UIImage(named: "camera_circle"), forState: .Normal)
        cameraIcon.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - 25)
        cameraIcon.addTarget(self, action: #selector(self.onCamera), forControlEvents: .TouchUpInside)
        self.view.addSubview(cameraIcon)
    }
    
    func showCamera(animated: Bool = true) {
        guard cameraIcon != nil else {
            return
        }
        
        self.view.bringSubviewToFront(vwLine)
        self.view.bringSubviewToFront(cameraIcon)
        let screenBounds = self.view.bounds
        
        if animated == true {
            vwLine.alpha = 0.0
            cameraIcon.alpha = 0.0
            vwLine.center = CGPoint(x: screenBounds.size.width/2, y: screenBounds.size.height + 4)
            cameraIcon.center = CGPoint(x: screenBounds.size.width/2, y: screenBounds.size.height + 50)
            UIView.animateWithDuration(0.2) {
                self.vwLine.alpha = 1.0
                self.vwLine.center = CGPoint(x: screenBounds.size.width/2, y: screenBounds.size.height - 2)
                self.cameraIcon.alpha = 1.0
                self.cameraIcon.center = CGPoint(x: screenBounds.size.width/2, y: screenBounds.size.height - 25)
            }
        }
        else {
            self.vwLine.alpha = 1.0
            self.vwLine.center = CGPoint(x: screenBounds.size.width/2, y: screenBounds.size.height - 2)
            self.cameraIcon.alpha = 1.0
            self.cameraIcon.center = CGPoint(x: screenBounds.size.width/2, y: screenBounds.size.height - 25)
        }
    }
    
    func hideCamera() {
        guard cameraIcon != nil else {
            return
        }
        
        let screenBounds = self.view.bounds
        UIView.animateWithDuration(0.2) {
            self.vwLine.alpha = 0.0
            self.vwLine.center = CGPoint(x: screenBounds.size.width/2, y: screenBounds.size.height + 4)
            self.cameraIcon.alpha = 0.0
            self.cameraIcon.center = CGPoint(x: screenBounds.size.width/2, y: screenBounds.size.height + 50)
        }
    }
}

extension BaseViewController { //Animation Alarm Bar
    struct AlarmBarConfiguration {
        static let PosY = 50
        static let Height = 24
        static let Width = 200
    }
    
    func initAlarmBar() {
        alarmBar = UIView(frame: CGRect(x: 0, y: AlarmBarConfiguration.PosY, width: AlarmBarConfiguration.Width, height: AlarmBarConfiguration.Height))
        alarmBar.alpha = 0
        alarmBar.backgroundColor = self.alarmBackgroundColor
        alarmBar.layer.cornerRadius = CGFloat(AlarmBarConfiguration.Height/2)
        alarmBar.layer.masksToBounds = true
        self.view.addSubview(alarmBar)
        
        alarmLabel = UILabel(frame: alarmBar.bounds)
        alarmLabel.textColor = alarmTextColor
        alarmLabel.textAlignment = .Center
        alarmLabel.text = alarmText
        alarmBar.addSubview(alarmLabel)
    }
    
    func showAlarm() {
        guard alarmBar != nil && alarmText.characters.count > 0 else {
            return
        }
        
        self.view.bringSubviewToFront(alarmBar)
        alarmBar.alpha = 1.0
        var barFrame = alarmBar.frame
        barFrame.origin.x = -barFrame.size.width
        alarmBar.frame = barFrame
        UIView.animateWithDuration(0.2) {
            barFrame.origin.x = -CGFloat(AlarmBarConfiguration.Height/2)
            self.alarmBar.frame = barFrame
        }
    }
    
    func showAlarm(text: String, timeInterval: Double) {
        guard alarmBar != nil else {
            return
        }
        
        self.alarmText = text

        self.view.bringSubviewToFront(alarmBar)
        alarmBar.alpha = 1.0
        var barFrame = alarmBar.frame
        barFrame.origin.x = -barFrame.size.width
        alarmBar.frame = barFrame
        UIView.animateWithDuration(0.3) {
            barFrame.origin.x = -CGFloat(AlarmBarConfiguration.Height/2)
            self.alarmBar.frame = barFrame
        }
        
        if timeInterval > 0{
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(timeInterval * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.hideAlarm()
            })
        }
    }
    
    func hideAlarm() {
        var barFrame = alarmBar.frame
        UIView.animateWithDuration(0.2) {
            barFrame.origin.x = -barFrame.size.width
            self.alarmBar.frame = barFrame
            self.alarmBar.alpha = 0
        }
    }
}

