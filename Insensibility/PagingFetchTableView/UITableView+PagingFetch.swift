//
//  UITableView+Paging.swift
//  Insensibility
//
//  Created by 李宗良 on 2020/9/4.
//

import UIKit

@available(iOS 10.0, *)
public extension UITableView {

// MARK: this part is only thing you need using
    
    typealias PagingFetchCompletionBlock = (_ nomore: Bool) -> Void
    typealias PagingFetchBlock = (@escaping PagingFetchCompletionBlock) -> Void
    
    func refresh() -> Bool {
        if fetching {
            return false
        }
        
        guard let refreshBlock = refreshBlock else {
            return false
        }
        
        fetching = true
        
        if let refreshControl = refreshControl, !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        
        refreshBlock { [weak self] hasMoreData in
            guard let self = self else {
                return
            }
            self.refreshControl?.endRefreshing()
            self.nomore = hasMoreData
            self.fetching = false
        }
        
        return true
    }
    
    func loadMore() -> Bool {
        if fetching || nomore {
            return false
        }
        
        guard let loadmoreBlock = loadmoreBlock else {
            return false
        }
        
        fetching = true
        
        loadmoreBlock { [weak self] hasMoreData in
            guard let self = self else {
                return
            }
            self.nomore = hasMoreData
            self.fetching = false
        }
        
        return true
    }
    
    var refreshBlock: PagingFetchBlock? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.refreshBlock) as? PagingFetchBlock
        }
        set {
            let block = newValue as PagingFetchBlock?
            if block == nil {
                refreshControl = nil;
            } else {
                refreshControl = UIRefreshControl(frame: .zero)
                refreshControl?.addTarget(self, action: #selector(tryToRefresh(_:)), for: .valueChanged)
            }
            objc_setAssociatedObject(self, &AssociatedKeys.refreshBlock, block, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var loadmoreBlock: PagingFetchBlock? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.loadmorehBlock) as? PagingFetchBlock
        }
        set {
            let block = newValue as PagingFetchBlock?
            if block == nil {
                pagingObserver = nil
            } else {
                let observer = PagingFetchObserver()
                observer.tableView = self
                pagingObserver = observer
            }
            objc_setAssociatedObject(self, &AssociatedKeys.loadmorehBlock, newValue as PagingFetchBlock?, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
// MARK: - the part below you can ignore
    
    private struct AssociatedKeys {
        static var refreshBlock = "pagingFetchBlock"
        static var loadmorehBlock = "pagingFetchBlock"
        static var nomore = "pagingNomore"
        static var fetching = "pagingFetching"
        static var observer = "pagingFetchObserver"
    }
    
    fileprivate var nomore: Bool {
        get {
            let nomoreNumber = objc_getAssociatedObject(self, &AssociatedKeys.nomore) as? NSNumber
            return nomoreNumber?.boolValue ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.nomore, NSNumber(booleanLiteral: newValue), .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    fileprivate var fetching: Bool {
        get {
            let nomoreNumber = objc_getAssociatedObject(self, &AssociatedKeys.fetching) as? NSNumber
            return nomoreNumber?.boolValue ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.fetching, NSNumber(booleanLiteral: newValue), .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    fileprivate var pagingObserver: PagingFetchObserver? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.observer) as? PagingFetchObserver
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.observer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc private func tryToRefresh(_ sender: UIRefreshControl) -> Void {
        if !refresh() {
            sender.endRefreshing()
        }
    }
    
    fileprivate func tryToLoadmore() -> Void {
        let offsetY = contentOffset.y
        let contentHeight = contentSize.height
        let tableHeight = fmin(contentHeight, bounds.height)
        let x = contentHeight - offsetY - tableHeight
        if  x > 0 && x < fmin(tableHeight / 2, 200){
            _ = loadMore()
        }
    }
}

private class PagingFetchObserver: NSObject {
    weak var tableView: UITableView? {
        willSet {
            if tableView != nil {
                tableView!.removeObserver(self, forKeyPath: "contentOffset")
                tableView!.removeObserver(self, forKeyPath: "contentSize")
            }
            if newValue != nil {
                newValue!.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
                newValue!.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            dealWithContentOffset(change)
        } else if keyPath == "contentSize" {
            
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func dealWithContentOffset(_ change: [NSKeyValueChangeKey : Any]?) -> Void {
        guard let tableView = tableView else {
            return
        }

        let oldOffsetY = (change?[.oldKey] as? NSValue)?.cgPointValue.y ?? 0
        let newOffsetY = (change?[.newKey] as? NSValue)?.cgPointValue.y ?? 0
        if newOffsetY <= oldOffsetY {
            return
        }
        
        tableView.tryToLoadmore()
    }
}
