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
                Text(asset.symbol).font(.headline).fontWeight(.bold)
                Spacer()
                Text(String(format: "$%.2f", asset.price))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                
                Image(systemName: asset.trend == .up ? "arrow.up.circle.fill" : (asset.trend == .down ? "arrow.down.circle.fill" : "minus.circle.fill"))
                    .foregroundColor(asset.trend == .up ? .green : (asset.trend == .down ? .red : .gray))
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(flashColor)
        .onChange(of: asset.lastUpdated) { _, _ in
            guard asset.trend != .flat else { return }
            
            flashColor = asset.trend == .up ? Color.green.opacity(0.4) : Color.red.opacity(0.4)
            
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                withAnimation(.easeOut(duration: 1.0)) {
                    flashColor = .clear
                }
            }
        }
    }
}
