//
//  Venue.swift
//  Revur
//
//  Created by John David on 8/30/16.
//  Copyright © 2016 John David. All rights reserved.
//

typealias VenueType = String

class Venue {
    var venueId: String!
    var name: String!
    
    var address: String!
    var country: String!
    var street: String!
    var city: String!
    var postalCode: String!
    var state: String!
    
    var distance: Float! = 0
    var latitude: Float!
    var longitude: Float!
    
    var price: Price!
    
    var ratings: Float! = 0 //0~10,
    var ratingCount: Int! = 0
    
    var url: String!
    var categories = [Category]()
    
    var photos = [Image]()
    var openStatus: String!
    
    var dishNames = [String]()
    var dishes = [Dish]()
    
    var venueType: VenueType
    {
        if self.categories.count > 0{
            return self.categories[0].categoryId!
        }
        return ""
    }
    
    func addDish(dish: Dish) {
        if self.dishes.contains(dish) {
            return
        }
        
        self.dishes.insert(dish, atIndex: 0)
        
        if !self.dishNames.contains(dish.name) {
            self.dishNames.sortInPlace{$0 < $1}
            self.dishNames.insert(dish.name, atIndex: 0)
        }
    }
    
    func addressString() -> String {
        var ret: String! = nil
        if address != nil && address.characters.count > 0{
            ret = address
        }
        
        if city != nil && city.characters.count > 0{
            if ret == nil {
                ret = city
            }
            else {
                ret = ret + ", " + city
            }
        }
        
        if state != nil && state.characters.count > 0{
            if ret == nil {
                ret = state
            }
            else {
                ret = ret + ", " + state
            }
        }
        
        if country != nil && country.characters.count > 0{
            if ret == nil {
                ret = country
            }
            else {
                ret = ret + ", " + country
            }
        }
        return ret
    }
}

extension Venue {
    class func venueFromJSON(object: JSONObject?) -> Venue? {
        guard object != nil else {
            return nil
        }
        
        let venue = Venue()
        venue.venueId = object!["id"] as! String
        venue.name = object!["name"] as! String
        
        let addressJson = object!["location"] as! JSONObject
        if let val = addressJson["address"]{
            venue.address = val as! String
        }
        
        if let val = addressJson["country"]{
            venue.country = val as! String
        }
        
        if let val = addressJson["city"]{
            venue.city = val as! String
        }
        
        if let crossStreet = addressJson["crossStreet"] {
            venue.street = crossStreet as! String
        }
        
        if let val = addressJson["state"]{
            venue.state = val as! String
        }
        
        if let val = addressJson["postalCode"]{
            venue.postalCode = val as! String
        }
        
        if let val = addressJson["distance"]{
            venue.distance = val as! Float
        }
        
        if let val = addressJson["lat"]{
            venue.latitude = val as! Float
        }
        
        if let val = addressJson["lng"]{
            venue.longitude = val as! Float
        }
        
        if let priceJson = object!["price"] as? JSONObject{
            var price = Price()
            price.currency = priceJson["currency"] as! String
            price.message = priceJson["message"] as! String
            price.tier = priceJson["tier"] as! Int
            venue.price = price
        }
        
        if let val = object!["rating"]{
            venue.ratings = (val as! Float)/2.0
        }
        
        if let val = object!["ratingSignals"]{
            venue.ratingCount = val as! Int
        }
        
        if let url = addressJson["url"] {
            venue.url = url as! String
        }
        
        for subObject: JSONObject in (object!["categories"] as! [JSONObject]){
            if let subCategory = Category.categoryFromJSON(subObject) {
                venue.categories.append(subCategory)
            }
        }
        
        if let photoJson = object!["featuredPhotos"] as? JSONObject {
            for subObject: JSONObject in (photoJson["items"] as![JSONObject]){
                var image = Image()
                image.prefix = subObject["prefix"] as! String
                image.suffix = subObject["suffix"] as! String
                image.width = subObject["width"] as! Int
                image.height = subObject["height"] as! Int
                
                image.fullUrl = image.prefix + "\(image.width)x\(image.height)" + image.suffix
                image.thumbUrl = image.prefix + "100x100" + image.suffix
                venue.photos.append(image)
            }
        }
        
        if let hourJson: JSONObject = object!["hours"] as? JSONObject{
            if let status = hourJson["status"] {
                venue.openStatus = status as! String
            }
        }
        
        return venue
    }
}
