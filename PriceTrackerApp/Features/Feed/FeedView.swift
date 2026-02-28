//
//  FeedView.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

struct FeedView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AssetStore.self) private var store
    @Binding var theme: AppTheme
    
    private var viewModel: FeedViewModel { FeedViewModel(store: store) }
        
    var body: some View {

        @Bindable var routerBindable = router
        
        NavigationStack(path: $routerBindable.path) {
            List(viewModel.assets) { asset in
                Button {
                    router.navigate(to: .detail(symbol: asset.symbol))
                } label: {
                    AssetRowView(asset: asset)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Live Markets")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Circle()
                            .fill(viewModel.connectionStatusColor)
                            .frame(width: 10, height: 10)
                        Text(viewModel.connectionStatusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button(viewModel.isFeedActive ? "Stop" : "Start") {
                            viewModel.toggleFeed()
                        }
                        .fontWeight(.bold)
                        
                        themePicker
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .detail(let symbol):
                    AssetDetailView(symbol: symbol)
                }
            }
        }
    }
    
    private var themePicker: some View {
        Menu {
            Picker("Theme", selection: $theme) {
                Text("System").tag(AppTheme.system)
                Text("Light").tag(AppTheme.light)
                Text("Dark").tag(AppTheme.dark)
            }
        } label: {
            Image(systemName: "circle.lefthalf.filled")
                .imageScale(.large)
        }
    }
}


#Preview {
    let mockService = MockWebSocketService()
    let mockStore = AssetStore(webSocketService: mockService)
    
    return FeedView(theme: .constant(.system))
        .environment(AppRouter())
        .environment(mockStore)
}
