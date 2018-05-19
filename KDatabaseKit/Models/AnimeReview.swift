//
//  AnimeReview.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Parse

public class AnimeReview {
   public class func parseClassName() -> String {
        return "AnimeReview"
    }
    
    @NSManaged public var reviews: [AnyObject]
    
    public struct Review {
        public var avatarUrl: String
        public var date: String
        public var episodes: Int
        public var helpful: Int
        public var helpfulTotal: Int
        public var rating: Int
        public var review: String
        public var username: String
        public var watchedEpisodes: Int
        
        public func helpfulString() -> String {
            let percentageString = String(format: "%.0f%%",Double(self.helpful)*100.0 / Double(self.helpfulTotal))
            return "\(percentageString) of \(self.helpfulTotal) people found this review helpful"
        }
    }
    
    public func reviewFor(index: Int) -> Review {
        
        let data: AnyObject = reviews[index]
        
        return Review(
            avatarUrl: (data["avatar_url"] as! String),
            date: (data["date"] as! String),
            episodes: (data["episodes"] as! Int),
            helpful: (data["helpful"] as! Int),
            helpfulTotal: (data["helpful_total"] as! Int),
            rating: (data["rating"] as! Int),
            review: (data["review"] as! String),
            username: (data["username"] as! String),
            watchedEpisodes: (data["watched_episodes"] as! Int)
        )
    }
}
