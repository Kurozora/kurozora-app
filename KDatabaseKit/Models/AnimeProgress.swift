////
////  AnimeProgress.swift
////  KDatabaseKit
////
////  Created by Khoren Katklian on 17/05/2018.
////  Copyright © 2018 Kusa. All rights reserved.
////
//
//import Foundation
////import Parse
//import KCommonKit
//
//public enum AozoraList: String {
//    case Planning = "Planning"
//    case Watching = "Watching"
//    case Completed = "Completed"
//    case Dropped = "Dropped"
//    case OnHold = "On-Hold"
//}
//
//public class AnimeProgress {
//    public class func parseClassName() -> String {
//        return "AnimeProgress"
//    }
//    
//    public var anime: Anime?
////    public var user: User?
//    
//    @NSManaged public var startDate: Date
//    @NSManaged public var endDate: Date
//    @NSManaged public var isRewatching: Bool
//    @NSManaged public var rewatchCount: Int
//    @NSManaged public var score: Int
//    @NSManaged public var tags: [String]
//    @NSManaged public var collectedEpisodes: Int
//    @NSManaged public var watchedEpisodes: Int
//    @NSManaged public var list: String
//
//    
//    // Used to cache the ID to sync with MyAnimeList faster
//    var myAnimeListID: Int = 0
//    
//    public func myAnimeListList() -> MALList {
//        switch list {
//        case "Planning": return .Planning
//        case "Watching": return .Watching
//        case "Completed": return .Completed
//        case "Dropped": return .Dropped
//        case "On-Hold": return .OnHold
//        default: return .Planning
//        }
//    }
//    
//    public func updateList(malList: MALList) {
//        switch malList {
//        case .Planning:
//            list = AozoraList.Planning.rawValue
//        case .Watching:
//            list = AozoraList.Watching.rawValue
//        case .Completed:
//            if anime?.episodes != 0 {
//                watchedEpisodes = (anime?.episodes)!
//            }
//            endDate = Date()
//            list = AozoraList.Completed.rawValue
//        case .Dropped:
//            list = AozoraList.Dropped.rawValue
//        case .OnHold:
//            list = AozoraList.OnHold.rawValue
//        }
//    }
//    
//    public func updatedEpisodes(animeEpisodes: Int) {
//        if myAnimeListList() == .Planning {
//            list = AozoraList.Watching.rawValue
//        }
//        
//        if myAnimeListList() != .Completed && (animeEpisodes == watchedEpisodes && animeEpisodes != 0) {
//            list = AozoraList.Completed.rawValue
//        }
//        
//        if myAnimeListList() == .Completed && (animeEpisodes != watchedEpisodes && animeEpisodes != 0) {
//            list = AozoraList.Watching.rawValue
//        }
//    }
//    
//    // Next episode to Watch
//    
//    public var nextEpisodeToWatch: Int? {
//        get {
//            return hasNextEpisodeToWatchInformation() ? nextEpisodeToWatchInternal : nil
//        }
//    }
//    
//    public var nextEpisodeToWatchDate: Date? {
//        get {
//            return hasNextEpisodeToWatchInformation() ? nextEpisodeToWatchDateInternal : nil
//        }
//    }
//
//    var nextEpisodeToWatchInternal: Int = 0
//    var nextEpisodeToWatchDateInternal: Date = Date()
//
//    func hasNextEpisodeToWatchInformation() -> Bool {
//        if let startDate = anime?.startDate, myAnimeListList() != .Completed {
//            if nextEpisodeToWatchInternal == 0 {
//                let (nextAiringDate, nextAiringEpisode) = nextEpisodeToWatchForStartDate(startDate: startDate as Date)
//                nextEpisodeToWatchInternal = nextAiringEpisode
//                nextEpisodeToWatchDateInternal = nextAiringDate as Date
//            }
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func nextEpisodeToWatchForStartDate(startDate: Date) -> (nextDate: Date, nextEpisode: Int) {
//        
//        let now = Date()
//        
//        if startDate.compare(now) == ComparisonResult.orderedDescending || watchedEpisodes == 0 {
//            return (startDate, 1)
//        }
//        
//        let unit = Set<Calendar.Component>([.weekOfYear])
//        let cal = Calendar.current
//        var components = cal.dateComponents(unit, from: startDate)
//        components.weekOfYear = watchedEpisodes
//        
//        let nextEpisodeDate: Date = cal.date(byAdding: components, to: startDate)!
//        return (nextEpisodeDate, components.weekOfYear! + 1)
//    }
//}
