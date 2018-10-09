//
//  DIshTableViewCell.swift
//  MenuTag
//
//  Created by John David on 9/13/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit

class DishTableViewCell: UITableViewCell {
    var dishes: [Dish] = [Dish]()
    var dishName: String!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblDishGroupName: UILabel!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var ratingView: FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func resetWithDish(dishList: [Dish], dishName: String) {
        scrollView.delegate = self
        self.dishes.removeAll()
        self.dishes.appendContentsOf(dishList)
        self.lblDishGroupName.text = dishName
        
        for subView in self.scrollView.subviews {
            if subView is DishThumbView {
                subView.removeFromSuperview()
            }
        }
        
        var scoreSum: Float = 0.0
        var rtBounds = self.scrollView.bounds
        for i in 0..<self.dishes.count{
            let dish = self.dishes[i]
            scoreSum += dish.rating
            rtBounds.origin.x = CGFloat(i)*rtBounds.size.width
            let thumbView = DishThumbView(frame: rtBounds)
            thumbView.resetWithDish(dish)
            self.scrollView.addSubview(thumbView)
        }
        
        if self.dishes.count > 0 {
            self.ratingView.rating = scoreSum/Float(self.dishes.count)
        }
        else {
            self.ratingView.rating = 0
        }
        updateButtons()
        
        self.scrollView.setContentOffset(CGPointZero, animated: false)
        self.scrollView.contentSize = CGSize(width: rtBounds.width*CGFloat(self.dishes.count), height: rtBounds.height)
    }
}

extension DishTableViewCell: UIScrollViewDelegate {
    
    @IBAction func onLeft(sender: AnyObject) {
        var contentOffset = scrollView.contentOffset
        contentOffset.x = contentOffset.x - scrollView.bounds.width
        scrollView.setContentOffset(contentOffset, animated: true)
        
    }
    
    @IBAction func onRight(sender: AnyObject) {
        var contentOffset = scrollView.contentOffset
        contentOffset.x = contentOffset.x + scrollView.bounds.width
        scrollView.setContentOffset(contentOffset, animated: true)
    }
    
    func updateButtons() {
        if self.dishes.count <= 1 {
            btnLeft.hidden = true
            btnRight.hidden = true
            return
        }
        btnLeft.hidden = false
        btnRight.hidden = false
        
        let page = Int(self.scrollView.contentOffset.x + 1) / Int(self.scrollView.bounds.size.width)
        if page <= 0 {
            btnLeft.hidden = true
        }
        else if page >= self.dishes.count - 1 {
            btnRight.hidden = true
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateButtons()
    }
}
