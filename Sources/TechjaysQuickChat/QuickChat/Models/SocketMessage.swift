//
//  File.swift
//  
//
//  Created by SathyaKrishna on 23/09/21.
//

import Foundation
import UIKit

class SocketMessage: Codable {
    /*{
    "result":true,
    "msg":"success",
    "type":"chat",
    "chat_type":"private",
    "data":{
    "sender":{
    "user_id":4,
    "username":"anu"
    },
    "message":"Hi 123",
    "timestamp":1632372760.5590613
    }
    }*/
    var result: Bool?
    var msg: String?
    var type: String?
    var chat_type: String?
    var data: SocketData?
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
            try container.encodeIfPresent(result, forKey: .result)
            try container.encodeIfPresent(msg, forKey: .msg)
            try container.encodeIfPresent(type, forKey: .type)
            try container.encodeIfPresent(chat_type, forKey: .chat_type)
    }
    
    init() {}
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        result = try container.decodeIfPresent(Bool.self, forKey: .result)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        chat_type = try container.decodeIfPresent(String.self, forKey: .chat_type)
        data = try container.decodeIfPresent(SocketData.self, forKey: .data)
        
    }
}

extension SocketMessage {
    private enum CodingKeys: String, CodingKey {
        case result
        case msg
        case type
        case chat_type
        case data
        
    }
}
//class SocketData: Codable {
//    var sender: SocketSender?
//    var message: String?
//    var timestamp: String?
//    
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encodeIfPresent(sender, forKey: .sender)
//            try container.encodeIfPresent(message, forKey: .message)
//            try container.encodeIfPresent(timestamp, forKey: .timestamp)
//    }
//    
//    init() {}
//    
//    public required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        sender = try container.decodeIfPresent(SocketSender.self, forKey: .sender)
//        message = try container.decodeIfPresent(String.self, forKey: .message)
//        timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
//        
//    }
//}
//
//extension SocketData {
//    private enum CodingKeys: String, CodingKey {
//        case sender
//        case message
//        case timestamp
//        
//    }
//}
//class SocketSender: Codable {
//    var user_id: String?
//    var username: String?
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encodeIfPresent(user_id, forKey: .user_id)
//            try container.encodeIfPresent(username, forKey: .username)
//    }
//    
//    init() {}
//    
//    public required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        user_id = try container.decodeIfPresent(String.self, forKey: .user_id)
//        username = try container.decodeIfPresent(String.self, forKey: .username)
//        
//    }
//}
//
//extension SocketSender {
//    func currentUserID() -> String? {
//      return user_id
//    }
//    private enum CodingKeys: String, CodingKey {
//        case user_id
//        case username
//    }
//}
