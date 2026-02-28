//
//  PriceTrackerAppTests.swift
//  PriceTrackerAppTests
//
//  Created by Fabiolous on 26/2/26.
//

import XCTest
@testable import PriceTrackerApp

@MainActor
final class AssetTests: XCTestCase {
    
    func testAssetImmutabilityAndTrend() {
        let initialAsset = Asset(symbol: "AAPL", price: 100.0)
        XCTAssertEqual(initialAsset.trend, .flat)
        
        let upAsset = initialAsset.updating(with: 105.0)
        XCTAssertEqual(upAsset.price, 105.0)
        XCTAssertEqual(upAsset.trend, .up)
        XCTAssertNotEqual(initialAsset.lastUpdated, upAsset.lastUpdated)
        
        let downAsset = upAsset.updating(with: 95.0)
        XCTAssertEqual(downAsset.trend, .down)
    }
    
    func testStoreReceivesUpdatesFromMockService() async throws {
        let mockService = MockWebSocketService()
        let store = AssetStore(webSocketService: mockService)
        
        XCTAssertFalse(store.isFeedActive)
        
        store.toggleFeed()
        XCTAssertTrue(store.isFeedActive)
        
        try await Task.sleep(for: .seconds(1.5))
        
        XCTAssertEqual(store.connectionState, .connected)
        
        store.toggleFeed()
    }
}
