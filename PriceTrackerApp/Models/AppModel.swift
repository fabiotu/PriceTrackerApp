//
//  AppModel.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import SwiftUI

enum AppRoute: Hashable {
    case detail(symbol: String)
}

	enum AppTheme: String, CaseIterable {
    case system, light, dark
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppEnvironment {
    // This server from the brief does not work
    //static let webSocketURL = URL(string: "wss://ws.postman-echo.com/raw")!
    // This is a public and working server instead
    static let webSocketURL = URL(string: "wss://echo.websocket.org")!
}
