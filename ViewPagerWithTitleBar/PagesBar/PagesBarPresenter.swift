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
    func onDraggingLetGo(targetOffset: CGFloat)
    func onDraggingScrollingComplete()

}

protocol ViewContract {
    func addTitle(title: String, index: Int)
    func addPage(page: UIViewController, index: Int)
    func clearTitles()
    func clearPages()

    func calculateAllDimensions()

    func getInstantaneousPagePosition() -> Int
    func getInstantaneousPagePosition(offset: CGFloat) -> Int
    func getVisiblePageIndices() -> [Int]

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

class PagesBarPresenter: PresenterContract {

    var titles: [String] = []
    var controllersAndLabels: [(String, UIViewController)] = [(String, UIViewController)]() {
        didSet {
            numberOfItems = controllersAndLabels.count
        }
    }
    var selectedIndex = 3
    var numberOfItems = 0
    var visiblePageIndices = [0]

    var didAppearType: LifecycleType = LifecycleType.OnSetViewControllers

    var pagesBarConfig: PagesBarConfig

    var view: ViewContract

    var pagesBarEvents: PagesBarEvents?

    init(view: ViewContract) {
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
        if index != selectedIndex {
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

        func getVisibleAppearingAndDisappearingPages() -> ([Int], [Int], [Int]) {
            let visiblePageIndices = Set(view.getVisiblePageIndices())
            let existingVisibleIndices = Set(self.visiblePageIndices)
            let appearing = visiblePageIndices.subtract(existingVisibleIndices)
            let disappearing = existingVisibleIndices.subtract(visiblePageIndices)
            return (Array(visiblePageIndices), Array(appearing), Array(disappearing))
        }

        func triggerPageLifecycleCalls(appearing: [Int], disappearing: [Int]) {
            for item in appearing {
                self.view.setWillAppear(item)
                self.view.setDidAppear(item)
            }
            for item in disappearing {
                self.view.setWillDisappear(item)
                self.view.setDidDisappear(item)
            }
        }

        if numberOfItems < 2 {
            return
        }

        let (visibleIndices, appearing, disappearing) = getVisibleAppearingAndDisappearingPages()
        if didAppearType == LifecycleType.OnAppearOnScreen {
            triggerPageLifecycleCalls(appearing, disappearing: disappearing)
        }
        self.visiblePageIndices = visibleIndices

        let calcIndex = view.getInstantaneousPagePosition()
        view.moveBarForOffset(offset)
        view.setColorsAndFonts(calcIndex)
        if (calcIndex != selectedIndex) && (selectedIndex < numberOfItems) {
            scrollTitleBarIfNeeded(calcIndex, inTime:0.2)
        }
    }

    func scrollTitleBarIfNeeded(index: Int, inTime: Double = 0) {
        if index >= controllersAndLabels.count {
            return
        }

        if !view.isLabelVisible(index) {
            view.scrollTitleBarTo(index, inTime: inTime)
        }
    }

    func onDraggingLetGo(targetOffset: CGFloat) {
        if didAppearType == LifecycleType.OnMovedToPage {
            let calcIndex = view.getInstantaneousPagePosition(targetOffset)
            self.view.setWillAppear(calcIndex)
            self.view.setWillDisappear(selectedIndex)
        }
    }

    func onDraggingScrollingComplete() {
        let visibleIndices = view.getVisiblePageIndices()
        if didAppearType == LifecycleType.OnMovedToPage {
            self.view.setDidAppear(visibleIndices[0])
            self.view.setDidDisappear(selectedIndex)
        }
        selectedIndex = visibleIndices[0]
        pagesBarEvents?.onPageChanged(selectedIndex)

    }
}
