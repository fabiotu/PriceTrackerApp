//
//  FeedView.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

struct FeedView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel: FeedViewModel
    @Binding var theme: AppTheme

    init(store: AssetStore, theme: Binding<AppTheme>) {
        _viewModel = State(initialValue: FeedViewModel(store: store))
        _theme = theme
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.assets) { asset in
                    AssetRowView(asset: asset) {
                        router.navigate(to: .detail(symbol: asset.identity.symbol))
                    }
                    .padding(.horizontal, 16)
                    .frame(minHeight: 52)

                    Divider()
                        .padding(.leading, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Live Markets")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                connectionToolbarItem
            }
            ToolbarItem(placement: .topBarTrailing) {
                themePicker
            }
        }
    }

    private var connectionToolbarItem: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.connectionStatusColor)
                    .frame(width: 10, height: 10)

                Text(viewModel.connectionStatusText)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .fixedSize()
            }

            Button(viewModel.isFeedActive ? "Stop" : "Start") {
                viewModel.toggleFeed()
            }
            .fontWeight(.bold)
            .tint(viewModel.isFeedActive ? .red : .blue)
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

    return NavigationStack {
        FeedView(store: mockStore, theme: .constant(.system))
    }
    .environment(AppRouter())
    .environment(mockStore)
}
