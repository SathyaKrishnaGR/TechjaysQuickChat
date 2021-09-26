//
//  URLFactory.swift
//  Fayvit
//
//  Created by Sharran on 8/21/20.
//  Copyright © 2020 Iderize. All rights reserved.
//

import Foundation

enum QueryParam: String {
    case search
    case fields
    case offset
    case limit
}

class URLFactory {
    
    static let shared = URLFactory()
    
    init() {}
    
    /// Generate Fayvit URL String for provided endpoint
    /// - Parameters:
    ///   - endpoint: Enpoint of the request
    ///   - parameters: Request parameters of the request
    ///   - pathVariable: Path variable of the request
    ///   - version: API version
    ///   - query: Preset query parameters like search, fields & pagination
    /// - Returns: Fayvit URL string for the provided paramters
    func url(
        endpoint: String,
        query: [QueryParam: String] = [.limit: FayvKeys.ChatDefaults.paginationLimit],
        parameters: [String: String] = [:],
        pathVariable: String = "",
        version: Int = 1
    ) -> String {
        let url = buildBaseUrl(for: version) + endpoint
        return buildPathVariable(for: url, with: pathVariable) + queryParamsOf(query, parameters)
    }
}

extension URLFactory {
    private func buildBaseUrl(for version: Int) -> String {
        return FayvKeys.APIDefaults.baseUrl + FayvKeys.APIDefaults.version
    }

    private func buildPathVariable(for url: String, with pathVariable: String) -> String {
        return pathVariable.isEmpty ? "\(url)" : "\(url)\(pathVariable)/"
    }

    private func queryParamsOf(_ query: [QueryParam: String], _ parameters: [String: String]) -> String {
        var queryParams = [String]()
        for (key, value) in query {
            queryParams.append("\(key)=\(value)")
        }
        for (key, value) in parameters {
            queryParams.append("\(key)=\(value)")
        }
        guard !queryParams.isEmpty else {
            return ""
        }
        return "?\(queryParams.joined(separator: "&"))"
    }
}
