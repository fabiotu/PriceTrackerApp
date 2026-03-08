//
//  MockWebSocketService.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import Foundation

actor MockWebSocketService: WebSocketServiceProtocol {

    let updatePriceStream: AsyncStream<AssetPriceBatch>
    let connectionStateStream: AsyncStream<WebSocketConnectionState>

    private let priceContinuation: AsyncStream<AssetPriceBatch>.Continuation
    private let statusContinuation: AsyncStream<WebSocketConnectionState>.Continuation
    private var simulationTask: Task<Void, Never>?

    var symbols: [String] = AssetConstants.defaultSymbols
    var tickSequence: [AssetPriceBatch] = []
    var tickInterval: Duration = .seconds(2)

    init() {
        let (priceStream, priceCont) = AsyncStream.makeStream(of: AssetPriceBatch.self)
        let (statusStream, statusCont) = AsyncStream.makeStream(of: WebSocketConnectionState.self)

        self.updatePriceStream = priceStream
        self.connectionStateStream = statusStream
        self.priceContinuation = priceCont
        self.statusContinuation = statusCont
    }

    func connect() async {
        statusContinuation.yield(.connected)
        simulationTask = Task { await self.simulationLoop() }
    }

    func disconnect() async {
        simulationTask?.cancel()
        simulationTask = nil
        statusContinuation.yield(.disconnected)
    }

    func send(batch: AssetPriceBatch) async throws {
        priceContinuation.yield(batch)
    }

    private func simulationLoop() async {
        var index = 0
        while !Task.isCancelled {
            try? await Task.sleep(for: tickInterval)
            guard !Task.isCancelled else { break }

            let batch: AssetPriceBatch = tickSequence.isEmpty
                ? randomBatch()
                : tickSequence[index % tickSequence.count]

            priceContinuation.yield(batch)
            index += 1
        }
    }

    private func randomBatch() -> AssetPriceBatch {
        let updates = symbols.map { symbol in
            AssetPriceUpdate(
                symbol: symbol,
                price: Double.random(in: AssetConstants.initialPriceRange)
            )
        }
        return AssetPriceBatch(updates: updates)
    }
}
