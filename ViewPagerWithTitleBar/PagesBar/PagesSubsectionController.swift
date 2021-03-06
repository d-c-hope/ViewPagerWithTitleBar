//
//  PagesSubsectionController.swift
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import Foundation


import UIKit

// The pages that site beneath the title bar
class PagesSubsectionController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pageScrollView: UIScrollView!
    @IBOutlet weak var pageContainer: UIView!

    weak var presenter: PagesBarPresenter?

    var offsetHasChanged: ((offset: CGFloat) -> Void)?
    var currentIndex = 0

    var didAppearType: LifecycleType = LifecycleType.OnSetViewControllers

    var orderedViewControllers: [UIViewController] = [UIViewController]()

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

        pageScrollView.contentSize =
            CGSize(width: frameWidth * CGFloat(orderedViewControllers.count), height: frameHeight)

        let indexAndViewList: [(String, UIView)] =
            orderedViewControllers.enumerate().map { (index, element) in
            return ("view\(index)", element.view)
        }

        // turn [("label":view1),("label2":view2)] into ["label":view1,"label2":view2]
        let hConstraintString = generateConstraintsString(indexAndViewList, frameWidth: frameWidth)
        var indexAndViewDict = [String:UIView]()
        for (label, view) in indexAndViewList {
            indexAndViewDict[label] = view
        }

        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            hConstraintString, options: [], metrics: nil, views: indexAndViewDict)

        allConstraints += horizontalConstraints
        NSLayoutConstraint.activateConstraints(allConstraints)

        pageScrollView.contentOffset = CGPoint(x: frameWidth*CGFloat(currentIndex), y: 0)
    }

    func generateConstraintsString(indexAndViewList: [(String, UIView)],
                                   frameWidth: CGFloat) -> String {

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

        return hConstraintString
    }

    func clearConstraints() {
        for constraint in allConstraints {
            constraint.active = false
        }
        allConstraints.removeAll()
    }

    func moveToPosition() {
        let frameWidth = self.view.frame.size.width
        pageScrollView.contentOffset = CGPoint(x: frameWidth*CGFloat(currentIndex), y: 0)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let callback = offsetHasChanged {
            callback(offset: scrollView.contentOffset.x)
        }
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        presenter?.onDraggingLetGo(targetContentOffset.memory.x)
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        presenter!.onDraggingScrollingComplete()
    }

    func doWillAppear(index: Int) {
        orderedViewControllers[index].beginAppearanceTransition(true, animated: true)
    }

    func doDidAppear(index: Int) {
        orderedViewControllers[index].endAppearanceTransition()
    }

    func doWillDisappear(index: Int) {
        orderedViewControllers[index].beginAppearanceTransition(false, animated: true)
    }

    func doDidDisappear(index: Int) {
        orderedViewControllers[index].endAppearanceTransition()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pageScrollView.pagingEnabled=true
        pageScrollView.delegate = self
        pageScrollView.backgroundColor = UIColor.blackColor()
        pageContainer.backgroundColor = UIColor.grayColor()
    }

    override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        if didAppearType == LifecycleType.OnSetViewControllers {
            return true
        } else {
            return false
        }

    }

}
