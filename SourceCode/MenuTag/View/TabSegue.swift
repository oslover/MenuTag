//
//  TabSegue.swift
//  MenuTag
//
//  Created by John David on 9/10/16.
//  Copyright © 2016 John David. All rights reserved.
//

import UIKit

@objc(TabSegue)
class TabSegue: UIStoryboardSegue {
    override func perform() {
        if sourceViewController.childViewControllers.count > 0{
            let viewController = sourceViewController.childViewControllers[0]
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
        
        destinationViewController.view.frame = sourceViewController.view.bounds
        sourceViewController.view.insertSubview(destinationViewController.view, atIndex: 0)
        sourceViewController.addChildViewController(destinationViewController)
    }
}
