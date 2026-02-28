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
    
    // can be set only internally, avoiding risk of UI changing the state
    private(set) var assets: [Asset] = []
    private(set) var connectionState: WebSocketConnectionState = .disconnected
    // from UI on/off button
    var isFeedActive: Bool = false
    
    // for dependency injection, to support mock service necessary in testing
    private let webSocketService: WebSocketServiceProtocol
    private var pingTask: Task<Void, Never>?
    
    let defaultSymbols = [
        "AAPL", "NVDA", "GOOG", "TSLA", "AMZN", "MSFT", "META", "NFLX",
        "AMD", "INTC", "BA", "DIS", "V", "MA", "JPM", "WMT", "T", "VZ",
        "CSCO", "PEP", "KO", "NKE", "MCD", "SBUX", "IBM"
    ]
    
    init(webSocketService: WebSocketServiceProtocol) {
        self.webSocketService = webSocketService
        
        self.assets = defaultSymbols.map { symbol in
            Asset(symbol: symbol, price: Double.random(in: 10...1000))
        }

        let connectionStateTask = Task { await listenToConnectionState() }
        let updateTask = Task { await listenToPriceUpdates() }
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
        if let index = assets.firstIndex(where: { $0.symbol == update.symbol }) {
            assets[index] = assets[index].updating(with: update.price)
        }
        if sort {
            sortAssetsByPrice()
        }
    }
    
    private func sortAssetsByPrice() {
        assets.sort { $0.price > $1.price }
    }
    
    private func startTimerRequests() async {
        while isFeedActive && !Task.isCancelled {
            // Wait 2 seconds
            try? await Task.sleep(for: .seconds(2))
            
            guard isFeedActive, !Task.isCancelled else { break }
            
            for asset in assets {
                let variance = Double.random(in: -0.02...0.02)
                let newPrice = asset.price + (asset.price * variance)
                
                let update = AssetPriceUpdate(symbol: asset.symbol, price: newPrice)
                
                // sequencial
                //try? await webSocketService.send(update: update)
                // concurrent
                Task {
                    try? await webSocketService.send(update: update)
                }
            }
        }
    }
}
