//
//  PriceTrackerAppUITests.swift
//  PriceTrackerAppUITests
//
//  Created by Fabiolous on 26/2/26.
//

import XCTest

@MainActor
final class PriceTrackerUITests: XCTestCase {
    
    func testFeedToDetailNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.navigationBars["Live Markets"].exists)
        
        // The feed is a ScrollView + LazyVStack (not a List), so query rows by accessibility identifier
        let firstRow = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'assetRow_'")).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        firstRow.tap()
        
        XCTAssertTrue(app.navigationBars["Details"].waitForExistence(timeout: 3))
        
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Live Markets"].waitForExistence(timeout: 3))
    }
}
