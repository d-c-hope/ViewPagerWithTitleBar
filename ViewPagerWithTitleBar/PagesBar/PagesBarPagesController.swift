//
//  PagesBarViewController.swift
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import Foundation


import UIKit

// The pages that site beneath the title bar
class PagesBarPagesController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageScrollView: UIScrollView!
    @IBOutlet weak var pageContainer: UIView!

    var offsetHasChanged: ((offset: CGFloat) -> Void)?
    var currentIndex = 0
    
    var orderedViewControllers: [UIViewController] = [UIViewController]()
    
    var called = false
    var allConstraints = [NSLayoutConstraint]()
        
    func addViewController(controller: UIViewController, index: Int) {
        self.orderedViewControllers.insert(controller, atIndex: index)
        self.addChildViewController(controller)
        self.pageContainer.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }
    
    func clearControllers() {
        removeAllViews()
        for controller in orderedViewControllers {
            controller.removeFromParentViewController()
        }
        orderedViewControllers.removeAll()
    }

    private func removeAllViews() {
        for ctl in orderedViewControllers {
            ctl.view.removeFromSuperview()
        }
        clearConstraints()
    }
    
    func layout() {
        clearConstraints()
        
        let frameWidth = self.view.frame.size.width
        let frameHeight = self.view.frame.size.height

        pageScrollView.contentSize = CGSizeMake(frameWidth * CGFloat(orderedViewControllers.count), frameHeight)
        
        let indexAndViewList: [(String, UIView)] = orderedViewControllers.enumerate().map { (index, element) in
            return ("view\(index)", element.view)
        }
        // turn [("label":view1),("label2":view2)] into ["label":view1,"label2":view2]
        var indexAndViewDict = [String:UIView]()
        for (label, view) in indexAndViewList {
            indexAndViewDict[label] = view
        }
        
        // Aim is to build up something like:
        //      "H:|[view1(\(frameWidth))][view2(\(frameWidth))][view3(\(frameWidth))]|"
        var hConstraintString = "H:|"
        
        for (label, view) in indexAndViewList {
            
            hConstraintString += "[\(label)(\(frameWidth))]"
            
            let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[view]|",
                options: [],
                metrics: nil,
                views: ["view" : view])
            allConstraints += verticalConstraints
            
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        hConstraintString += "|"
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            hConstraintString,  options: [],  metrics: nil, views: indexAndViewDict)
        
        allConstraints += horizontalConstraints
        NSLayoutConstraint.activateConstraints(allConstraints)
        
        pageScrollView.contentOffset = CGPointMake(frameWidth*CGFloat(currentIndex), 0)
    }
    
    func clearConstraints() {
        for constraint in allConstraints {
            constraint.active = false
        }
        allConstraints.removeAll()
    }
    
    func moveToPosition() {
        let frameWidth = self.view.frame.size.width
        pageScrollView.contentOffset = CGPointMake(frameWidth*CGFloat(currentIndex), 0)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let callback = offsetHasChanged {
            callback(offset: scrollView.contentOffset.x)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageScrollView.pagingEnabled=true;
        pageScrollView.delegate = self
        pageScrollView.backgroundColor = UIColor.blackColor()
        pageContainer.backgroundColor = UIColor.grayColor()
    }
    
}









