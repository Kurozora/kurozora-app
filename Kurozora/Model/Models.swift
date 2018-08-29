//
//  Models.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
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

struct ShowDetails: Decodable {
//    let success: Bool?
    var anime: Show?
}

struct UserJSON {
    
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
        case year = "year"
        
        // Ratings & ranks
        case averageRating = "average_rating"
        case ratingCount = "rating_count"
        case rank = "rank"
        case popularityRank = "popularity_rank"
        case startDate = "start_date"
        case endDate = "end_date"
        case producers = "producers"
        case nsfw = "nsfw"
        
        // Extra's
        case englishTitles = "english_titles"
        case japaneseTitles = "japanese_titles"
        case synonyms = "synonyms"
        case externalLinks = "external_links"
        case youtubeId = "youtube_id"
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
                return attributedString
            }
        }
        return nil
    }
//    public func linkAtIndex(index: Int) -> Link {
//        let linkData: AnyObject = externalLinks[index]
//        let externalLink = ExternalLink(rawValue: linkData["site"] as! String) ?? .Other
//
//        return Link(site: externalLink, url: (linkData["url"] as! String))
//    }
}
