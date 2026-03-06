//
//  AssetModels.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import Foundation

nonisolated
enum AssetConstants {
    static let defaultSymbols = [
        "AAPL", "NVDA", "GOOG", "TSLA", "AMZN", "MSFT", "META", "NFLX",
        "AMD", "INTC", "BA", "DIS", "V", "MA", "JPM", "WMT", "T", "VZ",
        "CSCO", "PEP", "KO", "NKE", "MCD", "SBUX", "IBM"
    ]
    
    static let initialPriceRange: ClosedRange<Double> = 10.0...1000.0
        
    static let priceVariance: ClosedRange<Double> = -0.02...0.02
        
    static let refreshIntervalSeconds: UInt64 = 2
}

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


struct AssetIdentity: Sendable, Hashable {
    let symbol: String
}

struct AssetState: Sendable {
    var price: Double
    var trend: PriceTrend = .flat
    var lastUpdated: Date = Date()
}

struct Asset: Identifiable, Sendable {
    var id: String { identity.symbol }
    let identity: AssetIdentity
    private(set) var state: AssetState

    init(symbol: String, price: Double = 0.0) {
        self.identity = AssetIdentity(symbol: symbol)
        self.state = AssetState(price: price)
    }
    
    mutating func updating(with newPrice: Double) {
        state.trend = newPrice > state.price ? .up : (newPrice < state.price ? .down : .flat)
        state.price = newPrice
        state.lastUpdated = Date()
    }
}

