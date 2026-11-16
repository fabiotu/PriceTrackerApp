//
//  PriceTrackerAppTests.swift
//  PriceTrackerAppTests
//
//  Created by Fabiolous on 26/2/26.
//

import Foundation
import Testing
@testable import PriceTrackerApp

@Suite("Asset model")
struct AssetTests {

    @Test func newAssetStartsFlat() {
        let asset = Asset(symbol: "AAPL", price: 100.0)
        #expect(asset.id == "AAPL")
        #expect(asset.state.price == 100.0)
        #expect(asset.state.trend == .flat)
    }

    @Test(arguments: [
        (105.0, PriceTrend.up),
        (95.0, PriceTrend.down),
        (100.0, PriceTrend.flat)
    ])
    func updatingSetsPriceAndTrend(newPrice: Double, expected: PriceTrend) {
        var asset = Asset(symbol: "AAPL", price: 100.0)
        let before = asset.state.lastUpdated

        asset.updating(with: newPrice)

        #expect(asset.state.price == newPrice)
        #expect(asset.state.trend == expected)
        #expect(asset.state.lastUpdated >= before)
    }

    @Test func consecutiveUpdatesTrackTrendChanges() {
        var asset = Asset(symbol: "AAPL", price: 100.0)
        asset.updating(with: 105.0)
        #expect(asset.state.trend == .up)
        asset.updating(with: 95.0)
        #expect(asset.state.trend == .down)
    }

    @Test func priceBatchRoundTripsThroughJSON() throws {
        let batch = AssetPriceBatch(updates: [
            AssetPriceUpdate(symbol: "AAPL", price: 101.5),
            AssetPriceUpdate(symbol: "NVDA", price: 900.25)
        ])
        let data = try JSONEncoder().encode(batch)
        let decoded = try JSONDecoder().decode(AssetPriceBatch.self, from: data)
        #expect(decoded.updates == batch.updates)
    }
}

@Suite("AssetStore")
@MainActor
struct AssetStoreTests {

    @Test func storeSeedsAllSymbolsSortedByPriceDescending() {
        let store = AssetStore(webSocketService: MockWebSocketService())

        #expect(store.sortedAssets.count == AssetConstants.defaultSymbols.count)
        let prices = store.sortedAssets.map(\.state.price)
        #expect(prices == prices.sorted(by: >))
    }

    @Test func toggleFeedConnectsAndDisconnects() async throws {
        let store = AssetStore(webSocketService: MockWebSocketService())
        #expect(store.isFeedActive == false)

        store.toggleFeed()
        #expect(store.isFeedActive)

        try await Task.sleep(for: .seconds(1.5))
        #expect(store.connectionState == .connected)

        store.toggleFeed()
        #expect(store.isFeedActive == false)
    }
}
