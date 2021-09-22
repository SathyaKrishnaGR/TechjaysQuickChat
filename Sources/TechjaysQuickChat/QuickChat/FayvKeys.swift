//
//  FayvKeys.swift
//  QuickChat
//
//  Created by SathyaKrishna on 21/09/21.
//  Copyright © 2021 Haik Aslanyan. All rights reserved.
//

import UIKit

struct FayvKeys {
    static let DeviceUUID = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    struct UserDefault {
        static let authTokenKey = "Auth-Token"
        static let userKey = "user"
        static let userId = "user_id"
        static var token = "token"
        static var chatToken = "chat_token"
        static var endpoint = "app_endpoint"
       }
}
