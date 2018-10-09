//
//  DishThumbView.swift
//  MenuTag
//
//  Created by John David on 9/13/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit

class DishThumbView: UIView {
    static let emptyStarImage = UIImage(named: "star_gray")
    static let fullStarImage = UIImage(named: "star_yellow")
    static let placeHolderImage = UIImage(named: "no_image")
    
    var newLabel: UILabel!
    var imageView: CacheImageView!
    //var ratingView: FloatRatingView!
    
    var dish: Dish!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    func initSubViews() {
        self.clipsToBounds = true
        self.imageView = CacheImageView(frame: CGRectZero)
        self.addSubview(imageView)
        
        self.newLabel = UILabel()
        self.newLabel.layer.borderColor = UIColor.whiteColor().CGColor
        self.newLabel.layer.borderWidth = 1
        self.newLabel.layer.backgroundColor = UIColor(red: 0, green: 0.8, blue: 0.3, alpha: 1.0).colorWithAlphaComponent(0.6).CGColor
        self.newLabel.layer.cornerRadius = 12.5
        self.newLabel.hidden = true
        self.newLabel.textColor = UIColor.whiteColor()
        self.newLabel.text = "      Item Added   "
        self.newLabel.font = UIFont.italicSystemFontOfSize(18)
        self.addSubview(self.newLabel)
        
//        self.ratingView = FloatRatingView()
//        self.ratingView.emptyImage = DishThumbView.emptyStarImage
//        self.ratingView.fullImage = DishThumbView.fullStarImage
//        self.ratingView.editable = false
//        self.ratingView.minRating = 0
//        self.ratingView.maxRating = 5
//        self.addSubview(self.ratingView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.bounds.size
        self.newLabel.frame = CGRect(x: -10, y: 7, width: 140, height: 25)
        self.imageView.frame = CGRect(origin: CGPointZero, size: size)
        //self.ratingView.frame = CGRect(x: size.width - 110, y: 10, width: 100, height: 20)
    }
    
    func resetWithDish(dish: Dish) {
        //self.ratingView.rating = dish.rating
        
        if dish.isNew {
            self.newLabel.hidden = false
        }
        else {
            self.newLabel.hidden = true
        }
        
        if let image = dish.image {
            self.imageView.image = image
        }
        else {
            if let image = UIImage.imageFrom("\(dish.id)", subfolder: "dish") {
                self.imageView.image = image
            }
            else {
                self.imageView.setImageWithURL(NSURL(string: dish.imageUrl)!, placeholder: DishThumbView.placeHolderImage!) { (image, error) in
                    if let resultImage = image {
                        resultImage.saveToFile("\(dish.id)", subfolder: "dish")
                    }
                }
            }
        }
    }
}
