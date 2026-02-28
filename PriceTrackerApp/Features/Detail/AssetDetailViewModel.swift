//
//  AssetDetailViewModel.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

@MainActor
@Observable
final class AssetDetailViewModel {
    private let store: AssetStore
    let symbol: String
    
    init(store: AssetStore, symbol: String) {
        self.store = store
        self.symbol = symbol
    }
    
    var asset: Asset? {
        store.assets.first { $0.symbol == symbol }
    }
}
