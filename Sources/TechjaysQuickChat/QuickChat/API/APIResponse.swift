//
//  APIResponse.swift
//  Fayvit
//
//  Created by Sharran on 8/17/20.
//  Copyright © 2020 Iderize. All rights reserved.
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    var result: Bool
    var msg: String
    var data: T?
    var nextLink: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case result
        case msg
        case nextLink = "next_link"
        case data
    }
}
