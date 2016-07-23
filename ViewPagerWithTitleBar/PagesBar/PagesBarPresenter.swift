//
//  PagesBarPresenter.swift
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import Foundation
import UIKit

protocol PresenterContract {
    func onSelectIndex(index: Int)
    func onPageScrolled(offset: CGFloat)
    func onLayoutDone()
    func onStartDragging()
    func onStopDragging(targetOffset: CGFloat)
    func onDraggingFinished()

}

protocol ViewContract {
    func addTitle(title: String, index: Int)
    func addPage(page: UIViewController, index: Int)
    func clearTitles()
    func clearPages()
    
    func calculateAllDimensions()
    func getInstantaneousPagePosition() -> Int
    func getInstantaneousPagePosition2(currentIndex: Int) -> CGFloat
    func getInstantaneousPagePosition3(offset: CGFloat) -> Int
    func getVisiblePageIndices(currentIndex: Int) -> [Int]
    func isLabelVisible(index: Int) -> Bool
    func layoutTitles()
    func layoutPages()
    func setColorsAndFonts(selectedIndex: Int)
    
    func moveToPosition(index: Int, inTime: Double)
    func moveBarForOffset(offset: CGFloat)
    func scrollTitleBarTo(index: Int, inTime: Double)
    
    func setWillAppear(index: Int)
    func setDidAppear(index: Int)
    func setWillDisappear(index: Int)
    func setDidDisappear(index: Int)
    
}

class PagesBarPresenter : PresenterContract {
    
    var titles : [String] = []
    var controllersAndLabels :[(String, UIViewController)] = [(String, UIViewController)]() { didSet {
            numberOfItems = controllersAndLabels.count
        }
    }
    var selectedIndex = 3
    var nextIndex = 0
    var numberOfItems = 0
    
    var pagesBarConfig: PagesBarConfig
    
    var view: ViewContract
    
    var pagesBarEvents: PagesBarEvents?
    
    var isScrolling: Bool = false

    var visiblePages = [0]

    var didAppearType = 1
    
    init(view:ViewContract) {
        self.view = view
        pagesBarConfig = PagesBarConfig()
    }
    
    // Call this to set the view controllers and and add them to the view hierarchy
    func setViewControllersAndLabels(controllersAndLabels: [(String, UIViewController)]) {
        setViewControllersAndLabels(controllersAndLabels, initialIndex: 0)
    }
    
    func setViewControllersAndLabels(controllersAndLabels: [(String, UIViewController)],
                                     initialIndex: Int) {
        selectedIndex = initialIndex
        self.controllersAndLabels = controllersAndLabels
        let titles = controllersAndLabels.map() { title, ctl in return title }
        let pageControllers = controllersAndLabels.map() { title, ctl in return ctl }
        
        clearAll()
        addTitles(titles)
        addPages(pageControllers)
    }

    func clearAll() {
        view.clearTitles()
        view.clearPages()
    }
    
    private func addTitles(titles: [String]) {
        for (i, title) in titles.enumerate() {
            self.titles.append(title)
            view.addTitle(title, index: i)
        }
    }
    
    private func addPages(pages: [UIViewController]) {
        for (i, page) in pages.enumerate() {
            view.addPage(page, index: i)
        }
    }

    func onSelectIndex(index: Int) {
        if (index != selectedIndex) {
            selectedIndex = index
            view.moveToPosition(index, inTime: 0.2)
            pagesBarEvents?.onPageChanged(index)
        }
    }
    
    func onLayoutDone() {
        if controllersAndLabels.count == 0 {return}
        // now we can layout the subview with our dimensions decided
        view.calculateAllDimensions()
        view.layoutTitles()
        view.layoutPages()
        view.moveToPosition(selectedIndex, inTime: 0)
        scrollTitleBarIfNeeded(selectedIndex)
    }
    
    func onPageScrolled(offset: CGFloat) {
        
        if (numberOfItems < 2) {return}
        let visibleIndices = view.getVisiblePageIndices(0)
        let existingVisibleIndices = Set(self.visiblePages)
        let newVisiblePages = Set(visibleIndices)
        let appearing = newVisiblePages.subtract(existingVisibleIndices)
        let disappearing = existingVisibleIndices.subtract(newVisiblePages)
        if (appearing.count > 0) {print("Appearing is \(appearing)")}
        if (disappearing.count > 0) {print("Disappearing is \(disappearing)")}
        if didAppearType == 0 {
            for item in appearing {
                self.view.setWillAppear(item)
                self.view.setDidAppear(item)
            }
            for item in disappearing {
                self.view.setWillDisappear(item)
                self.view.setDidDisappear(item)
            }
        }
        self.visiblePages = visibleIndices

        let calcIndex = view.getInstantaneousPagePosition()

        let relMovement = view.getInstantaneousPagePosition2(selectedIndex)
//        let next = relMovement > 0 ? selectedIndex+1 : selectedIndex - 1
//        if next != nextIndex && next != selectedIndex && next != -1 && next < numberOfItems && isScrolling {
//            nextIndex = next
//            self.view.setWillAppear(next)
//            print("got in here \(relMovement) \(next) \(selectedIndex)")
//        }
        
//        var calcIndex = selectedIndex
//        //let absNumToMove = abs(numToMove)
//        if relMovement >= 0.5 {
//            //print("moved")
//            calcIndex = nextIndex
//        }
//        else if relMovement <= -0.5 {
//           // print("left moved")
//            //if (selectedIndex != 0) {
//                calcIndex = nextIndex
//            //}
//        }
//        let numToMove = next>0 ? abs(next): abs(next) * -1
//        if (numToMove != 0) {
//            print("moved")
//        }
        //print("rel movement is \(relMovement)")
        print("calcIndex is \(calcIndex)")
        view.moveBarForOffset(offset)
        view.setColorsAndFonts(calcIndex)
        
        if ( (calcIndex != selectedIndex) && (selectedIndex < numberOfItems) ) {
            isScrolling = false
            scrollTitleBarIfNeeded(calcIndex, inTime:0.2)
            //selectedIndex = calcIndex
            nextIndex = selectedIndex
//            self.view.setDidAppear(selectedIndex)
//            pagesBarEvents?.onPageChanged(selectedIndex)
        }
    }
    
    func scrollTitleBarIfNeeded(index: Int, inTime: Double = 0) {
        
        if (index >= controllersAndLabels.count) {return}

        if (!view.isLabelVisible(index)) {
            view.scrollTitleBarTo(index, inTime: inTime)
        }
    }
    
    func onStartDragging() {
        isScrolling = true
    }
    
    func onStopDragging(targetOfset: CGFloat) {
        if didAppearType == 1 {
            let calcIndex = view.getInstantaneousPagePosition3(targetOfset)
            self.view.setWillAppear(calcIndex)
            self.view.setWillDisappear(selectedIndex)
        }
        isScrolling = false
        let relMovement = view.getInstantaneousPagePosition2(selectedIndex)
        print("stop dragging \(relMovement)")
        
    }
    
    
    func onDraggingFinished() {
        let visibleIndices = view.getVisiblePageIndices(0)
        if didAppearType == 1 {
            self.view.setDidAppear(visibleIndices[0])
            self.view.setDidDisappear(selectedIndex)
        }
        selectedIndex = visibleIndices[0]
        pagesBarEvents?.onPageChanged(selectedIndex)

//        let calcIndex = view.getInstantaneousPagePosition()
//        self.view.setDidAppear(calcIndex)
    }
}








