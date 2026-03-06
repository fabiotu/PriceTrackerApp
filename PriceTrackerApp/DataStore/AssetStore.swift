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
    
    private(set) var assetMap: [String: Asset] = [:]
    var sortedAssets: [Asset] {
            assetMap.values.sorted { $0.state.price > $1.state.price }
        }
    
    // can be only set internally, avoiding risk of UI changing the state
    private(set) var connectionState: WebSocketConnectionState = .disconnected
    // from UI on/off button
    var isFeedActive: Bool = false
    
    // for dependency injection, to support mock service necessary in testing
    private let webSocketService: WebSocketServiceProtocol
    private var pingTask: Task<Void, Never>?
    
    init(webSocketService: WebSocketServiceProtocol) {
        self.webSocketService = webSocketService
        
        AssetConstants.defaultSymbols.forEach { symbol in
            let initialPrice = Double.random(in: AssetConstants.initialPriceRange)
            assetMap[symbol] = Asset(symbol: symbol, price: initialPrice)
        }

        _ = Task { await listenToConnectionState() }
        _ = Task { await listenToPriceUpdates() }
    }
        
    func toggleFeed() {
        if isFeedActive {
            stopFeed()
        } else {
            startFeed()
        }
    }
    
    private func startFeed() {
        isFeedActive = true
        
        Task { await webSocketService.connect() }
        
        pingTask = Task { await startTimerRequests() }
    }
    
    private func stopFeed() {
        isFeedActive = false
        pingTask?.cancel()
        Task { await webSocketService.disconnect() }
    }
        
    private func listenToConnectionState() async {
        for await newState in await webSocketService.connectionStateStream {
            guard !Task.isCancelled else { break }
            self.connectionState = newState
        }
    }
    
    private func listenToPriceUpdates() async {
        for await update in await webSocketService.updatePriceStream {
            guard !Task.isCancelled else { break }
            applyUpdate(update)
        }
    }
    
    private func applyUpdate(_ update: AssetPriceUpdate, sort: Bool = true) {
        assetMap[update.symbol]?.updating(with: update.price)
    }
    
//    private func sortAssetsByPrice() {
//        assets.sort { $0.state.price > $1.state.price }
//    }
    
    private func startTimerRequests() async {
        while isFeedActive && !Task.isCancelled {
            try? await Task.sleep(for: .seconds(AssetConstants.refreshIntervalSeconds))
            
            guard isFeedActive, !Task.isCancelled else { break }
            Task {
                for asset in assetMap.values {
                    let variance = Double.random(in: AssetConstants.priceVariance)
                    let newPrice = asset.state.price + (asset.state.price * variance)
                    
                    let update = AssetPriceUpdate(symbol: asset.identity.symbol, price: newPrice)
                    
                    try? await webSocketService.send(update: update)
                }
            }
        }
    }
}
