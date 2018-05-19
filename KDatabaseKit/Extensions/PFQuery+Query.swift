//
//  PFQuery+Query.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

//import Foundation
//import Parse
//import Bolts

//extension PFQuery {
//
//    public func findAllObjectsInBackground(with skip: Int? = 0) -> BFTask {
//
//        limit = 1000
//        self.skip = skip!
//
//        return findObjectsInBackground()
//            .continueWithBlock { (task: BFTask!) -> BFTask! in
//
//                let result = task.result as! [PFObject]
//                if result.count == self.limit {
//                    return self.findAllObjectsInBackground(with: self.skip + self.limit)
//                        .continueWithBlock({ (previousTask: BFTask!) -> AnyObject! in
//                            let newResults = previousTask.result as! [PFObject]
//                            return BFTask(result: result+newResults)
//                        })
//                } else {
//                    return task
//                }
//        }
//    }
//}
