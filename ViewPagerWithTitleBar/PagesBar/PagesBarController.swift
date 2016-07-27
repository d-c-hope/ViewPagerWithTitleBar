//
//  PagesBarController.swift
//
//  Provides the public interface. See the presenter and view for the logic internals
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import UIKit


enum LifecycleType {
    case OnSetViewControllers // willAndDid called when all controllers added
    case OnAppearOnScreen // willAndDid called as the edge of page becomes visible/disappears
    case OnMovedToPage // will called as user stops dragging, did when scrolling completes
}

public struct PagesBarConfig {

    internal var numOfItems: Int = 0

    internal var singlePageBounds: CGRect = CGRect.zero

    var numOfVisibleLabels: Int = 0

    var hMarginWidth: CGFloat = 0

    var textWidth: CGFloat = 0
    var textHeight: CGFloat = 0
    var textColor: UIColor = UIColor.blackColor()
    var selectedTextColor: UIColor = UIColor.blueColor()
    var textFont: UIFont  = UIFont(name: "HelveticaNeue", size: 18.0)!

    var barBackgroundColor: UIColor = UIColor.whiteColor()
    var selectorColor: UIColor = UIColor.blueColor()
}

public protocol PagesBarEvents {
    func onPageChanged(index: Int)
}

public class PagesBarController: UIViewController {

    @IBOutlet internal weak var labelsScrollView: UIScrollView!
    internal var barSelector: UIView!
    internal var labels: [UILabel] = []
    internal var pagesSubsectionController: PagesSubsectionController!

    internal var presenter: PagesBarPresenter? = nil
    internal var pagesBarView: PagesBarView? = nil

    var calculatedLayoutInfo: CalculatedLayoutInfo!
    internal var isRotating = false
    var didAppearType: LifecycleType = LifecycleType.OnSetViewControllers {
        didSet {
            pagesSubsectionController.didAppearType = didAppearType
            presenter?.didAppearType = didAppearType
        }
    }

    public var pagesBarConfig: PagesBarConfig?

    public var currentlySelectedIndex: Int { get {
        return presenter!.selectedIndex
    }}

    public func selectPageAtIndex(index: Int) {
        presenter!.onSelectIndex(index)
    }

    public var pagesBarEvents: PagesBarEvents? {
        get {return presenter?.pagesBarEvents}
        set(pagesBarEvents) {presenter?.pagesBarEvents = pagesBarEvents}
    }

    public static func createPagesBarController() -> PagesBarController {
        let pagesBarController = UIStoryboard(name: "PagesBar",
            bundle: nil).instantiateViewControllerWithIdentifier("PagesBarController")
        // swiftlint:disable force_cast
        return pagesBarController as! PagesBarController // swiftlint:enable force_cast
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
        pagesSubsectionController.presenter = presenter
    }

    // All the labels and pages are positioned in here which will be called initially and then after
    // rotations and when setViewControllers is called (via adding subviews)
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        presenter?.onLayoutDone()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Obtain the embedded controller
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PagesSubsectionController
            where segue.identifier == "SectionBarPagesEmbedSegue" {

            self.pagesSubsectionController = vc
            self.pagesSubsectionController.offsetHasChanged = { (offset: CGFloat) in
                if !self.isRotating {
                    self.presenter?.onPageScrolled(offset)
                }
            }
        }
    }

    // When rotating we need to set a flag so we can disable content offset observing
    override public func viewWillTransitionToSize(size: CGSize,
                    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
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
        // swiftlint:disable force_cast
        let view = sender.view! as! UILabel // swiftlint:enable force_cast
        let index = labels.indexOf(view)
        presenter?.onSelectIndex(index!)
    }

    internal func addClickEventToLabel(label: UILabel) {

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                            action: #selector(onTapLabel(_:)))
        tapGesture.numberOfTapsRequired = 1
        label.userInteractionEnabled =  true
        label.addGestureRecognizer(tapGesture)
    }

    internal func produceLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        return label
    }

}
