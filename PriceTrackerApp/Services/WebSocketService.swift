//
//  WebSocketService.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import Foundation

actor WebSocketService: WebSocketServiceProtocol {

    let updatePriceStream: AsyncStream<AssetPriceBatch>
    let connectionStateStream: AsyncStream<WebSocketConnectionState>

    private let url: URL
    private var webSocketTask: URLSessionWebSocketTask?
    private var receiveLoopTask: Task<Void, Never>?

    private let priceContinuation: AsyncStream<AssetPriceBatch>.Continuation
    private let statusContinuation: AsyncStream<WebSocketConnectionState>.Continuation

    init(url: URL) {
        self.url = url

        let (priceStream, priceCont) = AsyncStream.makeStream(of: AssetPriceBatch.self)
        let (statusStream, statusCont) = AsyncStream.makeStream(of: WebSocketConnectionState.self)

        self.updatePriceStream = priceStream
        self.connectionStateStream = statusStream
        self.priceContinuation = priceCont
        self.statusContinuation = statusCont
    }

    func connect() async {
        guard webSocketTask == nil else { return }

        statusContinuation.yield(.connected)

        let task = URLSession.shared.webSocketTask(with: url)
        self.webSocketTask = task
        task.resume()

        receiveLoopTask = Task { await self.receiveLoop() }
    }

    func disconnect() async {
        receiveLoopTask?.cancel()
        receiveLoopTask = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        statusContinuation.yield(.disconnected)
    }

    func send(batch: AssetPriceBatch) async throws {
        guard let task = webSocketTask else {
            throw WebSocketError.notConnected
        }
        let data = try JSONEncoder().encode(batch)
        try await task.send(.data(data))
    }

    private func receiveLoop() async {
        while !Task.isCancelled, let task = webSocketTask {
            do {
                let message = try await task.receive()

                do {
                    if let batch = try decode(message: message) {
                        priceContinuation.yield(batch)
                    }
                } catch {
                    print("[WebSocket] Ignored non-decodable message: \(error)")
                }

            } catch {
                print("[WebSocket] Connection lost: \(error)")
                statusContinuation.yield(.disconnected)
                webSocketTask = nil
                break
            }
        }
    }

    private func decode(message: URLSessionWebSocketTask.Message) throws -> AssetPriceBatch? {
        let data: Data
        switch message {
        case .data(let d):
            data = d
        case .string(let s):
            guard let d = s.data(using: .utf8) else { return nil }
            data = d
        @unknown default:
            return nil
        }
        return try JSONDecoder().decode(AssetPriceBatch.self, from: data)
    }
}

enum WebSocketError: Error {
    case notConnected
}
