//
//  Library.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

//import TRON
//import SwiftyJSON
//
//class Library: JSONDecodable {
//	let success: Bool?
//	let library: [LibraryElement]?
//
//	required init(json: JSON) throws {
//		self.success = json["success"].boolValue
//
//		var library = [LibraryElement]()
//		let libraryArray = json["anime"].arrayValue
//		for libraryItem in libraryArray {
//			if let libraryElement = try? LibraryElement(json: libraryItem) {
//				library.append(libraryElement)
//			}
//		}
//		self.library = library
//	}
//}
//
//class LibraryElement: JSONDecodable {
//	let id: Int?
//	let title: String?
//	let episodeCount: Int?
//	let averageRating: Double?
//	let posterThumbnail: String?
//	let backgroundThumbnail: String?
//
//	required init(json: JSON) throws {
//		self.id = json["id"].intValue
//		self.title = json["title"].stringValue
//		self.episodeCount = json["episode_count"].intValue
//		self.averageRating = json["average_rating"].doubleValue
//		self.posterThumbnail = json["poster_thumbnail"].stringValue
//		self.backgroundThumbnail = json["background_thumbnail"].stringValue
//	}
//}
