//
//  Models.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

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

//struct Banner: Decodable {
//    let id: Int?
//    let title: String?
//    let genre: String?
//    let bannerUrl: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case title = "title"
//        case genre = "genre"
//        case bannerUrl = "background_url"
//    }
//}

struct Show: Decodable {
    let id: Int?
    let title: String?
    let genre: String?
    let posterUrl: String?
    let bannerUrl: String?
    let score: Double?
    
    let screenshots: [String]?
    let desc: String?
    let appInformation: [[String:String]]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case genre = "genre"
        case posterUrl = "poster_url"
        case bannerUrl = "background_url"
        case score = "score"
        
        case screenshots = "Screenshots"
        case desc = "description"
        case appInformation = "appInformation"
    }
}
