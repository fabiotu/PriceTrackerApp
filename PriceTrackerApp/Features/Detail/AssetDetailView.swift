//
//  AssetDetailView.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

struct AssetDetailView: View {
    let symbol: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(symbol)
                .font(.system(size: 60, weight: .black, design: .rounded))
            
            // TEMP value
            Text("10000")
                .foregroundColor(.secondary)
        }
        .navigationTitle(symbol)
        .navigationBarTitleDisplayMode(.inline)
    }
}
