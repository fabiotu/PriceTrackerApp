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
    
    // URL example: stocks://symbol/AAPL
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "stocks",
              url.host == "symbol",
              let symbol = url.pathComponents.last,
              !symbol.isEmpty else { return }
        
        popToRoot()
        navigate(to: .detail(symbol: symbol.uppercased()))
    }
}
