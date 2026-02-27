//
//  WebSocketServiceProtocol.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import Foundation

protocol WebSocketServiceProtocol: Sendable {
    var updatePriceStream: AsyncStream<AssetPriceUpdate> { get async }
    var connectionStateStream: AsyncStream<WebSocketConnectionState> { get async }
    
    func connect() async
    func disconnect() async
    func send(update: AssetPriceUpdate) async throws
}
