//
//  RootView.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 8/3/26.
//

import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AssetStore.self) private var store
    @Binding var theme: AppTheme

    var body: some View {
        @Bindable var routerBindable = router

        NavigationStack(path: $routerBindable.path) {
            FeedView(store: store, theme: $theme)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .detail(let symbol):
                        AssetDetailView(store: store, symbol: symbol)
                    }
                }
        }
    }
}
