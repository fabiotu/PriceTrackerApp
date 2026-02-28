//
//  AssetModels.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import Foundation

// without this directive the compiler complains with warning. This way we can use it both from main actor and background threads
// the compiler thinks that this belongs to the MainActor
nonisolated
struct AssetPriceUpdate: Codable, Sendable, Equatable {
    let symbol: String
    let price: Double
}

enum WebSocketConnectionState: Sendable {
    case connected
    case disconnected
}

enum PriceTrend: Sendable {
    case up
    case down
    case flat
}

// using a struct here ensures allocation on the stack which is super fast and allows SwiftUI to immediately change the UI with new copy of data
struct Asset: Identifiable, Equatable, Sendable {
    let id: String
    let symbol: String
    let price: Double
    let trend: PriceTrend
    let lastUpdated: Date // for flashing effect
    
    init(symbol: String, price: Double = 0.0) {
        self.id = symbol
        self.symbol = symbol
        self.price = price
        self.trend = .flat
        self.lastUpdated = Date()
    }
    
    private init(symbol: String, price: Double, trend: PriceTrend, lastUpdated: Date) {
        self.id = symbol
        self.symbol = symbol
        self.price = price
        self.trend = trend
        self.lastUpdated = lastUpdated
    }
    
    func updating(with newPrice: Double) -> Asset {
        let newTrend: PriceTrend = newPrice > self.price ? .up : (newPrice < self.price ? .down : .flat)
        
        return Asset(
            symbol: self.symbol,
            price: newPrice,
            trend: newTrend,
            lastUpdated: Date() // needed later for flashing effect
        )
    }
}
