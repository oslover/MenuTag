//
//  RatingViewController.swift
//  MenuTag
//
//  Created by John David on 9/11/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit
import SVProgressHUD

class RatingViewController: BaseViewController {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var tblCandidates: UITableView!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var txtFoodName: UITextField!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var tblHeightConstraint: NSLayoutConstraint!
    var dishName: String!
    
    var names: [String] = [String]()//["Canpture", "Caned butter", "Can Caole gielO", "Foo Pbu", "FoodPotato Engineering", "Foosion bubber aoeidla ep"]
    var searchNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPhoto.image = Manager.sharedInstance.capturedImage
        ratingView.rating = 0

        if Manager.sharedInstance.selectedRestaurant != nil{
            self.names = Manager.sharedInstance.selectedRestaurant.dishNames
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.txtFoodName.becomeFirstResponder()
        self.showAlarm("Name & Rate", timeInterval: 3)
    }
    
    func rateDish() {
        if Manager.sharedInstance.selectedRestaurant == nil || Manager.sharedInstance.awsImageUrl == nil{
            return
        }
        
        if txtFoodName.text?.characters.count == 0 {
            let alert = UIAlertController(title: "Warnning", message: "You haven't typed the food name, close without sharing?", preferredStyle: .Alert)
            let actionOk = UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
                Manager.sharedInstance.selectedRestaurant = nil
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.DISH_POST_CANCELLED, object: nil)
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            alert.addAction(actionOk)
            let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                self.txtFoodName.becomeFirstResponder()
            })
            alert.addAction(actionCancel)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        SVProgressHUD.show()
        APIManager.shareDish(self.dishName, rating: ratingView.rating, restaurant: Manager.sharedInstance.selectedRestaurant.venueId, imageUrl: Manager.sharedInstance.awsImageUrl) { (dish) in
            SVProgressHUD.dismiss()
            if let retDish = dish {
                retDish.image = Manager.sharedInstance.capturedImage
                retDish.image.saveToFile("\(retDish.id)", subfolder: "dish")
                Manager.sharedInstance.selectedRestaurant.addDish(retDish)
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.Notification.DISH_POSTED, object: nil)
            }
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}

extension RatingViewController { //Keyboard Event
    @objc private func keyboardDidShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.shrinkContainerTo(keyboardHeight)
            UIView.setAnimationsEnabled(true)
        })
    }
}

extension RatingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TEXT_CELL") as! RoundTextTableViewCell
        cell.selectionStyle = .None
        cell.resetWithText(self.searchNames[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dishName = self.searchNames[indexPath.row]
        rateDish()
    }
    
    func filterNames(text: String) {
        self.searchNames.removeAll()

        for name: String in self.names {
            if name.lowercaseString.containsString(text.lowercaseString) {
                self.searchNames.append(name)
            }
        }

        //This part is what I spent for 3 hours for solving list bugs. if i remove first reloadData, it doesn't work well.
        self.tblCandidates.reloadData()
        self.tblHeightConstraint.constant = CGFloat(self.searchNames.count) * 35
        self.tblCandidates.layoutIfNeeded()
        self.tblCandidates.reloadData()
    }
}

extension RatingViewController: UITextFieldDelegate {
    func shrinkContainerTo(height: CGFloat) {
        var containerRect = self.container.frame
        containerRect.origin.y =  -height
        self.container.frame = containerRect
    }
    
    func expandContainer() {
        self.container.frame = self.view.bounds
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.setAnimationsEnabled(false)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dishName = textField.text
        rateDish()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        expandContainer()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let targetText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if targetText.characters.count >= 3 {
            self.tblCandidates.hidden = false
            self.filterNames(targetText)
        }
        else {
            self.tblCandidates.hidden = true
        }
        return true
    }
}
