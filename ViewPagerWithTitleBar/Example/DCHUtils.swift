//
//  DCHUtils.swift
//  SectionBar
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import Foundation
import UIKit

class DCHUtils {
    
    
    func makeControllers0() -> [(String, UIViewController)] {
        let controllers :[(String, UIViewController)] =
            []
        return controllers
    }
    
    func makeControllers1() -> [(String, UIViewController)] {
        let controllers :[(String, UIViewController)] =
            [("TitleA", newColoredViewController("A"))
        ]
        return controllers
    }
    
    func makeControllers3() -> [(String, UIViewController)] {
        let controllers :[(String, UIViewController)] =
            [("TitleA", newColoredViewController("A")),
             ("TitleB" , newColoredViewController("B")),
             ("TitleC", newColoredViewController("C"))
        ]
        return controllers
    }
    
    func makeControllers5() -> [(String, UIViewController)] {
        let controllers :[(String, UIViewController)] =
            [("TitleA", newColoredViewController("A")),
             ("TitleB" , newColoredViewController("B")),
             ("TitleC", newColoredViewController("C")),
             ("TitleD", newColoredViewController("D")),
             ("TitleE", newColoredViewController("E"))
        ]
        return controllers
    }
    
    func makeWebControllers() -> [(String, UIViewController)] {
//        let controllers :[(String, UIViewController)] =
//            [("WebA", newWebViewController()),
//             ("WebB" , newWebViewController()),
//             ("WebC", newWebViewController()),
//             
//        ]
        
        var controllers = [(String, UIViewController)]()
        
        for item in [("A", "http://premsc.365dm.com/match-info/362376"),
                     ("B", "http://premsc.365dm.com/squads/362376"),
                     ("C", "http://premsc.365dm.com/report/362376/10507099")] {
            let controller = newWebViewController() as! WebViewController
            controller.name = "Web\(item.0)"
            controller.url = item.1
            controllers.append((controller.name, controller))
        }
        
        return controllers
    }
    
    
    private func newColoredViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("page\(name)")
    }
    
    private func newWebViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("WebA")
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }

    
}