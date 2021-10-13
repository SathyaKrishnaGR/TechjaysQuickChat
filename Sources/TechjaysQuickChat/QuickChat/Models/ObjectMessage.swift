//  MIT License

//  Copyright (c) 2019 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

class ObjectMessage: Codable {
    
    var message_id: Int?
    var is_sent_by_myself: Bool?
    var message: String?
    var timestamp: String?
    var result: Bool?
    var msg: String?
    var type: String?
    var chat_type: String?
    var data: SocketData?
    var timestamp_in_date: Date?
    var file_url: String?
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(message_id, forKey: .message_id)
        try container.encodeIfPresent(is_sent_by_myself, forKey: .is_sent_by_myself)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        
        try container.encodeIfPresent(result, forKey: .result)
        try container.encodeIfPresent(msg, forKey: .msg)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(chat_type, forKey: .chat_type)
        try container.encodeIfPresent(timestamp_in_date, forKey: .timestamp_in_date)
        try container.encodeIfPresent(file_url, forKey: .file_url)
        
        //    try container.encode(id, forKey: .id)
        //    try container.encodeIfPresent(message, forKey: .message)
        //    try container.encodeIfPresent(timestamp, forKey: .timestamp)
        //    try container.encodeIfPresent(ownerID, forKey: .ownerID)
        //    try container.encodeIfPresent(profilePicLink, forKey: .profilePicLink)
        //    try container.encodeIfPresent(contentType.rawValue, forKey: .contentType)
        //    try container.encodeIfPresent(content, forKey: .content)
    }
    
    init() {}
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message_id = try container.decodeIfPresent(Int.self, forKey: .message_id)
        is_sent_by_myself = try container.decodeIfPresent(Bool.self, forKey: .is_sent_by_myself)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
        result = try container.decodeIfPresent(Bool.self, forKey: .result)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        chat_type = try container.decodeIfPresent(String.self, forKey: .chat_type)
        data = try container.decodeIfPresent(SocketData.self, forKey: .data)
        timestamp_in_date = try container.decodeIfPresent(Date.self, forKey: .timestamp_in_date)
        file_url = try container.decodeIfPresent(String.self, forKey: .file_url)
        
    }
}

extension ObjectMessage {
    func currentUserID() -> Int? {
        return message_id
    }
    private enum CodingKeys: String, CodingKey {
        case message_id
        case is_sent_by_myself
        case message
        case timestamp
        case result
        case msg
        case type
        case chat_type
        case data
        case timestamp_in_date
        case file_url
        
    }
}

class SocketData: Codable {
    var sender: SocketSender?
    var message: String?
    var timestamp: String?
    var profile_pic: String?
    var file_url: String?
    var timestamp_in_date: Date?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(sender, forKey: .sender)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(profile_pic, forKey: .profile_pic)
        try container.encodeIfPresent(timestamp_in_date, forKey: .timestamp_in_date)
    }
    
    init() {}
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sender = try container.decodeIfPresent(SocketSender.self, forKey: .sender)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
        profile_pic = try container.decodeIfPresent(String.self, forKey: .profile_pic)
        timestamp_in_date = try container.decodeIfPresent(Date.self, forKey: .timestamp_in_date)
    }
}

extension SocketData {
    private enum CodingKeys: String, CodingKey {
        case sender
        case message
        case timestamp
        case profile_pic
        case timestamp_in_date
        
    }
}
class SocketSender: Codable {
    var user_id: Int?
    var username: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(user_id, forKey: .user_id)
        try container.encodeIfPresent(username, forKey: .username)
    }
    
    init() {}
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user_id = try container.decodeIfPresent(Int.self, forKey: .user_id)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        
    }
}

extension SocketSender {
    private enum CodingKeys: String, CodingKey {
        case user_id
        case username
    }
}


struct Multipart: Codable {
    var toUserId: Int?
    var fileType: String?
    var imageData: Data?
    
    private enum CodingKeys: String, CodingKey {
        case
        toUserId = "to_user_id",
        fileType = "file_type",
        imageData
        
    }
}
