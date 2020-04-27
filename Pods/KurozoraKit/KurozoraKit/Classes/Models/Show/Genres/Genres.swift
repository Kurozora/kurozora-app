//
//  Genres.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

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
