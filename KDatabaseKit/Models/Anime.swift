//
//  Anime.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Bolts
//import Parse
import KCommonKit

public class Anime {
    public class func parseClassName() -> String {
        return "Anime"
    }
    
    @NSManaged public var rank: Int
    @NSManaged public var myAnimeListID: Int
    @NSManaged public var anilistID: Int
    @NSManaged public var tvdbID: Int
    @NSManaged public var traktID: Int
    @NSManaged public var traktSlug: String
    @NSManaged public var title: String?
    @NSManaged public var titleEnglish: String?
    @NSManaged public var type: String
    @NSManaged public var episodes: Int
    
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var genres: [String]
    @NSManaged public var imageUrl: String
    @NSManaged public var producers: [String]
    @NSManaged public var status: String
    
    @NSManaged public var favoritedCount: Int
    @NSManaged public var membersCount: Int
    @NSManaged public var membersScore: Double
    @NSManaged public var popularityRank: Int
    @NSManaged public var year: Int
    @NSManaged public var fanart: String?
    @NSManaged public var hummingBirdID: Int
    @NSManaged public var hummingBirdSlug: String
    
    @NSManaged public var duration: Int
    @NSManaged public var externalLinks: [AnyObject]
    @NSManaged public var source: String?
    @NSManaged public var startDateTime: Date?
    @NSManaged public var studio: [NSDictionary]
//
//    public var progress: AnimeProgress?
//    public var publicProgress: AnimeProgress?
//    public var details: AnimeDetail?
//    public var relations: AnimeRelation?
//    public var cast: AnimeCast?
//    public var characters: AnimeCharacter?
//
//    public func fanartThumbURLString() -> String {
//        if let fanartUrl = fanart, fanartUrl.count != 0 {
//            return fanartUrl.replacingOccurrences(of: "/original/", with: "/thumb/")
//        } else {
//            return fanartURLString()
//        }
//    }
//
//    public func fanartURLString() -> String {
//        if let fanartUrl = fanart, fanartUrl.count != 0 {
//            return fanartUrl
//        } else {
//            return imageUrl.replacingOccurrences(of: ".jpg", with: "l.jpg")
//        }
//    }
//
//    public func informationString() -> String {
//        let episodes = (self.episodes != 0) ? self.episodes.description : "?"
//        let duration = (self.duration != 0) ? self.duration.description : "?"
//        let year = (self.year != 0) ? self.year.description : "?"
//        return "\(type) · \(KDatabaseKit.shortClassification(classification: details!.classification)) · \(episodes) eps · \(duration) min · \(year)"
//    }
//
//    // Episodes
////    var cachedEpisodeList: [Episode] = []
//
////    public func episodeList() -> BFTask {
////
////        if cachedEpisodeList.count != 0 || (episodes == 0 && traktID == 0) {
////            return BFTask(result: cachedEpisodeList)
////        }
////
////        return fetchEpisodes(myAnimeListID).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
////
////            guard let episodes = task.result as? [Episode] else {
////                return nil
////            }
////
////            self.cachedEpisodeList = episodes
////            return nil
////
////            }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
////
////                if let result = task.result as? [Episode], result.count > 0 {
////                    print("Found \(result.count) eps from network")
////                    self.cachedEpisodeList += result
////                }
////
////                return BFTask(result: self.cachedEpisodeList)
////        }
////
////    }
//
////    func fetchEpisodes(myAnimeListID: Int) -> BFTask {
////        let episodesQuery = episodes.query()!
////        episodesQuery.orderByAscending("number")
////        episodesQuery.whereKey("anime", equalTo: self)
////        return episodesQuery.findAllObjectsInBackground()
////    }
//
//    // ETA
//
//    public var nextEpisode: Int? {
//        get {
//            return hasNextEpisodeInformation() ? nextEpisodeInternal : nil
//        }
//    }
//
//    public var nextEpisodeDate: Date? {
//        get {
//            return hasNextEpisodeInformation() ? nextEpisodeDateInternal : nil
//        }
//    }
//
//    var nextEpisodeInternal: Int = 0
//    var nextEpisodeDateInternal: Date = Date()
//
//    func hasNextEpisodeInformation() -> Bool {
//        if let startDate = startDateTime, AnimeStatus(rawValue: status) != .FinishedAiring {
//            if nextEpisodeInternal == 0 {
//                let (nextAiringDate, nextAiringEpisode) = AiringController.nextEpisodeToAirForStartDate(startDate: startDate)
//                nextEpisodeInternal = nextAiringEpisode
//                nextEpisodeDateInternal = nextAiringDate
//            }
//            return true
//        } else {
//            return false
//        }
//    }
//
//    // External Links
//
//    public enum ExternalLink: String {
//        case Crunchyroll = "Crunchyroll"
//        case OfficialSite = "Official Site"
//        case Daisuki = "Daisuki"
//        case Funimation = "Funimation"
//        case MyAnimeList = "MyAnimeList"
//        case Hummingbird = "Hummingbird"
//        case Anilist = "Anilist"
//        case Other = "Other"
//    }
//
//    public struct Link {
//        public var site: ExternalLink
//        public var url: String
//    }
//
//    public func linkAtIndex(index: Int) -> Link {
//
//        let linkData: AnyObject = externalLinks[index]
//        let externalLink = ExternalLink(rawValue: linkData["site"] as! String) ?? .Other
//
//        return Link(site: externalLink, url: (linkData["url"] as! String))
//    }
//
//    // Fetching
//
//    public class func queryWith(objectID: String) /* -> PFQuery */{
//
//        let query = Anime.query()!
//        query.limit = 1
//        query.whereKey("objectId", equalTo: objectID)
//        return query
//    }
//
//    public class func queryWith(malID: Int) /*-> PFQuery */{
//
//        let query = Anime.query()!
//        query.limit = 1
//        query.whereKey("myAnimeListID", equalTo: malID)
//        return query
//    }

}
