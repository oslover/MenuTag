//
//  AppConfiguration.swift
//  Prayer
//
//  Created by John David on 7/15/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

//Location 37.787359 -122.408227
//41.7922, 123.4328

import UIKit

extension NSError {
    func description(description: String, code: Int) -> NSError {
        let domain = NSBundle.mainBundle().bundleIdentifier
        let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: description]
        return NSError(domain: domain!, code: code, userInfo: userInfo)
    }
    
    func getDescription() -> String {
        return self.userInfo[NSLocalizedDescriptionKey as NSObject] as! String
    }
}

extension Float {
    func toMilesFromMeter() -> Float { //meters to miles
        return self*0.000621371;
    }
    
    func toMetersFromMile() -> Float { //miles to meters
        return self/0.000621371;
    }
    
    func toMilesFromKiloMeter() -> Float { //kilometers to miles
        return self*0.621371;
    }
    
    func toKiloMetersFromMile() -> Float { //miles to kilometers
        return self/0.621371;
    }
}

struct Image{
    var prefix: String!
    var suffix: String!
    var thumbUrl: String!
    var fullUrl: String!
    
    var width: Int!
    var height: Int!
}

struct Price {
    var currency: String!
    var message: String!
    var tier: Int!
}

extension UIImage {
    func saveToFile (name: String, subfolder: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        print(paths)
        let dirPath = paths + "/images/\(subfolder)"
        let imagePath = dirPath + "/\(name).jpg"
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(imagePath) == false
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                try! fileManager.createDirectoryAtPath(dirPath, withIntermediateDirectories: true, attributes: nil)
                UIImageJPEGRepresentation(self, 100)!.writeToFile(imagePath, atomically: true)
            }
        }
    }
    
    class func imageFrom(name: String, subfolder: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let dirPath = paths + "/images/\(subfolder)"
        let imagePath = dirPath + "/\(name).jpg"
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(imagePath) {
            return UIImage(contentsOfFile: imagePath)
        }
        return nil
    }
    
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newWidth))
        self.drawInRect(CGRectMake(0, -(newHeight-newWidth)/2, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return String(format: hash as String)
    }
}
