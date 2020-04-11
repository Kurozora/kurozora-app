//
//  Genres.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of genres.
*/
public class Genres: JSONDecodable {
	// MARK: - Properties
	/// The collection of genres.
	public let genres: [GenreElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
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

/**
	A mutable object that stores information about a single genre, such as the genre's name, color, and symbol.
*/
public class GenreElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the genre.
	public let id: Int?

	/// The name of the genre.
	public let name: String?

	/// The color of the genre.
	public let color: String?

	/// The link to the symbol of the genre.
	public let symbol: String?

	/// Whether the genre is Not Safe For Work.
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
