//
//  AssetStore.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

@MainActor
@Observable
final class AssetStore {

    private(set) var sortedAssets: [Asset] = []
    private(set) var connectionState: WebSocketConnectionState = .disconnected
    var isFeedActive: Bool = false
    
    private var assetMap: [String: Asset] = [:]
    private var pendingPrices: [String: Double] = [:]

    private let webSocketService: WebSocketServiceProtocol
    private var pingTask: Task<Void, Never>?

    init(webSocketService: WebSocketServiceProtocol) {
        self.webSocketService = webSocketService

        AssetConstants.defaultSymbols.forEach { symbol in
            let initialPrice = Double.random(in: AssetConstants.initialPriceRange)
            assetMap[symbol] = Asset(symbol: symbol, price: initialPrice)
        }
        sortedAssets = assetMap.values.sorted { $0.state.price > $1.state.price }

        Task { await listenToConnectionState() }
        Task { await listenToPriceUpdates() }
        Task { await startRenderLoop() }
    }

    func toggleFeed() {
        isFeedActive ? stopFeed() : startFeed()
    }

    private func startFeed() {
        isFeedActive = true
        Task { await webSocketService.connect() }
        pingTask = Task { await startTimerRequests() }
    }

    private func stopFeed() {
        isFeedActive = false
        pingTask?.cancel()
        pingTask = nil
        Task { await webSocketService.disconnect() }
    }

    private func listenToConnectionState() async {
        for await newState in webSocketService.connectionStateStream {
            guard !Task.isCancelled else { break }
            connectionState = newState
        }
    }

    private func listenToPriceUpdates() async {
        for await batch in webSocketService.updatePriceStream {
            guard !Task.isCancelled else { break }
            for update in batch.updates {
                pendingPrices[update.symbol] = update.price
            }
        }
    }

    private func startRenderLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: AssetConstants.uiRefreshInterval)
            commitPendingUpdates()
        }
    }

    private func commitPendingUpdates() {
        guard !pendingPrices.isEmpty else { return }

        for symbol in pendingPrices.keys {
            assetMap[symbol]?.updating(with: pendingPrices[symbol]!)
        }

        pendingPrices.removeAll(keepingCapacity: true)
        sortedAssets = assetMap.values.sorted { $0.state.price > $1.state.price }
    }

    private func startTimerRequests() async {
        while isFeedActive && !Task.isCancelled {
            try? await Task.sleep(for: .seconds(AssetConstants.refreshIntervalSeconds))
            guard !Task.isCancelled else { break }

            let updates = assetMap.values.map { asset -> AssetPriceUpdate in
                let variance = Double.random(in: AssetConstants.priceVariance)
                let newPrice = asset.state.price * (1 + variance)
                return AssetPriceUpdate(symbol: asset.identity.symbol, price: newPrice)
            }

            try? await webSocketService.send(batch: AssetPriceBatch(updates: updates))
        }
    }
}
