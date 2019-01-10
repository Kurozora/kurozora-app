////
////  AnimeCast.swift
////  KDatabaseKit
////
////  Created by Khoren Katklian on 17/05/2018.
////  Copyright © 2018 Kusa. All rights reserved.
////
//
//import Foundation
////import Parse
//
//public class AnimeCast {
//    public class func parseClassName() -> String {
//        return "AnimeCast"
//    }
//    
//    @NSManaged public var cast: [[String:AnyObject]]
//    
//    public struct Cast {
//        public var castID: Int = 0
//        public var image: String = ""
//        public var name: String = ""
//        public var job: String = ""
//    }
//    
//    public func castAtIndex(index: Int) -> Cast {
//        let data = cast[index]
//        
//        return Cast(
//            castID: (data["id"] as! Int),
//            image: (data["image"] as! String),
//            name: (data["name"] as! String),
//            job: (data["rank"] as! String)
//        )
//    }
//}
