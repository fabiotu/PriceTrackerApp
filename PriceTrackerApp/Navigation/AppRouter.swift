//
//  AppRouter.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class AppRouter {
    var path = NavigationPath()
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    // URL example: pricetracker://symbol/AAPL
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "pricetracker",
              url.host == "symbol",
              let symbol = url.pathComponents.last,
              !symbol.isEmpty else { return }
        
        popToRoot()
        navigate(to: .detail(symbol: symbol.uppercased()))
    }
}
