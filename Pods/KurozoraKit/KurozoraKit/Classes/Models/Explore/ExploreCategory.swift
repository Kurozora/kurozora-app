//
//  ExploreCategory.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

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
