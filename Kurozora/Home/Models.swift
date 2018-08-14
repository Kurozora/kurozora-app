//
//  Models.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

struct FeaturedShows: Decodable {
//    let success: Bool
    let banners: ShowCategory
    let categories: [ShowCategory]
}

struct ShowCategory: Decodable {
    var title: String?
    var shows: [Show]?
//    var type: String?
}

struct Show: Decodable {
    let id: String?
    let title: String?
    let genre: String?
    let imageName: String?
    let score: Double?
    let nsfw: Bool?
    
    let screenshots: [String]?
    let desc: String?
    let appInformation: [[String:String]]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case genre = "genre"
        case imageName = "poster_url"
        case score = "score"
        case nsfw = "nsfw"
        
        case screenshots = "Screenshots"
        case desc = "description"
        case appInformation = "appInformation"
    }
}
