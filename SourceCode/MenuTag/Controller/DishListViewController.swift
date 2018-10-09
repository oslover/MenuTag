//
//  DishListViewController.swift
//  MenuTag
//
//  Created by John David on 9/12/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit

typealias DishGroup = [String: [Dish]]

protocol DishListViewControllerDelegate {
    func dishListViewDismissed()
}

class DishListViewController: BaseViewController {
    var delegate: DishListViewControllerDelegate!
    var restaurant: Venue!
    var dishGroups: DishGroup = DishGroup()
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblDish: UITableView!
    @IBOutlet weak var vwTitleBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restaurant = Manager.sharedInstance.selectedRestaurant
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DishListViewController.handlePan(_:)))
        self.vwTitleBar.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadDishes()
        self.lblTitle.text = self.restaurant.name
    }
    
    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began || gestureRecognizer.state == UIGestureRecognizerState.Changed {
            let translation = gestureRecognizer.translationInView(self.view)
            self.view!.center = CGPointMake(self.view!.center.x, self.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPointMake(0,0), inView: self.view)
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            if self.view.frame.origin.y > self.view.frame.size.height/2 {
                dismissView()
            }
            else {
                UIView.animateWithDuration(0.3, animations: { 
                    var rtView = self.view.frame
                    rtView.origin.y = 0
                    self.view.frame = rtView
                })
            }
        }
    }

    @IBAction func onTabBackground(sender: AnyObject) {
        dismissView()
    }
    
    func dismissView() {
        if self.delegate != nil {
            self.delegate.dishListViewDismissed()
        }
        
        UIView.animateWithDuration(0.3, animations: {
            var rtView = self.view.frame
            rtView.origin.y = rtView.size.height
            self.view.frame = rtView
        }) { (result) in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            Manager.sharedInstance.selectedRestaurant = nil
        }
    }
    
    func reloadDishes() {
        self.dishGroups.removeAll()
        for dish in self.restaurant.dishes{
            if self.dishGroups[dish.name] != nil {
                self.dishGroups[dish.name]!.append(dish)
            }
            else
            {
                var dishes = [Dish]()
                dishes.append(dish)
                self.dishGroups[dish.name] = dishes
            }
        }

        self.tblDish.reloadData()
    }
}

extension DishListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dishGroups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DISH_CELL") as! DishTableViewCell
        cell.selectionStyle = .None
        cell.frame.size.width = self.view.frame.size.width
        cell.layoutIfNeeded()
        
        let name = self.dishGroups.keys[self.dishGroups.keys.startIndex.advancedBy(indexPath.row)]
        cell.resetWithDish(self.dishGroups[name]!, dishName: name)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 250
    }
}
