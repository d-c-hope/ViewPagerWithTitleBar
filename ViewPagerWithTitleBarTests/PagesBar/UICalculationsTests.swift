//
//  UICalculationsTests.swift
//
//  Copyright © 2016 David Hope. All rights reserved.
//

import XCTest
@testable import ViewPagerWithTitleBar


class UICalculationsTest: XCTestCase {
    
    func testCalculatePagesLayoutInfo() {
        let calc = CalculatedLayoutInfo()
        var pagerConfig = PagesBarConfig()
        pagerConfig.singlePageBounds = CGRectMake(10, 15, 5, 8)
        calc.pagerConstants = pagerConfig
        calc.calculatePagesLayoutInfo()
        
        XCTAssertEqual(calc.pagesLayoutInfo.boundsWidth, 5)
        XCTAssertEqual(calc.pagesLayoutInfo.boundsHeight, 8)
    }
}
