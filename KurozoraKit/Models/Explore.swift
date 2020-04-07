//
//  Explore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class Explore: JSONDecodable {
    public let success: Bool?
	public let categories: [ExploreCategory]?

    required public init(json: JSON) throws {
		self.success = json["success"].boolValue

		var categories = [ExploreCategory]()
		let categoriesArray = json["categories"].arrayValue
		for categoriesItem in categoriesArray {
			if let exploreCategories = try? ExploreCategory(json: categoriesItem) {
				categories.append(exploreCategories)
			}
		}
		self.categories = categories
    }
}

public class ExploreCategory: JSONDecodable {
	public let title: String?
	public let size: String?
	public let shows: [ShowDetailsElement]?
	public let genres: [GenreElement]?

	required public init(json: JSON) throws {
		self.title = json["title"].stringValue
		self.size = json["size"].stringValue

		var shows = [ShowDetailsElement]()
		let showsArray = json["shows"].arrayValue
		for showItem in showsArray {
			if let showDetailsElement = try? ShowDetailsElement(json: showItem) {
				shows.append(showDetailsElement)
			}
		}
		self.shows = shows

		var genres = [GenreElement]()
		let genresArray = json["genres"].arrayValue
		for genreItem in genresArray {
			if let genre = try? GenreElement(json: genreItem) {
				genres.append(genre)
			}
		}
		self.genres = genres
	}
}
