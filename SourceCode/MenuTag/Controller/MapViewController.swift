//
//  MapViewController.swift
//  Revur
//
//  Created by John David on 8/26/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit
import SVProgressHUD
import MapKit

class MapViewController: BaseViewController {
    var isForRating = false
    var dishListViewController: DishListViewController!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadMap()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideAlarm()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if Manager.sharedInstance.selectedRestaurant == nil {
            showCamera()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsPointsOfInterest = false
        mapView.showsUserLocation = true
        mapView.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.VENUE_LOADED, object: nil, queue: nil) { (notification) in
            let standard = NSUserDefaults.standardUserDefaults()
            let launched = standard.boolForKey("LAUNCHED_ALREADY")
            if launched == false {
                self.showAlarm("Choose a restaurant", timeInterval: 3)
                standard.setBool(true, forKey: "LAUNCHED_ALREADY")
                standard.synchronize()
            }
            self.reloadMap()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.DISH_POSTED, object: nil, queue: nil) { (notification) in
            self.isForRating = false
            self.showDishList()
            self.showCamera()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Constant.Notification.DISH_POST_CANCELLED, object: nil, queue: nil) { (notification) in
            self.isForRating = false
            self.showCamera()
        }
    }
    
    func showDishList() {
        if Manager.sharedInstance.selectedRestaurant == nil {
            return
        }
        
        if dishListViewController == nil {
            dishListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("dishlistviewcontroller") as! DishListViewController
            dishListViewController.delegate = self
            self.addChildViewController(dishListViewController)
            dishListViewController.view.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            self.view.insertSubview(dishListViewController.view, atIndex: 1)
            UIView.animateWithDuration(0.3) { 
                self.dishListViewController.view.frame = self.view.bounds
            }
        }
        else {
            dishListViewController.reloadDishes()
        }
    }
}

extension MapViewController { //MapView
    func reloadMap() {
        let venues = FoursquareAPI.sharedInstance.searchedVenues
        guard venues.count > 0 else {
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
        var minLat: Double = Double(MAXFLOAT), minLong: Double = Double(MAXFLOAT), maxLat: Double = -Double(MAXFLOAT), maxLong: Double = -Double(MAXFLOAT)
        
        for venue in venues {
            let coordinate = CLLocationCoordinate2DMake(Double(venue.latitude), Double(venue.longitude))
            minLat = min(minLat, coordinate.latitude)
            minLong = min(minLong, coordinate.longitude)
            maxLat = max(maxLat, coordinate.latitude)
            maxLong = max(maxLong, coordinate.longitude)
            let title = venue.name + ", \(Int(venue.distance))m"
            let subtitle = venue.addressString()
            let annotation = VenueAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, venue: venue)
            mapView.addAnnotation(annotation)
        }
        
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.2, longitudeDelta: (maxLong - minLong)*1.2)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake((minLat + maxLat)/2, (minLong+maxLong)/2), span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func showRouteOnMap(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        self.mapView.removeOverlays(self.mapView.overlays)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .Automobile
        
        let directions = MKDirections(request: request)
        SVProgressHUD.show()
        directions.calculateDirectionsWithCompletionHandler { (response, error) in
            SVProgressHUD.dismiss()
            guard let unwrappedResponse = response else {
                return
            }
            
            if (unwrappedResponse.routes.count > 0) {
                self.mapView.addOverlay(unwrappedResponse.routes[0].polyline)
                self.mapView.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, animated: true)
            }
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is VenueAnnotation {
            var annotationView: VenueAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier("VenueAnnotation") as? VenueAnnotationView
            if annotationView == nil {
                annotationView = VenueAnnotationView(annotation: annotation, reuseIdentifier: "VenueAnnotation")
            }
            annotationView!.canShowCallout = false
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = Constant.UI.GLOBAL_TINT_COLOR
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //Load Restaurant Information
        
        guard let annotation = view.annotation as? VenueAnnotation else {
            SVProgressHUD.showErrorWithStatus("Error")
            return
        }
        
        Manager.sharedInstance.selectedRestaurant = annotation.currentVenue
        let restaurant = Manager.sharedInstance.selectedRestaurant
        
        SVProgressHUD.show()
        APIManager.dishes(restaurant.venueId) { (dishes, names) in
        //APIManager.dishes("104") { (dishes, names) in
            SVProgressHUD.dismiss()
            guard let dishArray = dishes, let nameArray = names else {
                SVProgressHUD.showErrorWithStatus("No dishes yet posted to this restaurant.")
                return
            }
            restaurant.dishes.removeAll()
            restaurant.dishNames.removeAll()
            restaurant.dishes.appendContentsOf(dishArray)
            restaurant.dishNames.appendContentsOf(nameArray)
            
            if self.isForRating {
                self.performSegueWithIdentifier("sid_takephoto", sender: self)
            }
            else {
                self.showDishList()
            }
        }
    }
}

extension MapViewController { //onCamera Event
    override func onCamera(){
        self.isForRating = true
        if Manager.sharedInstance.selectedRestaurant == nil {
            showAlarm("Tag your location", timeInterval: 3)
            hideCamera()
        }
        else {
            self.performSegueWithIdentifier("sid_takephoto", sender: self)
        }
    }
}

extension MapViewController: DishListViewControllerDelegate {
    func dishListViewDismissed() {
        self.dishListViewController = nil
    }
}
