//
//  Category.swift
//  Revur
//
//  Created by John David on 8/30/16.
//  Copyright © 2016 John David. All rights reserved.
//

typealias JSONObject = [String: AnyObject]

class Category{
    var iconPrefix: String?
    var iconSuffix: String?
    var iconUrl: String?
    var categoryId: String?
    var name: String?
    var pluralName: String?
    var shortName: String?
    var categories = [Category]()
}

extension Category {
    class func categoryFromJSON(object: JSONObject?) -> Category? {
        guard object != nil else {
            return nil
        }
        
        let category = Category()
        category.categoryId = object!["id"] as? String
        category.pluralName = object!["pluralName"] as? String
        category.shortName = object!["shortName"] as? String
        category.name = object!["name"] as? String
        
        let iconObj: JSONObject = object!["icon"] as! JSONObject
        category.iconPrefix = iconObj["prefix"] as? String
        category.iconSuffix = iconObj["suffix"] as? String
        category.iconUrl = category.iconPrefix! + "44" + category.iconSuffix! //icon size 32, 44, 64, 88 , default_bg_32.png , default_bg_44.png, etc
        
        if let subCategories = object!["categories"] {
            for subObject: JSONObject in (subCategories as! [JSONObject]){
                if let subCategory = categoryFromJSON(subObject) {
                    category.categories.append(subCategory)
                }
            }
        }
        return category
    }
}
