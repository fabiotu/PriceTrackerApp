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
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
            // .listRowBackground only applies inside a List; the feed is a LazyVStack, so flash via .background
            .background(flashColor)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(asset.identity.symbol)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Shows price details")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("assetRow_\(asset.identity.symbol)")
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

    private var accessibilityValue: String {
        let price = String(format: "%.2f dollars", asset.state.price)
        switch asset.state.trend {
        case .up: return "\(price), trending up"
        case .down: return "\(price), trending down"
        case .flat: return price
        }
    }
}
