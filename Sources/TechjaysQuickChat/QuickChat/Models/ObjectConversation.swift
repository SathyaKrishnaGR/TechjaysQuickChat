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

import Foundation

class Conversation: Codable {
//    var id = UUID().uuidString
    var next_link: Bool?
    var msg: String?
    var result: Bool?
    var data: [ObjectConversation]?
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
        try container.encode(next_link, forKey: .next_link)
        try container.encode(msg, forKey: .msg)
        try container.encode(result, forKey: .result)
        try container.encode(data, forKey: .data)
    }
    
    init() {}
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
        next_link = try container.decode(Bool.self, forKey: .next_link)
        msg = try container.decode(String.self, forKey: .msg)
        result = try container.decode(Bool.self, forKey: .result)
        data = try container.decode([ObjectConversation].self, forKey: .data)
    }
    
}

extension Conversation {
    private enum CodingKeys: String, CodingKey {
        case id
        case next_link
        case msg
        case result
        case data
    }
}
public class ObjectConversation: Codable, Equatable {
    public static func == (lhs: ObjectConversation, rhs: ObjectConversation) -> Bool {
        return (lhs.company_name == rhs.company_name) && (lhs.first_name == rhs.first_name) && (lhs.is_sent_by_myself == rhs.is_sent_by_myself) && (lhs.medium_profile_pic == rhs.medium_profile_pic) && (lhs.message == rhs.message) && (lhs.message_id == rhs.message_id) && (lhs.profile_pic == rhs.profile_pic) && (lhs.thumbnail_profile_pic == rhs.thumbnail_profile_pic) && (lhs.to_user_id == rhs.to_user_id) && (lhs.user_type == rhs.user_type) && (lhs.timestamp == rhs.timestamp)
    }
    
//    var id = UUID().uuidString
    var company_name: String?
    var first_name: String?
    var last_name: String?
    var is_sent_by_myself: Bool?
    var medium_profile_pic: String?
    var message: String?
    var message_id: Int?
    var profile_pic: String?
    var thumbnail_profile_pic: String?
    var to_user_id: Int?
    var user_type: String?
    var timestamp: String?
    var type: String?
    var username: String?
    
    //    var lastMessage: String?
    //    var isRead = [String: Bool]()
    //    var userIDs = [String]()
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(company_name, forKey: .company_name)
        try container.encodeIfPresent(first_name, forKey: .first_name)
        try container.encodeIfPresent(last_name, forKey: .last_name)
        try container.encodeIfPresent(is_sent_by_myself, forKey: .is_sent_by_myself)
        try container.encodeIfPresent(medium_profile_pic, forKey: .medium_profile_pic)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(message_id, forKey: .message_id)
        try container.encodeIfPresent(profile_pic, forKey: .profile_pic)
        try container.encodeIfPresent(thumbnail_profile_pic, forKey: .thumbnail_profile_pic)
        try container.encodeIfPresent(to_user_id, forKey: .to_user_id)
        try container.encodeIfPresent(user_type, forKey: .user_type)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(username, forKey: .username)
        
        //    try container.encode(userIDs, forKey: .userIDs)
        //    try container.encodeIfPresent(lastMessage, forKey: .lastMessage)
        //    try container.encode(isRead, forKey: .isRead)
        
    }
    
    init() {}
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
        company_name = try container.decodeIfPresent(String.self, forKey: .company_name)
        first_name = try container.decodeIfPresent(String.self, forKey: .first_name)
        last_name = try container.decodeIfPresent(String.self, forKey: .last_name)
        is_sent_by_myself = try container.decodeIfPresent(Bool.self, forKey: .is_sent_by_myself)
        medium_profile_pic = try container.decodeIfPresent(String.self, forKey: .medium_profile_pic)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        message_id = try container.decodeIfPresent(Int.self, forKey: .message_id)
        profile_pic = try container.decodeIfPresent(String.self, forKey: .profile_pic)
        thumbnail_profile_pic = try container.decodeIfPresent(String.self, forKey: .thumbnail_profile_pic)
        to_user_id = try container.decodeIfPresent(Int.self, forKey: .to_user_id)
        user_type = try container.decodeIfPresent(String.self, forKey: .user_type)
        timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        //    userIDs = try container.decode([String].self, forKey: .userIDs)
        //    lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
        //    isRead = try container.decode([String: Bool].self, forKey: .isRead)
        
    }
}

extension ObjectConversation {
    private enum CodingKeys: String, CodingKey {
//        case id
        case company_name
        case last_name
        case first_name
        case is_sent_by_myself
        case medium_profile_pic
        case message
        case message_id
        case profile_pic
        case thumbnail_profile_pic
        case to_user_id
        case user_type
        case timestamp
        case type
        case username
        

        
        //    case userIDs
        //    case lastMessage
        //    case isRead
        
    }
}


