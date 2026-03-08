//
//  WebSocketServiceProtocol.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import Foundation

protocol WebSocketServiceProtocol: Sendable {
    func connect() async
    func disconnect() async
    func send(batch: AssetPriceBatch) async throws
    var updatePriceStream: AsyncStream<AssetPriceBatch> { get }
    var connectionStateStream: AsyncStream<WebSocketConnectionState> { get }
}
