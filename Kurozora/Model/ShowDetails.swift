//
//  ShowDetails.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

struct ShowDetails: JSONDecodable {
    // General
    let id: Int?
	let imdbId: String?
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
    let seasons: Int?
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
    let network: String?
    let producers: String?
    let nsfw: Bool?
    
    // Extra's
    let englishTitles: String?
    let japaneseTitles: String?
    let synonyms: String?
    let externalLinks: String?
    let youtubeId: String?
    
    // User
    var currentRating: Double?
	var libraryStatus: String?
    
    init(json: JSON) throws {
        // Anime
        id = json["anime"]["id"].intValue
		imdbId = json["anime"]["imdb_id"].stringValue
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
        seasons = json["anime"]["seasons"].intValue
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
        network = json["anime"]["network"].stringValue
        producers = json["anime"]["producers"].stringValue
        nsfw = json["anime"]["nsfw"].boolValue
        
        // Extra's
        englishTitles = json["anime"]["english_titles"].stringValue
        japaneseTitles = json["anime"]["japanese_titles"].stringValue
        synonyms = json["anime"]["synonyms"].stringValue
        externalLinks = json["anime"]["external_links"].stringValue
        youtubeId = json["anime"]["youtube_id"].stringValue
        
        // User
        currentRating = json["user"]["current_rating"].doubleValue
		libraryStatus = json["user"]["library_status"].stringValue
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
                options: [.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil) {
                attributedString.addAttribute(.font, value: font, range: NSMakeRange(0, attributedString.length))
                attributedString.addAttribute(.foregroundColor, value: UIColor.white , range:  NSMakeRange(0, attributedString.length))
                return attributedString
            }
        }
        return nil
    }
}

