//
//  VenueAnnotationView.swift
//  Revur
//
//  Created by John David on 8/31/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit
import MapKit

class VenueAnnotationView: MKAnnotationView {
    
    var contentLabel: UILabel!
    
    // Required for MKAnnotationView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = UIImage(named: "icon_pin")
        initAnnotationView()
    }
    
    func initAnnotationView() {
        if contentLabel == nil {
            contentLabel = UILabel()
            contentLabel.textColor = UIColor.whiteColor()
            contentLabel.textAlignment = .Center
            contentLabel.font = UIFont.boldSystemFontOfSize(12)
            contentLabel.frame = CGRectMake(0, 0, 200, 20)
            contentLabel.layer.cornerRadius = 8
            contentLabel.layer.borderColor = UIColor.whiteColor().CGColor
            contentLabel.layer.borderWidth = 0
            contentLabel.layer.backgroundColor = UIColor(red: 1, green: 19.0/255.0, blue: 68.0/255.0, alpha: 1.0).CGColor
            contentLabel.layer.masksToBounds = true
            self.addSubview(contentLabel)
        }
        
        if let venueAnnotation = self.annotation as? VenueAnnotation {
            contentLabel.text = venueAnnotation.currentVenue.name
            contentLabel.sizeToFit()
            contentLabel.frame.size.width = contentLabel.frame.size.width + 10
            contentLabel.frame.size.height = 16
            contentLabel.center = CGPointMake(self.bounds.size.width/2, -10)
        }
    }
}
