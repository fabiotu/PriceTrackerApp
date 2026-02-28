//
//  AssetDetailView.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

struct AssetDetailView: View {
    @Environment(AssetStore.self) private var store
    let symbol: String
    
    private var viewModel: AssetDetailViewModel {
        AssetDetailViewModel(store: store, symbol: symbol)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            if let asset = viewModel.asset {
                VStack(spacing: 8) {
                    Text(asset.symbol)
                        .font(.system(size: 60, weight: .black, design: .rounded))
                    
                    HStack {
                        Text(String(format: "$%.2f", asset.price))
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                        
                        Image(systemName: asset.trend == .up ? "arrow.up" : (asset.trend == .down ? "arrow.down" : "minus"))
                            .font(.title)
                            .foregroundColor(asset.trend == .up ? .green : (asset.trend == .down ? .red : .gray))
                    }
                }
                
            } else {
                Text("Asset not found")
            }
            
            Spacer()
        }
        .padding(.top, 50)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
