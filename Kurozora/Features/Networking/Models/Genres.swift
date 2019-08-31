//
//  Genres.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Genres: JSONDecodable {
	let success: Bool?
	let genres: [GenreElement]?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		var genres = [GenreElement]()

		let genresArray = json["genres"].arrayValue
		for genreItem in genresArray {
			if let genreElement = try? GenreElement(json: genreItem) {
				genres.append(genreElement)
			}
		}

		self.genres = genres
	}
}

class GenreElement: JSONDecodable {
	let id: Int?
	let name: String?
	let color: String?
	let symbol: String?
	let nsfw: Bool?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.color = json["color"].stringValue
		self.symbol = json["symbol"].stringValue
		self.nsfw = json["nsfw"].boolValue
	}
}
