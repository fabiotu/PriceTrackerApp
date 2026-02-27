//
//  MockWebSocketService.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import Foundation

actor MockWebSocketService: WebSocketServiceProtocol {
    
    let updatePriceStream: AsyncStream<AssetPriceUpdate>
    let connectionStateStream: AsyncStream<WebSocketConnectionState>
    
    private let updateContinuation: AsyncStream<AssetPriceUpdate>.Continuation
    private let stateContinuation: AsyncStream<WebSocketConnectionState>.Continuation
    
    private var isConnected = false
    private var mockTask: Task<Void, Never>?
    
    init() {
        let (uStream, uCont) = AsyncStream.makeStream(of: AssetPriceUpdate.self)
        self.updatePriceStream = uStream
        self.updateContinuation = uCont
        
        let (sStream, sCont) = AsyncStream.makeStream(of: WebSocketConnectionState.self)
        self.connectionStateStream = sStream
        self.stateContinuation = sCont
        
        self.stateContinuation.yield(.disconnected)
    }
    
    func connect() async {
        guard !isConnected else { return }
        isConnected = true
        stateContinuation.yield(.connected)
        
        mockTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                
                let randomAssets = ["AAPL", "NVDA", "GOOG", "TSLA", "MSFT"]
                let randomUpdate = AssetPriceUpdate(
                    symbol: randomAssets.randomElement()!,
                    price: Double.random(in: 10...1000)
                )
                
                if !Task.isCancelled {
                    self.updateContinuation.yield(randomUpdate)
                }
            }
        }
    }
    
    func disconnect() async {
        isConnected = false
        mockTask?.cancel()
        mockTask = nil
        stateContinuation.yield(.disconnected)
    }
    
    func send(update: AssetPriceUpdate) async throws {
        // simulate network delay
        try? await Task.sleep(for: .milliseconds(100))
        updateContinuation.yield(update)
    }
}
