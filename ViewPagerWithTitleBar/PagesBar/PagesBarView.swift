//
//  PagesBarView.swift
//
//  This could live in the controller but kept separated here for clarity of separation
//  Note its only internally accessible
//
//  Copyright © 2016 David Hope. All rights reserved.
//


import Foundation
import UIKit

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
            self.setColorsAndFonts(index)
        })
    }
    
    func moveBarForOffset(offset: CGFloat) {
        pagesBarCtl.barSelector.center = calculatedLayoutInfo.calculateDynamicSelectorPosition(offset)
    }
    
    func scrollTitleBarTo(index: Int, inTime: Double) {
        let visibleRect = pagesBarCtl.labelsScrollView.bounds
        let newX = calculatedLayoutInfo.calculateNewLabelsScrollViewPosition(index, visibleRect: visibleRect)
        
        UIView.animateWithDuration(inTime, animations: {
            self.pagesBarCtl.labelsScrollView.contentOffset = CGPointMake(newX, 0)
        })
    }
    
    func setColorsAndFonts(selectedIndex: Int) {
        for (index, label) in pagesBarCtl.labels.enumerate() {
            label.textAlignment = .Center
            label.font = pagesBarCtl.pagesBarConfig?.textFont
            if (index == selectedIndex) {
                label.textColor = pagesBarCtl.pagesBarConfig?.selectedTextColor
            } else {
                label.textColor = pagesBarCtl.pagesBarConfig?.textColor
            }
        }
        pagesBarCtl.labelsScrollView.backgroundColor = pagesBarCtl.pagesBarConfig?.barBackgroundColor
    }
}
