//
//  PriceTrackerAppUITests.swift
//  PriceTrackerAppUITests
//
//  Created by Fabiolous on 26/2/26.
//

import XCTest

final class PriceTrackerUITests: XCTestCase {
    
    func testFeedToDetailNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.navigationBars["Live Markets"].exists)
        
        let firstRow = app.collectionViews.buttons.firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        firstRow.tap()
        
        XCTAssertTrue(app.navigationBars["Details"].exists)
        
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Live Markets"].exists)
    }
}
