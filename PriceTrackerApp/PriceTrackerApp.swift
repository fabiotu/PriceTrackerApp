//
//  PriceTrackerAppApp.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 26/2/26.
//

import SwiftUI

@main
struct PriceTrackerApp: App {

    @State private var router = AppRouter()
    
    // Store user theme preferences into UserDefaults
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    
    var body: some Scene {
        WindowGroup {
            FeedView(theme: $appTheme)
                .environment(router)
                .preferredColorScheme(appTheme.colorScheme)
                .onOpenURL { url in
                    router.handleDeepLink(url)
                }
        }
    }
}
