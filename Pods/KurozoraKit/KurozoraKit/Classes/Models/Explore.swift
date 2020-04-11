//
//  Explore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of explore categories.
*/
public class Explore: JSONDecodable {
	// MARK: - Properties
	/// The collection of categories.
	public let categories: [ExploreCategory]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
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

/**
	A mutable object that stores information about a single explore category, such as the category's title, size, and collection of shows.
*/
public class ExploreCategory: JSONDecodable {
	// MARK: - Properties
	/// The title of the category.
	public let title: String?

	/// The size of the category.
	public let size: String?

	/// The collection of shows in the category.
	public let shows: [ShowDetailsElement]?

	/// The collection of genres in the category.
	public let genres: [GenreElement]?

	// MARK: - Initializers
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
