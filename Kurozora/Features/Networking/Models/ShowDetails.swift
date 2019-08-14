//
//  ShowDetails.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ShowDetails: JSONDecodable {
	var showDetailsElement: ShowDetailsElement?
	var userProfile: UserProfile?

	required init(json: JSON) throws {
		let showDetailsJson = json["anime"]
		let userProfileJson = json["user"]

		let showDetailsElement = try? ShowDetailsElement(json: showDetailsJson)
		let userProfile = try? UserProfile(json: userProfileJson)

		self.showDetailsElement = showDetailsElement
		self.userProfile = userProfile
	}
}

class ShowDetailsElement: JSONDecodable {
    // General
    let id: Int?
	let imdbId: String?
    let title: String?
    let genres: [GenreElement]?
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
	let languages: String?
    let englishTitles: String?
    let japaneseTitles: String?
    let synonyms: String?
    let externalLinks: String?
    let videoUrl: String?

    required init(json: JSON) throws {
        // Anime
        id = json["id"].intValue
		imdbId = json["imdb_id"].stringValue
        title = json["title"].stringValue
		var genres = [GenreElement]()

		let genresArray = json["genres"].arrayValue
		for genreItem in genresArray {
			if let genreElement = try? GenreElement(json: genreItem) {
				genres.append(genreElement)
			}
		}

		self.genres = genres
        poster = json["poster"].stringValue
        posterThumbnail = json["poster_thumbnail"].stringValue
        banner = json["background"].stringValue
        bannerThumbnail = json["background_thumbnail"].stringValue
        
        // Details
        screenshots = json["screenshots"].rawValue as? [String]
        synopsis = json["synopsis"].stringValue
        type = json["type"].stringValue
        seasons = json["seasons"].intValue
        episodes = json["episodes"].intValue
        status = json["status"].stringValue
        aired = json["aired"].stringValue
        runtime = json["runtime"].intValue
        watchRating = json["watch_rating"].stringValue
        year = json["year"].intValue
        
        // Ratings & ranks
        averageRating = json["average_rating"].doubleValue
        ratingCount = json["rating_count"].intValue
        rank = json["rank"].intValue
        popularityRank = json["popularity_rank"].intValue
        startDate = json["start_date"].rawValue as? Date
        endDate = json["end_date"].rawValue as? Date
        network = json["network"].stringValue
        producers = json["producers"].stringValue
        nsfw = json["nsfw"].boolValue
        
        // Extra's
		languages = json["languages"].stringValue
        englishTitles = json["english_titles"].stringValue
        japaneseTitles = json["japanese_titles"].stringValue
        synonyms = json["synonyms"].stringValue
        externalLinks = json["external_links"].stringValue
        videoUrl = json["video_url"].stringValue
    }
    
    public func informationString() -> String {
		let episodes = (self.episodes != 0) ? self.episodes : 0
        let runtime = (self.runtime != 0) ? self.runtime : 0
        let year = (self.year != 0) ? self.year : 0000
        return "\(type ?? "Unknown") · \(watchRating ?? "N/A") · \(episodes ?? 0) eps · \(runtime ?? 0) min · \(year ?? 0000)"
    }
    
    public func attributedSynopsis() -> NSAttributedString? {
        if let synopsis = synopsis, let data = synopsis.data(using: String.Encoding.unicode) {
            let font = UIFont.systemFont(ofSize: 17)
            
            if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil) {
                attributedString.addAttribute(.font, value: font, range: NSMakeRange(0, attributedString.length))
                return attributedString
            }
        }
        return nil
    }
}

