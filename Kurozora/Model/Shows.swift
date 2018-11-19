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

//public struct FeaturedShows: Decodable {
//    //    let success: Bool
//    var banners: [Show]?
//    let categories: [ShowCategory]
//}
//
//struct ShowCategory: Decodable {
//    var title: String?
//    var shows: [Show]?
//    var type: String?
//}
//
//struct Show: Decodable {
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
//
//    // Ratings & ranks
//    let averageRating: Double?
//
//    // Extra's
//    let englishTitles: String?
//    let japaneseTitles: String?
//    let synonyms: String?
//    let externalLinks: String?
//    let youtubeId: String?
//
//    enum CodingKeys: String, CodingKey {
//        // General
//        case id = "id"
//        case title = "title"
//        case genre = "genre"
//        case poster = "poster"
//        case posterThumbnail = "poster_thumbnail"
//        case banner = "background"
//        case bannerThumbnail = "background_thumbnail"
//
//        // Details
//        case screenshots = "screenshots"
//        case synopsis = "synopsis"
//        case type = "type"
//        case episodes = "episodes"
//        case status = "status"
//        case aired = "aired"
//        case runtime = "runtime"
//        case watchRating = "watch_rating"
//
//        // Ratings & ranks
//        case averageRating = "average_rating"
//
//        // Extra's
//        case englishTitles = "english_titles"
//        case japaneseTitles = "japanese_titles"
//        case synonyms = "synonyms"
//        case externalLinks = "external_links"
//        case youtubeId = "youtube_id"
//    }
//    //    public func linkAtIndex(index: Int) -> Link {
//    //        let linkData: AnyObject = externalLinks[index]
//    //        let externalLink = ExternalLink(rawValue: linkData["site"] as! String) ?? .Other
//    //
//    //        return Link(site: externalLink, url: (linkData["url"] as! String))
//    //    }
//}

struct Show: JSONDecodable {
    let success: Bool?
    let banners: [JSON]?
    let categories: [JSON]?
    let message: String?

    init(json: JSON) throws {
        success = json["success"].boolValue
        banners = json["banners"].arrayValue
        categories = json["categories"].arrayValue
        message = json["message"].stringValue
    }
}
