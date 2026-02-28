//
//  FeedViewModel.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

@MainActor
@Observable
final class FeedViewModel {
    private let store: AssetStore
    
    // dependency injection
    init(store: AssetStore) {
        self.store = store
    }
    
    var assets: [Asset] { store.assets }
    var isFeedActive: Bool { store.isFeedActive }
    
    var connectionStatusText: String {
        store.connectionState == .connected ? "Connected" : "Disconnected"
    }
    
    var connectionStatusColor: Color {
        store.connectionState == .connected ? .green : .red
    }
    
    func toggleFeed() {
        store.toggleFeed()
    }
}
