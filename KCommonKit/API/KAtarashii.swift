//
//  KAtarashii.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import Alamofire

public enum SyncState: Int {
    case InSync = 0
    case Created
    case Updated
    case Deleted
}

public enum MALList: String {
    case Planning = "plan to watch"
    case Watching = "watching"
    case Completed = "completed"
    case Dropped = "dropped"
    case OnHold = "on-hold"
}

public struct MALProgress: Hashable {
    public var myAnimeListID: Int
    public var status: String
    public var episodes: Int
    public var score: Int
    public var syncState: SyncState = .InSync
    
    public init(myAnimeListID: Int, status: MALList, episodes: Int, score: Int) {
        self.myAnimeListID = myAnimeListID
        self.status = status.rawValue
        self.episodes = episodes
        self.score = score
    }
    
    func toDictionary() -> [String: Any] {
        return ["anime_id": myAnimeListID, "status": status, "episodes": episodes, "score": score]
    }
    
    public var hashValue: Int {
        get {
            return myAnimeListID
        }
    }
}

public func ==(lhs: MALProgress, rhs: MALProgress) -> Bool {
    return lhs.myAnimeListID == rhs.myAnimeListID
}

public struct KAtarashii {
    
    public var accessToken: String
    
    enum Router: URLRequestConvertible {
        static let BaseURLString = "https://api.atarashiiapp.com/2"
        
        case animeCast(id: Int)
        case verifyCredentials()
        case animeList(username: String)
        case profile(username: String)
        case friends(username: String)
        case history(username: String)
        case animeAdd(progress: MALProgress)
        case animeUpdate(progress: MALProgress)
        case animeDelete(id: Int)
        
        func asURLRequest() throws -> URLRequest {
            let (method, path, parameters): (Alamofire.HTTPMethod, String, [String: Any]) = {
                switch self {
                case .animeCast(let id):
                    return (.get,"anime/cast/\(id)",[:])
                case .verifyCredentials():
                    return (.get,"account/verify_credentials",[:])
                case .animeList(let username):
                    return (.get,"animelist/\(username)",[:])
                case .profile(let username):
                    return (.get,"profile/\(username)",[:])
                case .friends(let username):
                    return (.get,"friends/\(username)",[:])
                case .history(let username):
                    return (.get,"history/\(username)",[:])
                case .animeAdd(let progress):
                    return (.post,"animelist/anime", progress.toDictionary())
                case .animeUpdate(let progress):
                    return (.put,"animelist/anime/\(progress.myAnimeListID)", progress.toDictionary())
                case .animeDelete(let id):
                    return (.delete,"animelist/anime/\(id)",[:])
                }
            }()
        
            let url = URL(string: Router.BaseURLString)!
            var request = URLRequest(url: url.appendingPathComponent(path))
            request.httpMethod = method.rawValue
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
            let encoding = Alamofire.URLEncoding.default
            
            return try! encoding.encode(request, with: parameters.count > 0 ? parameters : nil)
        }
    }
}
