//
//  APIManager.swift
//  MenuTag
//
//  Created by John David on 9/13/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit
import Alamofire

typealias ShareCallBack = ((Dish?)-> Void)
typealias DishListCallBack = ((dishes: [Dish]?, names: [String]?)-> Void)

class APIManager {
    static let sharedInstance = APIManager()
    //static let serverAddress = "http://192.168.1.119/haslem/api.php"
    static let serverAddress = "http://reviewtable.com/foodlens/api.php"
    
    class func shareDish(name: String, rating: Float, restaurant: String, imageUrl: String, completion: ShareCallBack?) {
        var params = ["action": "share"]
        params["name"] = name
        params["rating"] = "\(rating)"
        params["restaurant"] = restaurant
        params["image"] = imageUrl
            
        Alamofire.request(.POST, serverAddress, parameters: params).responseJSON { (response) in
            guard response.result.isSuccess else {
                if completion != nil {
                    completion!(nil)
                }
                return
            }
            
            guard let value = response.result.value as? [String:AnyObject], success = value["success"] as? Int, data = value["data"] as? [String: AnyObject] else {
                if completion != nil {
                    completion!(nil)
                }
                return
            }
            
            if success == 0 {
                return
            }
            
            if let dish = Dish.dishFromDict(data) {
                if completion != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        dish.isNew = true
                        completion!(dish)
                    })
                }
            }
            else {
                if completion != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        completion!(nil)
                    })
                }
            }
        }
    }
    
    class func dishes(restaurant: String, completion: DishListCallBack?) {
        var params = ["action": "dishes"]
        params["restaurant"] = restaurant
        
        Alamofire.request(.GET, serverAddress, parameters: params).responseJSON { (response) in
            guard response.result.isSuccess else {
                if completion != nil {
                    completion!(dishes: nil, names: nil)
                }
                return
            }
            
            guard let value = response.result.value as? [String:AnyObject], success = value["success"] as? Int, data = value["data"] as? [JSONObject], names = value["name"] as? [String] else {
                if completion != nil {
                    completion!(dishes: nil, names: nil)
                }
                return
            }
            
            if success == 0 {
                return
            }
            
            var dishes = [Dish]()
            for object in data {
                if let dish = Dish.dishFromDict(object) {
                    dishes.append(dish)
                }
            }
            
            if completion != nil {
                dispatch_async(dispatch_get_main_queue(), { 
                    completion!(dishes: dishes, names: names)
                })
            }
        }
    }
}
