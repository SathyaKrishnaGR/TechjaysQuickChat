//
//  PaginatedCollectionView.swift
//  Fayvit
//
//  Created by Sharran M on 02/10/20.
//  Copyright © 2020 Iderize. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PaginatedCollectionViewDelegate {
    func paginatedCollectionView(paginationEndpointFor collectionView: UICollectionView) -> PaginationUrl
    func paginatedCollectionView(_ collectionView: UICollectionView, paginateTo url: String, isFirstPage: Bool, afterPagination hasNext: @escaping(_ hasNext: Bool) -> Void)
    func paginatedCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func paginatedCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    @objc optional func paginatedCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    @objc optional func paginatedCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    @objc optional func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)

}

class PaginatedCollectionView: UICollectionView {
    @IBOutlet open weak var paginationDelegate: PaginatedCollectionViewDelegate! {
        didSet { paginationManager = PaginationManager(delegate: paginationDelegate, collectionView: self) }
    }
    private var paginationManager: PaginationManager!
    private var dataCount = 0
    private var hasNext = false
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
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

extension PaginatedCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        paginationDelegate.paginatedCollectionView?(collectionView, didSelectItemAt: indexPath)
    }
}

extension PaginatedCollectionView: UICollectionViewDataSource {
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        paginationDelegate.scrollViewWillBeginDragging?(scrollView)
    }

    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        paginationDelegate.scrollViewDidScroll?(scrollView)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataCount = paginationDelegate.paginatedCollectionView(collectionView, numberOfItemsInSection: section)
        return dataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return paginationDelegate.paginatedCollectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionFooterSpinner.identifier, for: indexPath)
            return footer
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == dataCount - 1, !isLoading, hasNext {
            fetchData(from: dataCount)
        }
    }
}

extension PaginatedCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return paginationDelegate.paginatedCollectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize(width: 160, height: 210)
    }
}

extension PaginatedCollectionView {
    var isLoading: Bool {
        get {
            return (collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize.equalTo(CollectionFooterSpinner.size) ?? false
        }
        set {
            if newValue {
                DispatchQueue.main.async {
                    (self.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CollectionFooterSpinner.size
                }
            } else {
                DispatchQueue.main.async {
                    (self.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = .zero
                }
            }
        }
    }
    
    fileprivate func commonInit() {
        delegate = self
        dataSource = self
        register(
            CollectionFooterSpinner.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: CollectionFooterSpinner.identifier
        )
    }
}

public class CollectionFooterSpinner: UICollectionReusableView {
    static let identifier = "Footer"
    static let size = CGSize(width: 50, height: 50)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let footerSpinner = UIActivityIndicatorView(style: .medium)
        footerSpinner.startAnimating()
        footerSpinner.center = self.center
        addSubview(footerSpinner)
    }
}
