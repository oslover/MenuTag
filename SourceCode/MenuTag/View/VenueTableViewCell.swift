//
//  VenueTableViewCell.swift
//  Revur
//
//  Created by John David on 8/31/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit

class VenueTableViewCell: UITableViewCell {
    var venue: Venue!
    
    @IBOutlet weak var imgView: CacheImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var ratingView: FloatRatingView!
    
    @IBOutlet weak var lblRating: UILabel!
    
    @IBOutlet weak var lblCategory: UILabel!
    
    @IBOutlet weak var lblOpenStatus: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onDirection(sender: AnyObject) {
        Manager.openAppleMapWithDirection(venue.latitude, lon: venue.longitude, name: venue.name)
    }
    
    func resetWithVenue(venue: Venue) {
        self.venue = venue
        lblName.text = venue.name
        
        
        lblLocation.text = "\(venue.distance/1000.0)km, " + (venue.address ?? venue.street ?? venue.city) + "," + venue.state
        lblRating.text = String(format: "%.1f", venue.ratings)
        ratingView.rating = venue.ratings
        lblCategory.text = venue.categories[0].pluralName
        
        if venue.openStatus != nil {
            lblOpenStatus.text = venue.openStatus
        }
        else {
            lblOpenStatus.text = "N/A"
        }
        
        if venue.price != nil {
            var str = ""
            for _ in 0..<venue.price.tier {
                str += "$"
            }
            lblPrice.text = str
        }
        
        imgView.image = nil
        if venue.photos.count > 0 {
            if let image = UIImage.imageFrom(venue.venueId, subfolder: "venue") {
                imgView.image = image
            }
            else {
                imgView.setImageWithURL(NSURL(string: venue.photos[0].thumbUrl)!, placeholder: UIImage(named: "no_image")!, completion: { (image, error) in
                    if error == nil && image != nil{
                        image!.saveToFile(venue.venueId, subfolder: "venue")
                    }
                })
            }
        }
    }
}
