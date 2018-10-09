//
//  Manager.swift
//  Prayer
//
//  Created by John David on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SVProgressHUD
import AWSS3
import AWSCore

class Manager: NSObject{
    static let sharedInstance = Manager()
    
    var awsImageUrl: String! = ""
    var selectedRestaurant: Venue!
    var capturedImage: UIImage!
    
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    private override init() {
        super.init()
        initConfiguration()
    }
    
    func initConfiguration()
    {
        SVProgressHUD.setDefaultStyle(.Light)
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
    }
    
    func initGeolocation() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            let status = CLLocationManager.authorizationStatus()
            if status == .NotDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            } else if status == CLAuthorizationStatus.AuthorizedWhenInUse
                || status == CLAuthorizationStatus.AuthorizedAlways {
                self.locationManager.startUpdatingLocation()
            }
            else {
                showNoPermissionsAlert()
            }
        }
    }
    
    func showNoPermissionsAlert() {
        let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        
        let alertController = UIAlertController(title: "No permission",
                                                message: "In order to work, app needs your location", preferredStyle: .Alert)
        let openSettings = UIAlertAction(title: "Open settings", style: .Default, handler: {
            (action) -> Void in
            let URL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(URL!)
        })
        alertController.addAction(openSettings)
        viewController?.presentViewController(alertController, animated: true, completion: nil)
    }
}

extension Manager {
    class func uploadImageToS3(imageData: NSData, completion: (response: AnyObject?)->Void) {
        let date = NSDate()
        let hashableString = "\(date.timeIntervalSinceReferenceDate)".md5
        
        // make sure that you already have all of these things
        // sorted out. It is really necessary!
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: Constant.AWS.AccessKeyID, secretKey: Constant.AWS.SecretAccessKey)
        let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        defaultServiceConfiguration.maxRetryCount = 5
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
        // this is only to make sure that
        // the image is hashed to avoid redundancy
        
        let tempFile = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("temp")
        let uploadRequest : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        imageData.writeToURL(tempFile, atomically: true)
        
        // set the bucket
        uploadRequest.bucket = Constant.AWS.BucketName
        // I want this image to be public to anyone to view
        // it so I'm setting it to Public Read
        uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
        // set the image's name that will be used on the s3 server.
        // I am also creating a folder to place the image in
        uploadRequest.key = hashableString + ".png"
        // set the content type
        uploadRequest.contentType = "image/png"
        // and finally set the body to the local file path
        uploadRequest.body = tempFile
        
        // we will track progress through an
        // AWSNetworkingUploadProgressBlock
        uploadRequest.uploadProgress = {(bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) in
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                print(totalBytesSent)
            })
        }
        
        // now the upload request is set up we can
        // create the transfermanger,
        // the credentials are already set up in the app delegate
        let transferManager: AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
        // start the upload
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
            if (task.error != nil) {
                completion(response: nil)
            } else {
                completion(response: "https://s3.amazonaws.com/" + Constant.AWS.BucketName + "/" + hashableString + ".png")
            }
            return "all done"
        }
    }
}

extension Manager: CLLocationManagerDelegate {
    class func openAppleMapWithDirection(lat: Float, lon: Float, name: String) {
        let coordinate = CLLocationCoordinate2DMake(Double(lat), Double(lon))
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = name
        mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
        else {
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newlocation = locations[0]
        
        if self.location == nil || self.location.distanceFromLocation(newlocation) > 100 {
            print("location updated")
            self.location = newlocation
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.LOCATION_UPDATED, object: nil)
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Error")
    }
}
