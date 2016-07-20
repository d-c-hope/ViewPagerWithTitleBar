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
    
    
    private func newColoredViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("page\(name)")
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