//
//  FetchController.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Parse
//import Bolts

public protocol FetchControllerDelegate: class {
    func didFetchFor(skip: Int)
}

public protocol FetchControllerQueryDelegate: class {
//    func queriesForSkip(skip: Int) -> [PFQuery]?
//    func processResult(result: [PFObject], dataSource: [PFObject]) -> [PFObject]
}

public class FetchController {
    
    public weak var delegate: FetchControllerDelegate?
    public weak var queryDelegate: FetchControllerQueryDelegate?
    
    var isFetching = true
    var canFetchMore = true
    var dataSourceCount = 0
    var page = 0
    var limit = 100
    
    var defaultIsFetching = true
    var defaultCanFetchMore = true
    var defaultDataSourceCount = 0
    var defaultPage = 0
    var defaultLimit = 100
    
    public var tableView: UITableView?
    public var collectionView: UICollectionView?
//    public var dataSource: [PFObject] = []
//    var query: PFQuery?
    
    var isFirstFetch = true
    var datasourceUsesSections = false
//    var pinnedData: [PFObject] = []
    
    public init() {}
    
    public func configureWith() {
//        (delegate: FetchControllerDelegate,
//        query: PFQuery? = nil,
//        queryDelegate: FetchControllerQueryDelegate? = nil,
//        collectionView: UICollectionView? = nil,
//        tableView: UITableView? = nil,
//        limit: Int = 100,
//        datasourceUsesSections: Bool = false,
//        pinnedData: [PFObject] = []) {
//
//        self.queryDelegate = queryDelegate
//        self.delegate = delegate
//        self.tableView = tableView
//        self.collectionView = collectionView
//        query?.limit = limit
//        self.query = query
//        self.datasourceUsesSections = datasourceUsesSections
//        self.pinnedData = pinnedData
//        defaultLimit = limit
//        resetToDefaults()
//        if let tableView = tableView {
//            tableView.reloadData()
//        }
//        fetchWith(skip: 0)
    }
    
    public func resetToDefaults() {
//        dataSource = []
//        isFetching = defaultIsFetching
//        canFetchMore = defaultCanFetchMore
//        dataSourceCount = defaultDataSourceCount
//        page = defaultPage
//        limit = defaultLimit
//        query?.skip = 0
    }
    
//    public func dataCount() -> Int {
//        return dataSource.count
//    }
    
    public func objectAtIndex(index: Int) /*-> PFObject */{
//        didDisplayItemAt(index: index)
//        return dataSource[index]
    }
    
    public func objectInSection(section: Int) /*-> PFObject */{
//        return dataSource[section]
    }
    
    public func didDisplayItemAt(index: Int) {
//
//        if isFetching || !canFetchMore {
//            return
//        }
//
//        if Float(index) > Float(dataSourceCount) - Float(limit) * 0.2 {
//            isFetching = true
//            page += 1
//            print("Fetching page \(page)")
//            fetchWith(skip: page*limit)
//        }
    }
    
    public func didFetch(newDataSourceCount: Int) {
        if !isFetching && newDataSourceCount == limit {
            resetToDefaults()
        }
        
        if isFetching {
            
            isFetching = false
            canFetchMore = newDataSourceCount < dataSourceCount + limit ? false : true
            dataSourceCount = newDataSourceCount
            
            print("Fetched page \(page)")
        }
    }
    
    public var canFetchMoreData: Bool {
        get {
            return canFetchMore
        }
    }
    
    func fetchWith(skip: Int) /*-> BFTask */{
        
//        var secondaryQuery: PFQuery? = nil
//        if let queries = queryDelegate?.queriesForSkip(skip: skip), queries.count > 1 {
//            self.query = queries.first
//            secondaryQuery = queries[1]
//        } else if let query = query {
//            query.skip = skip
//        } else {
//            return BFTask(result: nil)
//        }
//
//        var allData:[PFObject] = []
//
//        let fetchTask = query!.findObjectsInBackground().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject? in
//            allData += task.result as! [PFObject]
//            return nil
//        })
//
//        var fetchTask2 = BFTask(result: nil)
//        if let secondaryQuery = secondaryQuery {
//            fetchTask2 = secondaryQuery.findAllObjectsInBackground().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject? in
//                let result = task.result as! [PFObject]
//                print(result.count)
//                allData += result
//                return nil
//            })
//        }
//
//        let allFetchTasks = BFTask(forCompletionOfAllTasks: [fetchTask, fetchTask2]).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject? in
//
//            if let processedResult = self.queryDelegate?.processResult(result: allData, dataSource: self.dataSource) {
//                allData = processedResult
//            }
//
//            if skip == 0 {
//                self.dataSource = self.pinnedData + allData
//            } else {
//                self.dataSource += allData
//            }
//            self.didFetch(self.dataSource.count)
//            self.delegate?.didFetchFor(skip: skip)
//
//            if let collectionView = self.collectionView {
//                if skip == 0 {
//                    // Reload data
//                    collectionView.reloadData()
//                    if self.isFirstFetch || collectionView.alpha == 0 {
//                        self.isFirstFetch = false
//                        collectionView.animateFadeIn()
//                    }
//                } else {
//                    // Insert rows
//                    // Implement a better way of adding new rows
//                    collectionView.reloadData()
//                }
//            } else if let tableView = self.tableView {
//                if skip == 0 {
//                    tableView.reloadData()
//                    if self.isFirstFetch {
//                        self.isFirstFetch = false
//                        tableView.animateFadeIn()
//                    }
//                } else {
//                    tableView.reloadData()
//                }
//            }
//
//            return nil
//        }).continueWithBlock({ (task: BFTask!) -> AnyObject? in
//            if let exception = task.exception {
//                print(exception)
//            }
//            return nil
//        })
//
//        return allFetchTasks
    }
}
