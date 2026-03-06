//
//  AssetRowView.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

struct AssetRowView: View {
    let asset: Asset
    let onTap: () -> Void
    @State private var flashColor: Color = .clear
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(asset.identity.symbol).font(.headline).fontWeight(.bold)
                Spacer()
                Text(String(format: "$%.2f", asset.state.price))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                
                Image(systemName: asset.state.trend == .up ? "arrow.up.circle.fill" : (asset.state.trend == .down ? "arrow.down.circle.fill" : "minus.circle.fill"))
                    .foregroundColor(asset.state.trend == .up ? .green : (asset.state.trend == .down ? .red : .gray))
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(flashColor)
        .onChange(of: asset.state.lastUpdated) { _, _ in
            guard asset.state.trend != .flat else { return }
            
            flashColor = asset.state.trend == .up ? Color.green.opacity(0.4) : Color.red.opacity(0.4)
            
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                withAnimation(.easeOut(duration: 1.0)) {
                    flashColor = .clear
                }
            }
        }
    }
}
