//
//  Kurozora.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation
import Alamofire

public struct KList {
	public var accessToken: String

	//    public enum Router: URLRequestConvertible {
	//        static let ClientID = ""
	//        static let ClientSecret = ""
	//        static let BaseURLString = GlobalVariables().baseUrlString
	//
	//        case requestAccessToken()
	//        case browseAnime(year: Int?, season: AnimeSeason?, type: AnimeType?, status: AnimeStatus?, genres: [String]?, excludedGenres: [String]?, sort: AnimeSort, airingData: Bool, fullPage: Bool, page: Int?)
	//        case browseSeasonalChart(year: Int, season: AnimeSeason, sort: AnimeSort, airingData: Bool)
	//        case getAnime(id: Int)
	//        case searchAnime(query: String)
	//
	//        public func asURLRequest() throws -> URLRequest {
	//            let (method, path, parameters): (Alamofire.HTTPMethod, String, [String: Any]) = {
	//                let accessToken = UserDefaults.standard.string(forKey: "access_token") ?? ""
	//                switch self {
	//                case .requestAccessToken:
	//                    let params = ["grant_type": "client_credentials", "client_id": Router.ClientID, "client_secret": Router.ClientSecret]
	//                    return (.post, "/auth/access_token", params)
	//                case .browseAnime(let year, let season, let type, let status, let genres, let excludedGenres, let sort, let airingData, let fullPage, let page):
	//                    var params = ["access_token":accessToken]
	//                    if let year = year {
	//                        params["year"] = String(year)
	//                    }
	//                    if let season = season {
	//                        params["season"] = season.rawValue
	//                    }
	//                    if let type = type {
	//                        params["type"] = type.rawValue
	//                    }
	//                    if let status = status {
	//                        params["status"] = status.rawValue
	//                    }
	//                    if let genres = genres {
	//                        params["genres"] = genres.joined(separator: ",")
	//                    }
	//                    if let excludedGenres = excludedGenres {
	//                        params["genres_exclude"] = excludedGenres.joined(separator: ",")
	//                    }
	//                    if let page = page, !fullPage {
	//                        params["page"] = String(page)
	//                    }
	//                    params["sort"] = sort.rawValue
	//                    params["airing_data"] = (airingData) ? "true" : "false"
	//                    params["full_page"] = (fullPage) ? "true" : "false"
	//                    if fullPage && status != AnimeStatus.CurrentlyAiring && season == nil {
	//                        print("Warning: status must be currently airing or a season must be provided when requesting fullPage")
	//                    }
	//
	//                    return (.get,"browse/anime",params)
	//
	//                case .browseSeasonalChart(let year, let season, let sort, let airingData):
	//                    var params = ["access_token":accessToken]
	//                    params["year"] = String(year)
	//                    params["season"] = season.rawValue
	//                    params["sort"] = sort.rawValue
	//                    params["airing_data"] = (airingData) ? "true" : "false"
	//                    params["full_page"] = "true"
	//
	//                    return (.get,"browse/anime",params)
	//
	//                case .getAnime(let id):
	//                    let params = ["access_token":accessToken]
	//                    return (.get,"anime/\(id)/page",params)
	//                case .searchAnime(let query):
	//                    let params = ["access_token":accessToken]
	//                    return (.get,"anime/search/\(query)",params)
	//                }
	//            }()
	//
	//            let url = URL(string: Router.BaseURLString)!
	//            var request = URLRequest(url: url.appendingPathComponent(path))
	//            request.httpMethod = method.rawValue
	//            let encoding = Alamofire.URLEncoding.default
	//
	//            return try! encoding.encode(request, with: parameters)
	//        }
	//    }

	public enum AnimeSeason: String {
		case winter = "Winter"
		case spring = "Spring"
		case summer = "Summer"
		case fall = "Fall"
	}

	public enum AnimeType: String {
		case tv = "Tv"
		case movie = "Movie"
		case special = "Special"
		case ova = "OVA"
		case ona = "ONA"
		case tvShort = "Tv Short"
	}

	public enum AnimeStatus: String {
		case notYetAired = "Not Yet Aired"
		case currentlyAiring = "Currently Airing"
		case finishedAiring = "Finished Airing"
		case cancelled = "Cancelled"
	}

	public enum AnimeSort: String {
		case id = "id"
		case score = "score"
		case popularity = "popularity"
		case startDate = "start_date"
		case endDate = "end_date"

		func desc(sort: AnimeSort) -> String {
			return "\(sort.rawValue)-desc"
		}
	}

	public enum Genre: String {
		case action = "Action"
		case adult = "Adult"
		case adventure = "Adventure"
		case cars = "Cars"
		case comedy = "Comedy"
		case dementia = "Dementia"
		case demons = "Demons"
		case doujinshi = "Doujinshi"
		case drama = "Drama"
		case ecchi = "Ecchi"
		case fantasy = "Fantasy"
		case game = "Game"
		case genderBender = "Gender Bender"
		case harem = "Harem"
		case hentai = "Hentai"
		case historical = "Historical"
		case horror = "Horror"
		case josei = "Josei"
		case kids = "Kids"
		case magic = "Magic"
		case martialArts = "Martial Arts"
		case mature = "Mature"
		case mecha = "Mecha"
		case military = "Military"
		case motionComic = "Motion Comic"
		case music = "Music"
		case mystery = "Mystery"
		case mythological = "Mythological"
		case parody = "Parody"
		case police = "Police"
		case psychological = "Psychological"
		case romance = "Romance"
		case samurai = "Samurai"
		case school = "School"
		case sciFi = "Sci-Fi"
		case seinen = "Seinen"
		case shoujo = "Shoujo"
		case shoujoAi = "Shoujo Ai"
		case shounen = "Shounen"
		case shounenAi = "Shounen Ai"
		case sliceOfLife = "Slice Of Life"
		case space = "Space"
		case sports = "Sports"
		case superPower = "Super Power"
		case supernatural = "Supernatural"
		case thriller = "Thriller"
		case tragedy = "Tragedy"
		case vampire = "Vampire"
		case yaoi = "Yaoi"
		case yuri = "Yuri"
	}
}
