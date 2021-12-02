//
//  PaginatedTableView.swift
//  Fayvit
//
//  Created by Sharran M on 01/10/20.
//  Copyright © 2020 Iderize. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PaginatedTableViewDelegate {
    func paginatedTableView(paginationEndpointFor tableView: UITableView) -> PaginationUrl
    func paginatedTableView(_ tableView: UITableView, paginateTo url: String, isFirstPage: Bool, afterPagination hasNext: @escaping(_ hasNext: Bool) -> Void)
    func paginatedTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func paginatedTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    @objc optional func paginatedTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    @objc optional func paginatedTableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    @objc optional func paginatedTableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func paginatedTableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func paginatedTableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    
    @objc optional func paginatedTableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    @objc optional func paginatedTableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    
    @objc optional func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class PaginatedTableView: UITableView {
    @IBOutlet open weak var paginationDelegate: PaginatedTableViewDelegate! {
        didSet { paginationManager = PaginationManager(delegate: paginationDelegate, tableView: self) }
    }
    private var paginationManager: PaginationManager!
    private var hasNext = false
    private var dataCount = 0
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setDataSourceAndDelegate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setDataSourceAndDelegate()
    }
    
    /// Fetch data from server from the given offset with default fetch limit.
    /// - Parameter from: offset of the api data
    func fetchData(from offset: Int = 0) {
        isLoading = true
        paginationManager.paginate(to: offset) { (hasNext) in
            self.isLoading = false
            self.hasNext = hasNext
        }
    }
}

extension PaginatedTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataCount = paginationDelegate.paginatedTableView(self, numberOfRowsInSection: section)
        return dataCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == dataCount - 1 && !isLoading && hasNext {
            fetchData(from: dataCount)
        }
        return paginationDelegate.paginatedTableView(self, cellForRowAt: indexPath) 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        paginationDelegate.paginatedTableView?(self, didSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        paginationDelegate.paginatedTableView?(self, heightForRowAt: indexPath) ?? rowHeight
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        paginationDelegate.paginatedTableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        paginationDelegate.paginatedTableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        paginationDelegate.scrollViewWillBeginDragging?(scrollView)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        ((paginationDelegate.paginatedTableView?(tableView, canEditRowAt: indexPath)) != nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        paginationDelegate.paginatedTableView?(tableView, commit: editingStyle, forRowAt: indexPath)
    }
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //paginationDelegate.scrollViewDidScroll?(scrollView)
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: (paginationDelegate.paginatedTableView?(self, editingStyleForRowAt: indexPath))!.rawValue) ?? .none
    }
}

extension PaginatedTableView {
    var isLoading: Bool {
        get {
            return self.tableFooterView != nil
        }
        set {
            if !newValue {
                self.tableFooterView = nil
            } else {
                DispatchQueue.main.async { self.tableFooterView = self.createFooterSpinner() }
            }
        }
    }
    
    fileprivate func setDataSourceAndDelegate() {
        delegate = self
        dataSource = self
    }
    
    fileprivate func createFooterSpinner() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        footerView.addSubview(spinner)
        spinner.center = footerView.center
        spinner.startAnimating()
        return footerView
    }
    
    fileprivate func hasReachedBottom(_ tableView: UITableView, _ scrollView: UIScrollView) -> Bool {
        let screenEnd = tableView.contentSize.height - 100 - scrollView.frame.size.height
        let scrollPosition = scrollView.contentOffset.y
        return scrollPosition > screenEnd
    }
}
