//
//  MainWebViewController.swift
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import UIKit


class MainWebViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    var pagesBarController: PagesBarController!
    
    var originalHeaderFrame = CGRectZero
    var originalContainerFrame = CGRectZero
    var startingY : CGFloat = 0
    
    var isScrolling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var pagesBarConfig = PagesBarConfig()
        pagesBarConfig.numOfVisibleLabels = 3
        pagesBarConfig.hMarginWidth = 35
        pagesBarConfig.textWidth = 60
        pagesBarConfig.textHeight = 20
        
        class PageChanged: PagesBarEvents {
            var outer: MainWebViewController? = nil
            private func onPageChanged(index: Int) {
                print("page changed to \(index)")
                outer!.getInitials2()
            }
        }
        
        // Some demo items
        let viewControllersAndLabels = DCHUtils().makeWebControllers()
        pagesBarController.pagesBarConfig = pagesBarConfig
        pagesBarController.setViewControllersAndLabels(viewControllersAndLabels)
        let pageChanged = PageChanged()
        pagesBarController.pagesBarEvents = pageChanged
        pageChanged.outer = self
        
        
        
        for (title, controller) in viewControllersAndLabels {
            let webController = controller as! WebViewController
            webController.contentOffsetCallback = { (contentOffset: CGFloat, scrollView: UIScrollView) in
                
                if (self.isScrolling) {
                    self.whenScrolling(contentOffset)
                }
            }
            
            webController.hasBegunScrolling = { (scrollView: UIScrollView) in
                print("has begun scrolling")
                self.isScrolling = true
                //self.originalHeaderFrame = self.headerView.frame
                //self.startingY = self.originalHeaderFrame.minY
            }
            
            webController.hasEndedScrolling = { (scrollView: UIScrollView) in
                print("has ended scrolling")
                self.isScrolling = false
            }
        }
    }
    
    
    
    func whenScrolling(contentOffset: CGFloat) {
        // header frame dependes on the offset but also where  the frame started on
        // page load. We want to move relatively when we scroll, not absolutely to scroll position
        let potentialFrameY = -contentOffset - -self.startingY
        print(startingY)
        //var frameY : CGFloat = 0
        var frameY = checkY(potentialFrameY)
        
        // when at the top but not with a full header - usually when changing tabs to
        // a new one where the bounds is at the top
        if (contentOffset < 0) && (frameY < 0) {
            self.startingY -= contentOffset
            if (self.startingY < -80) {self.startingY = -80}
            print("startingY is \(self.startingY)")
            frameY += contentOffset
        }
        
        
        //print("before frameY is \(potentialFrameY) offset is \(contentOffset) starting is \(startingY)")
        frameY = checkY(potentialFrameY)

        //print("frameY is \(frameY) offset is \(contentOffset)")
        
        // if its a big change animate - this is normally when the menu is visible but you go
        // to a screen scrolled down significantly, so it hides on any scrolling
        let existing = self.headerView.frame.minY
        let frameChange = existing - frameY
        let height = self.originalContainerFrame.height-frameY+startingY
        if (frameChange > 20) {
            UIView.animateWithDuration(0.2, animations: {
                self.updateFrame(frameY, hei:height)
            })
        }
        else {
            
            updateFrame(frameY, hei:height)
        }
        

    }

    
    func updateFrame(frameY: CGFloat, hei: CGFloat) {
        print("\(frameY)   \(self.originalContainerFrame.height)")
        let newHeaderFrame = CGRect(x: 0,
                                    y: frameY,
                                    width:self.originalHeaderFrame.width,
                                    height:self.originalHeaderFrame.height)
        self.headerView.frame = newHeaderFrame
        
        let newContainerFrame = CGRect(x: 0,
                                       y: frameY + self.originalHeaderFrame.height,
                                       width:self.originalContainerFrame.width,
                                       height:hei)
        self.containerView.frame = newContainerFrame

    }

    func checkY(potentialFrameY: CGFloat) -> CGFloat {
        if ((potentialFrameY <= 0) && (potentialFrameY >= -80)) {
            return potentialFrameY
        }
        else if (potentialFrameY < -80) {
            return CGFloat(-80)
        }
        else {
            return 0;
        }
    }
    
    
    func getInitials() {
        originalHeaderFrame = headerView.frame
        originalContainerFrame = containerView.frame
        startingY = self.originalHeaderFrame.minY
    }

    func getInitials2() {
        let originalHeaderFrame = headerView.frame
        let originalContainerFrame = containerView.frame
        startingY = originalHeaderFrame.minY
    }

    
    override func viewDidLayoutSubviews() {
        getInitials()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PagesBarController
            where segue.identifier == "mainPagesEmbed" {
            
            pagesBarController = vc
        }
    }
    
}



