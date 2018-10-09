//
//  AppConstants.swift
//  Prayer
//
//  Created by John David on 7/18/16.
//  Copyright © 2016 Jessup. All rights reserved.
//

import UIKit

struct Constant{
    
    static func allFonts() {
        for family: String in UIFont.familyNames()
        {
            print("\(family)")
            for names: String in UIFont.fontNamesForFamilyName(family)
            {
                print("== \(names)")
            }
        }
    }
    
    struct FOURSQUARE{
        static let defaultRadius = "500"
    }
    
    struct AWS{
        static let BucketName = "foodlens"
        static let AccessKeyID = "AKIAJ7U644BMNQZZME7Q"
        static let SecretAccessKey = "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"
    }
    
    struct UI {
        static func RGB(r r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
            return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
        }
        
        static let GLOBAL_TINT_COLOR = UIColor(red: 246.0/255.0, green: 95.0/255.0, blue: 89.0/255.0, alpha: 1)
        static let COLOR_BLUE = UI.RGB(r: 82, g: 190, b: 216)
        static let COLOR_LIGHT = UI.RGB(r: 239, g: 83, b: 80)
    }
    
    struct StandardDefault {
        static let CURRENTUSER           = "CurrentUser"
    }
    
    struct Notification {
        static let LOCATION_UPDATED     = "NOTIFICATION_LOCATION_UPDATED"
        static let VENUE_LOADED         = "NOTIFICATION_VENUE_LOADED"
        static let DISH_POSTED          = "NOTIFICATION_DISH_POSTED"
        static let DISH_POST_CANCELLED  = "NOTIFICATION_DISH_POST_CANCELLED"
        static let AWS_UPLOADED         = "NOTIFICATION_AWS_UPLOADED"
    }
}

struct Global_Functions {
    static func stringSinceDateFor(interval: NSTimeInterval) -> String?{
        let period: Int = Int(NSDate().timeIntervalSince1970 - interval)
        
        let min = period/60
        let hours = (min/60)%24
        let day = (min/1440)
        let month = day / 30
        let year = month / 12
        
        var ret: String
        if (hours == 0)
        {
            ret = "\(min) min(s)"
        }
        else
        {
            ret = "\(hours) hr(s)"
            if (day > 0)
            {
                ret = "\(day%30) day(s)" + ret
                if (month > 0)
                {
                    ret = "\(month) month(s)"
                    if (year > 0)
                    {
                        ret = "\(year) yr(s) \(month%12) mth(s)"
                    }
                }
            }
        }
        return ret
    }
}
