//
//  PagesBarController.swift
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import UIKit


public struct PagesBarConfig {
    
    internal var numOfItems: Int = 0
    
    internal var singlePageBounds: CGRect = CGRectMake(0,0,0,0)
    
    var numOfVisibleLabels: Int = 0
    
    var hMarginWidth: CGFloat = 0
    
    var textWidth:  CGFloat = 0
    var textHeight: CGFloat = 0
    var textColor:  UIColor = UIColor.blackColor()
    var selectedColor:  UIColor = UIColor.blackColor() // TODO use this
    var textFont:   UIFont  = UIFont(name: "HelveticaNeue", size: 18.0)!
    
    var barBackgroundColor: UIColor = UIColor.whiteColor()
    var selectorColor: UIColor = UIColor.blueColor() // TODO use this
}

public protocol PagesBarEvents {
    func onPageChanged(index: Int)
}

public class PagesBarController: UIViewController {
    
    public var pagesBarConfig: PagesBarConfig?
    public var pagesBarEvents: PagesBarEvents? {
        get {return presenter?.pagesBarEvents}
        set(pagesBarEvents) {presenter?.pagesBarEvents = pagesBarEvents}
    }
    
    @IBOutlet internal weak var labelsScrollView: UIScrollView!
    internal var barSelector: UIView!
    internal var labels: [UILabel] = []
    internal var pagesViewController: PagesBarPagesController!
    
    internal var presenter: PagesBarPresenter? = nil
    internal var pagesBarView: PagesBarView? = nil
    
    var calculatedLayoutInfo: CalculatedLayoutInfo!
    internal var isRotating = false
    
    public static func createPagesBarController() -> PagesBarController {
        let pagesBarController = UIStoryboard(name: "PagesBar", bundle: nil).instantiateViewControllerWithIdentifier("PagesBarController")
        return pagesBarController as! PagesBarController
    }
    
    func setViewControllersAndLabels(controllersAndLabels: [(String, UIViewController)],
                                     initialIndex: Int = 0) {
        presenter!.setViewControllersAndLabels(controllersAndLabels, initialIndex: initialIndex)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        barSelector = UIView()
        labelsScrollView.addSubview(barSelector)
        
        calculatedLayoutInfo = CalculatedLayoutInfo()
        pagesBarView = PagesBarView(barController: self)
        presenter = PagesBarPresenter(view: pagesBarView!)
    }
    
    // All the labels and pages are positioned in here which will be called initially and then after
    // rotations and when setViewControllers is called (via adding subviews)
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // now we can layout the subview with our dimensions decided
        pagesBarView!.calculateAllDimensions()
        pagesBarView!.layoutTitles()
        pagesBarView!.layoutPages()
        presenter?.onLayoutDone()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Obtain the embedded controller
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PagesBarPagesController
            where segue.identifier == "SectionBarPagesEmbedSegue" {
            
            self.pagesViewController = vc
            self.pagesViewController.offsetHasChanged = { (offset: CGFloat) in
                self.presenter?.onPageScrolled(offset)
            }
        }
    }
    
    // When rotating we need to set a flag so we can disable content offset observing
    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        isRotating = true
        coordinator.animateAlongsideTransition(nil, completion: {
            _ in
            self.isRotating = false
        })
    }
    
    internal func setSelectorPosition(index: Int) {
        barSelector.frame = calculatedLayoutInfo.selectorLayoutInfo.selectorFrames[index]
        barSelector.backgroundColor = pagesBarConfig!.selectorColor
    }
    
    internal func onTapLabel(sender: UITapGestureRecognizer) {
        let view = sender.view! as! UILabel
        let index = labels.indexOf(view)
        presenter?.onSelectIndex(index!)
    }
    
    internal func addClickEventToLabel(label: UILabel) {
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapLabel(_:)))
        tapGesture.numberOfTapsRequired = 1
        label.userInteractionEnabled =  true
        label.addGestureRecognizer(tapGesture)
    }
    
    internal func produceLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textAlignment = .Center
        label.textColor = pagesBarConfig?.textColor
        label.font = pagesBarConfig?.textFont
        return label
    }
    
}


// This could live in the controller but kept separated here for clarity
// Note its only internally accessible
class PagesBarView: ViewContract {
    
    weak var pagesBarCtl: PagesBarController!
    weak var calculatedLayoutInfo: CalculatedLayoutInfo!
    
    init(barController: PagesBarController) {
        self.pagesBarCtl = barController
        calculatedLayoutInfo = pagesBarCtl.calculatedLayoutInfo
    }
    
    func addTitle(title: String, index: Int) {
        let label = pagesBarCtl.produceLabel(title)
        pagesBarCtl.labelsScrollView.addSubview(label)
        pagesBarCtl.addClickEventToLabel(label)
        pagesBarCtl.labels.insert(label, atIndex: index)
    }
    
    func addPage(page: UIViewController, index: Int) {
        pagesBarCtl.pagesViewController.addViewController(page, index: index)
    }
    
    func clearTitles() {
        for label in pagesBarCtl.labels {
            label.removeFromSuperview()
        }
        pagesBarCtl.labels.removeAll()
    }
    
    func clearPages() {
        pagesBarCtl.pagesViewController.clearControllers()
    }
    
    func layoutTitles() {
        for (index, label) in pagesBarCtl.labels.enumerate() {
            label.frame = calculatedLayoutInfo.labelLayoutInfo.itemsFrames[index]
        }
        pagesBarCtl.labelsScrollView.contentSize = CGSizeMake(calculatedLayoutInfo.labelLayoutInfo.scrollWidth, 0)
    }
    
    func layoutPages() {
        pagesBarCtl.pagesViewController.layout()
    }
    
    func calculateAllDimensions() {
        let count = pagesBarCtl.presenter!.numberOfItems
        if (count == 0) {return}
        pagesBarCtl.pagesBarConfig?.singlePageBounds = pagesBarCtl.pagesViewController.view.bounds
        pagesBarCtl.pagesBarConfig?.numOfItems = count
        calculatedLayoutInfo.updateAll(pagesBarCtl.pagesBarConfig!)
    }
    
    func getInstantaneousPagePosition() -> Int {
        let offset = pagesBarCtl.pagesViewController.pageScrollView.contentOffset.x
        let calcIndex = calculatedLayoutInfo.calcIndexFromPagePosition(offset)
        return calcIndex
    }
    
    func isLabelVisible(index: Int) -> Bool {
        let selLabelFrame = pagesBarCtl.labels[index].frame
        let visibleRect = pagesBarCtl.labelsScrollView.bounds
        return calculatedLayoutInfo.rectContainsLabelFrame(selLabelFrame, visibleRect: visibleRect)
    }
    
    func moveToPosition(index: Int, inTime: Double) {
        UIView.animateWithDuration(inTime, animations: {
            self.pagesBarCtl.pagesViewController.currentIndex = index
            self.pagesBarCtl.setSelectorPosition(index)
            self.pagesBarCtl.pagesViewController.moveToPosition()
        })
    }
    
    func moveBarForOffset(offset: CGFloat) {
        pagesBarCtl.barSelector.center = calculatedLayoutInfo.calculateDynamicSelectorPosition(offset)
    }
    
    func scrollTitleBarTo(index: Int, inTime: Double) {
        let selLabelFrame = pagesBarCtl.labels[index].frame
        let visibleRect = pagesBarCtl.labelsScrollView.bounds
        let newX = calculatedLayoutInfo.calculateNewLabelsScrollViewPosition(selLabelFrame, visibleRect: visibleRect, scrollViewXOffset: pagesBarCtl.labelsScrollView.contentOffset.x)
        
        UIView.animateWithDuration(inTime, animations: {
            self.pagesBarCtl.labelsScrollView.contentOffset = CGPointMake(newX, 0)
        })
    }
}



