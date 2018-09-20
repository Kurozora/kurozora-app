//
//  UIViewController+Kurozora.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

extension UIViewController {
    public func addRefreshControl(refreshControl: UIRefreshControl, action: Selector, forTableView tableView: UITableView) {
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: action, for: UIControl.Event.valueChanged)
        tableView.insertSubview(refreshControl, at: tableView.subviews.count - 1)
        tableView.alwaysBounceVertical = true
    }
    
    public func addRefreshControl(refreshControl: UIRefreshControl, action: Selector, forCollectionView collectionView: UICollectionView) {
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: action, for: UIControl.Event.valueChanged)
        collectionView.insertSubview(refreshControl, at: collectionView.subviews.count - 1)
        collectionView.alwaysBounceVertical = true
    }
}
