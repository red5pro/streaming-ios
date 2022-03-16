//
//  WebSocketProvider.swift
//  R5ProTestbed
//
//  Created by Todd Anderson on 2/21/22.
//  Copyright © 2022 Infrared5. All rights reserved.
//
import Foundation
import Starscream

extension String {
    var parseJSONString: AnyObject? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
    }
}

protocol WebSocketProviderDelegate: AnyObject {
    func webSocketDidConnect(_ webSocket: WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveMessage message: String)
}

/*
 Starscream implementation of WebSocket.
 */
class WebSocketProvider: Starscream.WebSocketDelegate {
    
    var delegate: WebSocketProviderDelegate?
    private var isSocketConnected: Bool = false
    private var socket: WebSocket?
        
    init(url: URL) {
        debugPrint("[Starscream] WebSocketProvider")
        self.socket = WebSocket(request: URLRequest(url: url))
        self.socket!.delegate = self
    }
        
    func connect() {
        self.socket!.connect()
    }
    
    func write(message: String) {
        self.socket!.write(data: Data(message.utf8))
    }
    
    func disconnect() {
        if (self.socket != nil) {
            self.isSocketConnected = false
            self.socket!.delegate = nil
            self.socket!.disconnect()
            self.socket?.forceDisconnect()
        }
        self.socket = nil
    }
    
    func isConnected() -> Bool {
        return isSocketConnected
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(let headers):
                self.isSocketConnected = true
                self.delegate?.webSocketDidConnect(self)
            case .disconnected(let reason, let code):
                self.isSocketConnected = false
                self.delegate?.webSocketDidDisconnect(self)
            case .text(let string):
                debugPrint("[Starscream] message: \(string)")
                self.delegate?.webSocket(self, didReceiveMessage: string)
            case .binary(let data):
                print("Received data: \(data.count)")
                debugPrint("[Starscream] data: \(data.debugDescription)")
                self.delegate?.webSocket(self, didReceiveMessage: data.debugDescription)
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                self.isSocketConnected = false
            case .error(let error):
                self.isSocketConnected = false
                debugPrint("[Starscream] Error: \(error?.localizedDescription)")
        }
    }
}
