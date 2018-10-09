//
//  FoursquareAPI.swift
//  Revur
//
//  Created by John David on 8/30/16.
//  Copyright © 2016 John David. All rights reserved.
//

import QuadratTouch
import CoreLocation
import SVProgressHUD

class FoursquareAPI: NSObject {
    static let sharedInstance = FoursquareAPI()
    static let VENUE_LIMIT = 100
    
    var nearbyRequested = false
    var categoryLoaded = false
    
    var categories = [Category]()
    var foodCategory: Category!
    var session: Session!
    var searchedVenues = [Venue]()
    
    class func configure() {
        sharedInstance.loadCategories()
    }
    
    private override init() {
        super.init()
        initConfiguration()
    }
    
    func initConfiguration() {
        let client = Client(clientID:       "SIM5T2IRCMW3ZX41UTFMKOSPQ0LXVCHS3NPGPSZNQBMRLFYH",
                            clientSecret:   "LLFNFN3R51ZJLEYHAMCHDU3CMZPWDFOIHYGDNZVMT4HTKHLA",
                            redirectURL:    "revur://foursquare")
        let configuration = Configuration(client:client)
        Session.setupSharedSessionWithConfiguration(configuration)
        
        self.session = Session.sharedSession()
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.LOCATION_UPDATED, object: nil, queue: nil) { (notification) in
            if self.categoryLoaded {
                self.loadNearbyVenues({ (result) in
                    NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.VENUE_LOADED, object: nil)
                })
            }
            else {
                self.nearbyRequested = true
            }
        }
    }
    
    func loadCategories() {
        let standard = NSUserDefaults.standardUserDefaults()
        if let jsonCategory = standard.objectForKey("food_categories") {
            self.foodCategory = Category.categoryFromJSON(jsonCategory as? JSONObject)
            self.categoryLoaded = true
        }
        else {
            let task = self.session.venues.categories() { (result) in
                if let response = result.response {
                    for object: JSONObject in (response["categories"] as! [JSONObject]) {
                        let category = Category.categoryFromJSON(object)
                        if category?.name == "Food" {
                            standard.setObject(object, forKey: "food_categories")
                            standard.synchronize()
                            self.foodCategory = category
                        }
                        self.categories.append(category!)
                    }
                    
                    self.categoryLoaded = true
                    if self.nearbyRequested {
                        self.loadNearbyVenues({ (result) in
                            NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.VENUE_LOADED, object: nil)
                        })
                        self.nearbyRequested = false
                    }
                }
            }
            task.start()
        }
    }
 
    func loadNearbyVenues(completion: ((Bool)->Void)?) {
        guard Manager.sharedInstance.location != nil else {
            return
        }
        
        var firstLoading = false
        if self.searchedVenues.count == 0 {
            firstLoading = true
        }
        else {
            self.searchedVenues.removeAll()
        }
        
        if firstLoading {
            SVProgressHUD.show()
        }
        
        var parameters = Manager.sharedInstance.location.parameters()
        parameters += [Parameter.radius: Constant.FOURSQUARE.defaultRadius]
        parameters += [Parameter.categoryId: foodCategory.categoryId!]
        parameters += [Parameter.sortByDistance: "1"]
        parameters += [Parameter.venuePhotos: "1"]
        parameters += [Parameter.venueId: "1"]
        parameters += [Parameter.limit: "\(FoursquareAPI.VENUE_LIMIT)"]
        
        let task = session.venues.explore(parameters) {
            (result) -> Void in
            
            if SVProgressHUD.isVisible() {
                SVProgressHUD.dismiss()
            }

            if let response = result.response {
                let groupJson = response["groups"] as! [JSONObject]
                let firstGroup = groupJson[0]
                let itemJson = firstGroup["items"] as! [JSONObject]
                
                for object: JSONObject in itemJson {
                    let venueJson = object["venue"] as! JSONObject
                    self.searchedVenues.append(Venue.venueFromJSON(venueJson)!)
                }

                if (completion != nil) {
                    completion!(true)
                }
            }
            else {
                if (completion != nil) {
                    completion!(false)
                }
            }
        }
        task.start()
    }
}

extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}
