//
//  Kurozora.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import Alamofire
import Keys

public struct KList {
    public var accessToken: String
    
    public enum Router: URLRequestConvertible {
        static let ClientID = KurozoraKeys().kListClientID
        static let ClientSecret = KurozoraKeys().kListClientSecret
        static let BaseURLString = GlobalVariables().BaseURLString
        
        case requestAccessToken()
        case browseAnime(year: Int?, season: AnimeSeason?, type: AnimeType?, status: AnimeStatus?, genres: [String]?, excludedGenres: [String]?, sort: AnimeSort, airingData: Bool, fullPage: Bool, page: Int?)
        case browseSeasonalChart(year: Int, season: AnimeSeason, sort: AnimeSort, airingData: Bool)
        case getAnime(id: Int)
        case searchAnime(query: String)
        
        public func asURLRequest() throws -> URLRequest {
            let (method, path, parameters): (Alamofire.HTTPMethod, String, [String: Any]) = {
                let accessToken = UserDefaults.standard.string(forKey: "access_token") ?? ""
                switch self {
                case .requestAccessToken:
                    let params = ["grant_type": "client_credentials", "client_id": Router.ClientID, "client_secret": Router.ClientSecret]
                    return (.post, "/auth/access_token", params)
                case .browseAnime(let year, let season, let type, let status, let genres, let excludedGenres, let sort, let airingData, let fullPage, let page):
                    var params = ["access_token":accessToken]
                    if let year = year {
                        params["year"] = String(year)
                    }
                    if let season = season {
                        params["season"] = season.rawValue
                    }
                    if let type = type {
                        params["type"] = type.rawValue
                    }
                    if let status = status {
                        params["status"] = status.rawValue
                    }
                    if let genres = genres {
                        params["genres"] = genres.joined(separator: ",")
                    }
                    if let excludedGenres = excludedGenres {
                        params["genres_exclude"] = excludedGenres.joined(separator: ",")
                    }
                    if let page = page, !fullPage {
                        params["page"] = String(page)
                    }
                    params["sort"] = sort.rawValue
                    params["airing_data"] = (airingData) ? "true" : "false"
                    params["full_page"] = (fullPage) ? "true" : "false"
                    if fullPage && status != AnimeStatus.CurrentlyAiring && season == nil {
                        print("Warning: status must be currently airing or a season must be provided when requesting fullPage")
                    }
                    
                    return (.get,"browse/anime",params)
                    
                case .browseSeasonalChart(let year, let season, let sort, let airingData):
                    var params = ["access_token":accessToken]
                    params["year"] = String(year)
                    params["season"] = season.rawValue
                    params["sort"] = sort.rawValue
                    params["airing_data"] = (airingData) ? "true" : "false"
                    params["full_page"] = "true"
                    
                    return (.get,"browse/anime",params)
                    
                case .getAnime(let id):
                    let params = ["access_token":accessToken]
                    return (.get,"anime/\(id)/page",params)
                case .searchAnime(let query):
                    let params = ["access_token":accessToken]
                    return (.get,"anime/search/\(query)",params)
                }
            }()
            
            let url = URL(string: Router.BaseURLString)!
            var request = URLRequest(url: url.appendingPathComponent(path))
            request.httpMethod = method.rawValue
            let encoding = Alamofire.URLEncoding.default
            
            return try! encoding.encode(request, with: parameters)
        }
    }
    
    public enum AnimeSeason: String {
        case Winter = "Winter"
        case Spring = "Spring"
        case Summer = "Summer"
        case Fall = "Fall"
    }
    
    public enum AnimeType: String {
        case Tv = "Tv"
        case Movie = "Movie"
        case Special = "Special"
        case OVA = "OVA"
        case ONA = "ONA"
        case TvShort = "Tv Short"
    }
    
    public enum AnimeStatus: String {
        case NotYetAired = "Not Yet Aired"
        case CurrentlyAiring = "Currently Airing"
        case FinishedAiring = "Finished Airing"
        case Cancelled = "Cancelled"
    }
    
    public enum AnimeSort: String {
        case Id = "id"
        case Score = "score"
        case Popularity = "popularity"
        case StartDate = "start_date"
        case EndDate = "end_date"
        
        func desc(sort: AnimeSort) -> String {
            return "\(sort.rawValue)-desc"
        }
    }
    
    public enum Genre: String {
        case Action = "Action"
        case Adult = "Adult"
        case Adventure = "Adventure"
        case Cars = "Cars"
        case Comedy = "Comedy"
        case Dementia = "Dementia"
        case Demons = "Demons"
        case Doujinshi = "Doujinshi"
        case Drama = "Drama"
        case Ecchi = "Ecchi"
        case Fantasy = "Fantasy"
        case Game = "Game"
        case GenderBender = "Gender Bender"
        case Harem = "Harem"
        case Hentai = "Hentai"
        case Historical = "Historical"
        case Horror = "Horror"
        case Josei = "Josei"
        case Kids = "Kids"
        case Magic = "Magic"
        case MartialArts = "Martial Arts"
        case Mature = "Mature"
        case Mecha = "Mecha"
        case Military = "Military"
        case MotionComic = "Motion Comic"
        case Music = "Music"
        case Mystery = "Mystery"
        case Mythological = "Mythological"
        case Parody = "Parody"
        case Police = "Police"
        case Psychological = "Psychological"
        case Romance = "Romance"
        case Samurai = "Samurai"
        case School = "School"
        case SciFi = "Sci-Fi"
        case Seinen = "Seinen"
        case Shoujo = "Shoujo"
        case ShoujoAi = "Shoujo Ai"
        case Shounen = "Shounen"
        case ShounenAi = "Shounen Ai"
        case SliceOfLife = "Slice Of Life"
        case Space = "Space"
        case Sports = "Sports"
        case SuperPower = "Super Power"
        case Supernatural = "Supernatural"
        case Thriller = "Thriller"
        case Tragedy = "Tragedy"
        case Vampire = "Vampire"
        case Yaoi = "Yaoi"
        case Yuri = "Yuri"
    }
}
