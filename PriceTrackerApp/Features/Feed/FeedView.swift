//
//  FeedView.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

struct FeedView: View {
    @Environment(AppRouter.self) private var router
    @Binding var theme: AppTheme
    
    let tempSymbols = ["AAPL", "NVDA", "GOOG", "TSLA", "MSFT"]
    
    var body: some View {

        @Bindable var routerBindable = router
        
        NavigationStack(path: $routerBindable.path) {
            List(tempSymbols, id: \.self) { symbol in
                Button {
                    router.navigate(to: .detail(symbol: symbol))
                } label: {
                    assetRow(symbol: symbol, price: Double.random(in: 10...1000))
                }
                .buttonStyle(.plain)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Live Markets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    themePicker
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
    
    private func assetRow(symbol: String, price: Double) -> some View {
        HStack {
            Text(symbol)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            Text(String(format: "$%.2f", price))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
            
            Image(systemName: "arrow.up.right.circle.fill")
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
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
    FeedView(theme: .constant(.system))
    .environment(AppRouter())
}
