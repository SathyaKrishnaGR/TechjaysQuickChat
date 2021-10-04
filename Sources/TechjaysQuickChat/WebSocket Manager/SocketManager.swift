

import Starscream
import Foundation

protocol SocketDataTransferDelegate {
    func updateChatList(message: String)
}
class SocketManager {
    var socket: WebSocket!
    var isConnected = false
    var dataUpdateDelegate: SocketDataTransferDelegate?
    let server = WebSocketServer()
    var addMessageToChatList: ((String) -> Void)?
    
    func startSocketWith(url: String) {
        let request = URLRequest(url: URL(string:url)!)
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
    
    // MARK: Write Text Action
    func sendConnectRequest(chatToken: String) {
        let messageString = "{\n" +
            "\n" +
            "    \"token\": \"\(chatToken)\",\n" +
            "\n" +
            "    \"type\": \"connect\"\n" +
            "\n" +
            "}"
        socket.write(string: messageString)
    }
    func sendMessage(chatToken: String, toUserId: String, message: String) {
        
        let dict = ["token": chatToken, "type": "chat", "chat_type": "private", "to": toUserId, "message": message]
        let test = self.convertDoctionaryToJson(dict: dict)
        
        print(test)
        let messageString = "{\n" +
            "    \"token\": \"\(chatToken)\",\n" +
            "    \"type\": \"chat\",\n" +
            "    \"chat_type\": \"private\",\n" +
            "    \"to\": \(toUserId),\n" +
            "    \"message\": \"\(message)\"\n" +
            "}"
        socket.write(string: messageString)
    }
    
    // MARK: Disconnect Action
    
    func disconnect( ) {
        if isConnected {
            socket.disconnect()
        } else {
            socket.connect()
        }
    }
}
extension SocketManager: WebSocketDelegate {
    // MARK: - WebSocketDelegate
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            sendConnectRequest(chatToken: FayvKeys.ChatDefaults.chatToken)
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            dataUpdateDelegate?.updateChatList(message: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
}

extension SocketManager {
    func convertDoctionaryToJson(dict: [String: Any]) -> String {
        var jsonString = ""
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(dic) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                jsonString = jsonString
                return jsonString
            }
        }
        return jsonString
    }
}
