//
//  WebSocketService.swift
//  PriceTrackerApp
//
//  Created by Fabiolous on 27/2/26.
//

import Foundation

actor WebSocketService: WebSocketServiceProtocol {
    
    let updatePriceStream: AsyncStream<AssetPriceUpdate>
    let connectionStateStream: AsyncStream<WebSocketConnectionState>
    
    private let updateContinuation: AsyncStream<AssetPriceUpdate>.Continuation
    private let stateContinuation: AsyncStream<WebSocketConnectionState>.Continuation
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    init(url: URL) {
        self.url = url
        let (uStream, uContinuation) = AsyncStream.makeStream(of: AssetPriceUpdate.self)
        self.updatePriceStream = uStream
        self.updateContinuation = uContinuation
        
        let (sStream, sContinuation) = AsyncStream.makeStream(of: WebSocketConnectionState.self)
        self.connectionStateStream = sStream
        self.stateContinuation = sContinuation
        
        self.stateContinuation.yield(.disconnected)
    }
    
    func connect() async {
        guard webSocketTask == nil else { return }
        
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        
        stateContinuation.yield(.connected)
        
        Task {
            await self.listen()
        }
    }
    
    func disconnect() async {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        stateContinuation.yield(.disconnected)
    }
    
    func send(update: AssetPriceUpdate) async throws {
        guard let task = webSocketTask else { return }
        
        let data = try jsonEncoder.encode(update)
        let message = URLSessionWebSocketTask.Message.data(data)
        try await task.send(message)
    }
    
    private func listen() async {
        while let task = webSocketTask {
            do {
                let message = try await task.receive()
                
                switch message {
                case .data(let data):
                    try decodeAndYield(data)
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        try decodeAndYield(data)
                    }
                @unknown default:
                    break
                }
            } catch {
                await disconnect()
                break
            }
        }
    }
    
    private func decodeAndYield(_ data: Data) throws {
        let update = try jsonDecoder.decode(AssetPriceUpdate.self, from: data)
        updateContinuation.yield(update)
    }
}
