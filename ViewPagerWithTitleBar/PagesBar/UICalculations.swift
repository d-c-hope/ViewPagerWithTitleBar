//
//  UICalculations.swift
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import Foundation
import UIKit


struct PagesLayoutInfo {
    var boundsWidth: CGFloat = 0
    var boundsHeight: CGFloat = 0
}

struct LabelsScrollLayoutInfo {
    
    var singleTextWidth: CGFloat = 0
    
    var visibleTextWidth: CGFloat = 0
    var completeTextWidth: CGFloat = 0
    
    var totalMarginWidth: CGFloat = 0
    var labelSpacing: CGFloat = 0
    
    var completeSpacingWidth: CGFloat = 0
    var scrollWidth: CGFloat = 0
    
    var itemsFrames: [CGRect] = [CGRect]()
    var itemsCentres: [CGPoint] = [CGPoint]()
    var centresGap: CGFloat = 0
}


// The possible locations for the selector (for when its static anyway)
struct SelectorScrollLayoutInfo {
    var selectorFrames: [CGRect] = [CGRect]()
    var selectorCentres: [CGPoint] = [CGPoint]()
    var maxMinCentresGap: CGFloat = 0
}


class CalculatedLayoutInfo {
    
    var pagerConstants: PagesBarConfig!
    
    var labelLayoutInfo: LabelsScrollLayoutInfo!
    var selectorLayoutInfo: SelectorScrollLayoutInfo!
    var pagesLayoutInfo: PagesLayoutInfo!
    
    func updateAll(pagerConstants: PagesBarConfig) {
        self.pagerConstants = pagerConstants
        self.calculateLabelLayoutInfo()
        self.calculatePagesLayoutInfo()
        self.calculateSelectorLayoutInfo()
    }
    
    func calculatePagesLayoutInfo() {
        var layoutInfo = PagesLayoutInfo()
        layoutInfo.boundsWidth = pagerConstants.singlePageBounds.size.width
        layoutInfo.boundsHeight = pagerConstants.singlePageBounds.size.width
        
        self.pagesLayoutInfo = layoutInfo
    }
    
    func calculateLabelLayoutInfo() {
        
        var layoutInfo = LabelsScrollLayoutInfo()
        
        let boundsWidth = pagerConstants.singlePageBounds.size.width
        
        layoutInfo.visibleTextWidth = pagerConstants.textWidth * CGFloat(pagerConstants.numOfVisibleLabels);
        layoutInfo.completeTextWidth = pagerConstants.textWidth * CGFloat(pagerConstants.numOfItems)
        
        layoutInfo.totalMarginWidth = pagerConstants.hMarginWidth * CGFloat(2)
        layoutInfo.labelSpacing = (boundsWidth - layoutInfo.visibleTextWidth - layoutInfo.totalMarginWidth)
                            / CGFloat(pagerConstants.numOfVisibleLabels - 1)
        
        layoutInfo.completeSpacingWidth = layoutInfo.labelSpacing * CGFloat(pagerConstants.numOfItems - 1)
        layoutInfo.scrollWidth = CGFloat(layoutInfo.totalMarginWidth + layoutInfo.completeTextWidth + layoutInfo.completeSpacingWidth)
        
        for i in 0...pagerConstants.numOfItems-1 {
            let x = pagerConstants.hMarginWidth +
                ((pagerConstants.textWidth + layoutInfo.labelSpacing) * CGFloat(i))
            let y: CGFloat = 15
            let centreX = x + (pagerConstants.textWidth / 2)
            let centreY = y + (pagerConstants.textHeight / 2)
            layoutInfo.itemsFrames.append(CGRectMake(CGFloat(x),CGFloat(y),CGFloat(pagerConstants.textWidth), CGFloat(20)))
            layoutInfo.itemsCentres.append(CGPointMake(centreX, centreY))
        }
        
        layoutInfo.centresGap = pagerConstants.textWidth + layoutInfo.labelSpacing
        
        self.labelLayoutInfo = layoutInfo
    }
    
    func calculateSelectorLayoutInfo() {
        
        let selectorWidth: CGFloat = 40
        let selectorHeight: CGFloat = 5
        let selectorLabelGap: CGFloat = 22
        
        var layoutInfo = SelectorScrollLayoutInfo()
        
        for labelCentre in labelLayoutInfo.itemsCentres {
            let selCentre = CGPointMake(labelCentre.x, labelCentre.y + selectorLabelGap)
            let frameX = selCentre.x - (selectorWidth / 2)
            let frameY = selCentre.y - (selectorHeight / 2)
            let selFrame = CGRectMake(frameX, frameY, selectorWidth, selectorHeight)
            
            layoutInfo.selectorCentres.append(selCentre)
            layoutInfo.selectorFrames.append(selFrame)
        }
        
        layoutInfo.maxMinCentresGap = layoutInfo.selectorCentres[layoutInfo.selectorCentres.count-1].x - layoutInfo.selectorCentres[0].x
        
        self.selectorLayoutInfo = layoutInfo
    }
    
    func calculateDynamicSelectorPosition(offset: CGFloat) -> CGPoint {
        
        let ratio = offset / (pagesLayoutInfo.boundsWidth * CGFloat(pagerConstants.numOfItems-1))
        let centres = selectorLayoutInfo.selectorCentres
        let x = centres[0].x + (selectorLayoutInfo.maxMinCentresGap * ratio)
        return CGPointMake(x, centres[0].y)
    }
    
    func calcIndexFromPagePosition(offset: CGFloat) -> Int {
        let boundsWidth = pagesLayoutInfo.boundsWidth
        // once we pass half width we are now on the next page
        let calcIndex = Int( (offset+(boundsWidth/2)) / boundsWidth)
        return calcIndex;
    }

    func rectContainsLabelFrame(selLabelFrame: CGRect, visibleRect: CGRect) -> Bool {
        
        if (CGRectContainsRect(visibleRect, selLabelFrame)) { return true }
        else { return false }
    }
    
    // Calculates an offset for the scrollview containing labels to ensure selected label is visible
    func calculateNewLabelsScrollViewPosition(selLabelIndex: Int, visibleRect: CGRect) -> CGFloat {
        
        let selLabelFrame = self.labelLayoutInfo.itemsFrames[selLabelIndex]
        var leftMostVisibleRect = CGRectMake(0, visibleRect.minY, visibleRect.width, visibleRect.height)
        let labelsSpacing = labelLayoutInfo.centresGap
        
        func getOffsetRect(i: Int, letMostVisibleRect: CGRect) -> CGRect {
            let offset = CGFloat(i)*labelsSpacing
            return letMostVisibleRect.offsetBy(dx: offset, dy: 0)
        }
        
        var visibleOffsets = [CGFloat]()
        for (i, _) in self.labelLayoutInfo.itemsFrames.enumerate() {
            let newVisibleRect = getOffsetRect(i, letMostVisibleRect: leftMostVisibleRect)
            if rectContainsLabelFrame(selLabelFrame, visibleRect: newVisibleRect) {
                visibleOffsets.append(newVisibleRect.minX)
            }
        }
        
        if selLabelFrame.minX < visibleRect.minX {
            return visibleOffsets.last!
        } else {
            return visibleOffsets.first!
        }
    }

}






