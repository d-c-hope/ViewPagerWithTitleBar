//
//  MainViewController.swift
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    class PageChanged: PagesBarEvents {
        internal func onPageChanged(index: Int) {
            print("page changed to \(index)")
        }
    }

    var pagesBarController: PagesBarController!

    override func viewDidLoad() {
        super.viewDidLoad()

        var pagesBarConfig = PagesBarConfig()
        pagesBarConfig.numOfVisibleLabels = 3
        pagesBarConfig.hMarginWidth = 35
        pagesBarConfig.textWidth = 60
        pagesBarConfig.textHeight = 20

        // Some demo items
        let viewControllersAndLabels = DCHUtils().makeControllers5()
        pagesBarController.pagesBarConfig = pagesBarConfig
        pagesBarController.setViewControllersAndLabels(viewControllersAndLabels)
        pagesBarController.pagesBarEvents = PageChanged()
        //presenter?.setViewControllers(viewControllersAndLAbels)

        // Testing a change after 5 seconds
        //        DCHUtils().delay(5) {
        //            let viewControllersAndLAbels = DCHUtils().makeControllers()
        //            self.presenter?.setViewControllers(viewControllersAndLAbels)
        //        }

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
