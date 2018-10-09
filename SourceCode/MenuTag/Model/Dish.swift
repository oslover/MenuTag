//
//  Dish.swift
//  MenuTag
//
//  Created by John David on 9/12/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit

class Dish: NSObject {
    var id: String!
    var name: String!
    var rating: Float!
    var restaurantId: String!
    var image: UIImage!
    var imageUrl: String!
    var isNew: Bool = false
    
    class func dishFromDict(dict: [String: AnyObject]!) -> Dish? {
        guard dict != nil else {
            return nil
        }
        
        let dish = Dish()
        dish.id = String(dict["id"])
        dish.name = dict["name"] as! String
        dish.restaurantId = dict["restaurant"] as! String
        dish.imageUrl = dict["image"] as! String
        dish.rating = Float(dict["rating"]! as! String)
        return dish
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let target = object as? Dish else {
            return false
        }
        
        if self.id == target.id {
            return true
        }
        return false
    }
}
