//
//  Genres.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class Genres: JSONDecodable {
	// MARK: - Properties
	internal let success: Bool?
	public let genres: [GenreElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
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

public class GenreElement: JSONDecodable {
	// MARK: - Properties
	public let id: Int?
	public let name: String?
	public let color: String?
	public let symbol: String?
	public let nsfw: Bool?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.color = json["color"].stringValue
		self.symbol = json["symbol"].stringValue
		self.nsfw = json["nsfw"].boolValue
	}
}
