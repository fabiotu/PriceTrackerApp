//
//  AssetModels.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import Foundation

// without this compiler complains with warning. This way we can use it both from main actor and background threads
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
