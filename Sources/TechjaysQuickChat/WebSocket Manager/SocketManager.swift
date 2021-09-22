//
//  SocketManager.swift
//  QuickChat
//
//  Created by Indhumathy Vellingiri on 16/09/21.
//  Copyright © 2021 Haik Aslanyan. All rights reserved.
//

import Foundation
protocol SocketManagerDelegate: AnyObject {
    func didReciveMessage(text: String)
}

class SocketManager {
    
    fileprivate var webSocketTask: URLSessionWebSocketTask!
    weak var delegate : SocketManagerDelegate?
    init() {}
    
    func sendUrlForWebsocketConfigure(url: String) {
        webSocketTask = configureWebSocket(url: url)
        sendPing()
    }
}

extension SocketManager {
    func configureWebSocket(url: String) -> URLSessionWebSocketTask {
        let urlSession = URLSession(configuration: .default)
        let urlRequest = URLRequest(url: URL(string: url)!)
        let websocket = urlSession.webSocketTask(with: urlRequest)
        websocket.resume()
        return websocket
    }
    
    func sendPing() {
        webSocketTask.sendPing { (error) in
            if let error = error {
                print("Sending PING failed: \(error)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//                self.connectRequst()
//                self.sendPing()
//                self.receiveMessages()
            }
        }
    }
    
    func connectRequst(chatToken: String) {
       let message = URLSessionWebSocketTask.Message.string("{\n" +
                                                               "\n" +
                                                               "    \"token\": \"\(chatToken)\",\n" +
                                                               "\n" +
                                                               "    \"type\": \"connect\"\n" +
                                                               "\n" +
                                                               "}")
       webSocketTask.send(message) { error in
           if let error = error {
               print("WebSocket couldn’t send message because: \(error)")
           }
       }
   }
    
    func sendMessage(chatToken: String, toUserId: String, message: String) {
       let message = URLSessionWebSocketTask.Message.string("{\n" +
        "    \"token\": \"\(chatToken)\",\n" +
        "    \"type\": \"chat\",\n" +
        "    \"chat_type\": \"private\",\n" +
        "    \"to\": \(toUserId),\n" +
        "    \"message\": \"\(message)\"\n" +
        "}")
       webSocketTask.send(message) { error in
           if let error = error {
               print("WebSocket couldn’t send message because: \(error)")
           }
       }
   }
    
    func receiveMessages() {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string: \(text)")
                    self.delegate?.didReciveMessage(text: text)
                case .data(let data):
                    print("Received data: \(data)")
                default:
                    print("Test Failed")
                }
            }
        }
    }
}
