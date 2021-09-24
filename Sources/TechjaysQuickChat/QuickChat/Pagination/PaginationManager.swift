//
//  PaginationManager.swift
//  Fayvit
//
//  Created by Sharran M on 02/10/20.
//  Copyright © 2020 Iderize. All rights reserved.
//

import Foundation
import UIKit

class PaginationManager {
    weak var tableViewDelegate: PaginatedTableViewDelegate?
    weak var collectionViewDelegate: PaginatedCollectionViewDelegate?
    weak var paginatedCollectionView: PaginatedCollectionView?
    weak var paginatedTableView: PaginatedTableView?
    private let urlFactory = URLFactory.shared
    
    init(delegate: PaginatedTableViewDelegate, tableView: PaginatedTableView) {
        self.tableViewDelegate = delegate
        self.paginatedTableView = tableView
    }
    
    init(delegate: PaginatedCollectionViewDelegate, collectionView: PaginatedCollectionView) {
        self.collectionViewDelegate = delegate
        self.paginatedCollectionView = collectionView
    }
    
    func paginate(to: Int, afterPagination: @escaping(_ hasNext: Bool) -> Void) {
        if let delegate = tableViewDelegate, let tableView = paginatedTableView {
            delegate.paginatedTableView(
                tableView,
                paginateTo: buildUrl(delegate.paginatedTableView(paginationEndpointFor: tableView), offset: to),
                isFirstPage: to == 0,
                afterPagination: afterPagination
            )
        } else if let delegate = collectionViewDelegate, let collectionView = paginatedCollectionView {
            delegate.paginatedCollectionView(
                collectionView,
                paginateTo: buildUrl(delegate.paginatedCollectionView(paginationEndpointFor: collectionView), offset: to),
                isFirstPage: to == 0,
                afterPagination: afterPagination
            )
        }
    }
}

extension PaginationManager {
    fileprivate func buildUrl(_ paginationUrl: PaginationUrl, offset: Int) -> String {
        let url = paginationUrl
        var query: [QueryParam: String] = [
            .offset: offset.description,
            .limit: "10"
        ]
        if !url.searchQuery.isEmpty {
            query[.search] = url.searchQuery
        }
        return urlFactory.url(
            endpoint: url.endpoint,
            query: query,
            parameters: url.parameters
        )
    }
}

@objc class PaginationUrl: NSObject {
    var endpoint: String
    var searchQuery: String
    var parameters: [String: String]
    
    init(endpoint: String, search: String = "", parameters: [String: String] = [:]) {
        self.endpoint = endpoint
        self.searchQuery = search
        self.parameters = parameters
    }
}
