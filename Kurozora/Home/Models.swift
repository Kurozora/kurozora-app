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

struct ShowDetails: Decodable {
//    let success: Bool?
    var anime: Show?
}

struct Show: Decodable {
    let id: Int?
    let title: String?
    let genre: String?
    let poster: String?
    let posterThumbnail: String?
    let banner: String?
    let bannerThumbnail: String?
    let score: Double?
    
    let screenshots: [String]?
    let synopsis: String?
    let type: String?
    let episodes: Int?
    let status: String?
    let aired: String?
    let runtime: Int?
    let watchRating: String?
    let nsfw: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case genre = "genre"
        case posterThumbnail = "poster_thumbnail"
        case poster = "poster"
        case bannerThumbnail = "background_thumbnail"
        case banner = "background"
        case score = "score"
        
        case screenshots = "screenshots"
        case synopsis = "synopsis"
        case type = "type"
        case episodes = "episodes"
        case status = "status"
        case aired = "aired"
        case runtime = "runtime"
        case watchRating = "watch_rating"
        case nsfw = "nsfw"
    }
}
