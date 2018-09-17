//
//  Models.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

public struct FeaturedShows: Decodable {
    //    let success: Bool
    var banners: [Show]?
    let categories: [ShowCategory]
}

struct ShowCategory: Decodable {
    var title: String?
    var shows: [Show]?
    var type: String?
}

struct ShowDetails: JSONDecodable {
    // General
    let anime: String?
    let id: Int?
    let title: String?
    let genre: String?
    let poster: String?
    let posterThumbnail: String?
    let banner: String?
    let bannerThumbnail: String?

    // Details
    let screenshots: [String]?
    let synopsis: String?
    let type: String?
    let episodes: Int?
    let status: String?
    let aired: String?
    let runtime: Int?
    let watchRating: String?
    let year: Int?

    // Ratings & ranks
    let averageRating: Double?
    let ratingCount: Int?
    let rank: Int?
    let popularityRank: Int?
    let startDate: Date?
    let endDate: Date?
    let producers: String?
    let nsfw: Bool?

    // Extra's
    let englishTitles: String?
    let japaneseTitles: String?
    let synonyms: String?
    let externalLinks: String?
    let youtubeId: String?
    
    // User
    let user: String?
    var currentRating: Double?

    init(json: JSON) throws {
//        id = json["anime"]["id"].intValue
//        title = json["anime"]["title"].stringValue
//        type = json["anime"]["type"].stringValue
//        averageRating = json["anime"]["average_rating"].intValue
//        ratingCount = json["anime"]["rating_count"].intValue
//        synopsis = json["anime"]["synopsis"].stringValue
//        episodes = json["anime"]["episodes"].intValue
//        runtime = json["anime"]["runtime"].intValue
//        watchRating = json["anime"]["watch_rating"].stringValue
//        year = json["anime"]["year"].intValue
//        poster = json["anime"]["poster"].stringValue
//        posterThumbnail = json["anime"]["poster_thumbnail"].stringValue
//        banner = json["anime"]["background"].stringValue
//        bannerThumbnail = json["anime"]["background_thumbnail"].stringValue
//        nsfw = json["anime"]["nsfw"].boolValue
//
//
//
//        user = json["user"].stringValue
//        currentRating = json["current_rating"].doubleValue
        
        // Anime
        anime = json["anime"].stringValue
        id = json["anime"]["id"].intValue
        title = json["anime"]["title"].stringValue
        genre = json["anime"]["genre"].stringValue
        poster = json["anime"]["poster"].stringValue
        posterThumbnail = json["anime"]["poster_thumbnail"].stringValue
        banner = json["anime"]["background"].stringValue
        bannerThumbnail = json["anime"]["background_thumbnail"].stringValue

        // Details
        screenshots = json["anime"]["screenshots"].rawValue as? [String]
        synopsis = json["anime"]["synopsis"].stringValue
        type = json["anime"]["type"].stringValue
        episodes = json["anime"]["episodes"].intValue
        status = json["anime"]["status"].stringValue
        aired = json["anime"]["aired"].stringValue
        runtime = json["anime"]["runtime"].intValue
        watchRating = json["anime"]["watch_rating"].stringValue
        year = json["anime"]["year"].intValue

        // Ratings & ranks
        averageRating = json["anime"]["average_rating"].doubleValue
        ratingCount = json["anime"]["rating_count"].intValue
        rank = json["anime"]["rank"].intValue
        popularityRank = json["anime"]["popularity_rank"].intValue
        startDate = json["anime"]["start_date"].rawValue as? Date
        endDate = json["anime"]["end_date"].rawValue as? Date
        producers = json["anime"]["producers"].stringValue
        nsfw = json["anime"]["nsfw"].boolValue

        // Extra's
        englishTitles = json["anime"]["english_titles"].stringValue
        japaneseTitles = json["anime"]["japanese_titles"].stringValue
        synonyms = json["anime"]["synonyms"].stringValue
        externalLinks = json["anime"]["external_links"].stringValue
        youtubeId = json["anime"]["youtube_id"].stringValue

        // User
        user = json["user"].stringValue
        currentRating = json["user"]["current_rating"].doubleValue
    }

    public func informationString() -> String {
        let episodes = (self.episodes != 0) ? self.episodes : 0
        let runtime = (self.runtime != 0) ? self.runtime : 0
        let year = (self.year != 0) ? self.year : 0000
        return "\(type ?? "Unknown") · \(watchRating ?? "N/A") · \(episodes ?? 0) eps · \(runtime ?? 0) min · \(year ?? 0000)"
    }

    public func attributedSynopsis() -> NSAttributedString? {
        if let synopsis = synopsis, let data = synopsis.data(using: String.Encoding.unicode) {
            let font = UIFont.systemFont(ofSize: 15)
            
            if let attributedString = try? NSMutableAttributedString(
                data: data,
                options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil) {
                attributedString.addAttribute(NSAttributedStringKey.font, value: font, range: NSMakeRange(0, attributedString.length))
                attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white , range:  NSMakeRange(0, attributedString.length))
                return attributedString
            }
        }
        return nil
    }
}

struct Show: Decodable {
    // General
    let id: Int?
    let title: String?
    let genre: String?
    let poster: String?
    let posterThumbnail: String?
    let banner: String?
    let bannerThumbnail: String?

    // Details
    let screenshots: [String]?
    let synopsis: String?
    let type: String?
    let episodes: Int?
    let status: String?
    let aired: String?
    let runtime: Int?
    let watchRating: String?

    // Ratings & ranks
    let averageRating: Double?

    // Extra's
    let englishTitles: String?
    let japaneseTitles: String?
    let synonyms: String?
    let externalLinks: String?
    let youtubeId: String?

    enum CodingKeys: String, CodingKey {
        // General
        case id = "id"
        case title = "title"
        case genre = "genre"
        case poster = "poster"
        case posterThumbnail = "poster_thumbnail"
        case banner = "background"
        case bannerThumbnail = "background_thumbnail"

        // Details
        case screenshots = "screenshots"
        case synopsis = "synopsis"
        case type = "type"
        case episodes = "episodes"
        case status = "status"
        case aired = "aired"
        case runtime = "runtime"
        case watchRating = "watch_rating"

        // Ratings & ranks
        case averageRating = "average_rating"

        // Extra's
        case englishTitles = "english_titles"
        case japaneseTitles = "japanese_titles"
        case synonyms = "synonyms"
        case externalLinks = "external_links"
        case youtubeId = "youtube_id"
    }
    //    public func linkAtIndex(index: Int) -> Link {
    //        let linkData: AnyObject = externalLinks[index]
    //        let externalLink = ExternalLink(rawValue: linkData["site"] as! String) ?? .Other
    //
    //        return Link(site: externalLink, url: (linkData["url"] as! String))
    //    }
}

//import UIKit
//import TRON
//import SwiftyJSON
//
//struct FeaturedShows: JSONDecodable {
////    let success: Bool
//    var banners: [Show]?
//    let categories: [ShowCategory]?
//
//    init(json: JSON) {
//        banners = json["banners"].rawValue as? [Show]
//        categories = json["categories"].rawValue as? [ShowCategory]
//    }
//}
//
//struct ShowCategory: JSONDecodable {
//    var title: String?
//    var shows: [Show]?
//    var type: String?
//
//    init(json: JSON) {
//
//    }
//}
//
//struct ShowDetails: JSONDecodable {
////    let success: Bool?
//    var anime: Show?
//
//    init(json: JSON) {
//        anime = json["anime"].rawValue as? Show
//    }
//}
//
//struct Show: JSONDecodable {
//    // General
//    let id: Int?
//    let title: String?
//    let genre: String?
//    let poster: String?
//    let posterThumbnail: String?
//    let banner: String?
//    let bannerThumbnail: String?
//
//    // Details
//    let screenshots: [String]?
//    let synopsis: String?
//    let type: String?
//    let episodes: Int?
//    let status: String?
//    let aired: String?
//    let runtime: Int?
//    let watchRating: String?
//    let year: Int?
//
//    // Ratings & ranks
//    let averageRating: Double?
//    let ratingCount: Int?
//    let rank: Int?
//    let popularityRank: Int?
//    let startDate: Date?
//    let endDate: Date?
//    let producers: String?
//    let nsfw: Bool?
//
//    // Extra's
//    let englishTitles: String?
//    let japaneseTitles: String?
//    let synonyms: String?
//    let externalLinks: String?
//    let youtubeId: String?
//
//    init(json: JSON) {
//        // General
//        id = json["id"].intValue
//        title = json["title"].stringValue
//        genre = json["genre"].stringValue
//        poster = json["poster"].stringValue
//        posterThumbnail = json["poster_thumbnail"].stringValue
//        banner = json["background"].stringValue
//        bannerThumbnail = json["background_thumbnail"].stringValue
//
//        // Details
//        screenshots = json["screenshots"].rawValue as? [String]
//        synopsis = json["synopsis"].stringValue
//        type = json["type"].stringValue
//        episodes = json["episodes"].intValue
//        status = json["status"].stringValue
//        aired = json["aired"].stringValue
//        runtime = json["runtime"].intValue
//        watchRating = json["watch_rating"].stringValue
//        year = json["year"].intValue
//
//        // Ratings & ranks
//        averageRating = json["average_rating"].doubleValue
//        ratingCount = json["rating_count"].intValue
//        rank = json["rank"].intValue
//        popularityRank = json["popularity_rank"].intValue
//        startDate = json["start_date"].rawValue as? Date
//        endDate = json["end_date"].rawValue as? Date
//        producers = json["producers"].stringValue
//        nsfw = json["nsfw"].boolValue
//
//        // Extra's
//        englishTitles = json["english_titles"].stringValue
//        japaneseTitles = json["japanese_titles"].stringValue
//        synonyms = json["synonyms"].stringValue
//        externalLinks = json["external_links"].stringValue
//        youtubeId = json["youtube_id"].stringValue
//    }
//
//
//    func informationString() -> String {
//        let episodes = (self.episodes != 0) ? self.episodes : 0
//        let runtime = (self.runtime != 0) ? self.runtime : 0
//        let year = (self.year != 0) ? self.year : 0000
//        return "\(type ?? "Unknown") · \(watchRating ?? "N/A") · \(episodes ?? 0) eps · \(runtime ?? 0) min · \(year ?? 0000)"
//    }
//
//    func attributedSynopsis() -> NSAttributedString? {
//        if let synopsis = synopsis, let data = synopsis.data(using: String.Encoding.unicode) {
//            let font = UIFont.systemFont(ofSize: 15)
//            if let attributedString = try? NSMutableAttributedString(
//                data: data,
//                options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil) {
//                attributedString.addAttribute(NSAttributedStringKey.font, value: font, range: NSMakeRange(0, attributedString.length))
//                return attributedString
//            }
//        }
//        return nil
//    }
////    public func linkAtIndex(index: Int) -> Link {
////        let linkData: AnyObject = externalLinks[index]
////        let externalLink = ExternalLink(rawValue: linkData["site"] as! String) ?? .Other
////
////        return Link(site: externalLink, url: (linkData["url"] as! String))
////    }
//}
