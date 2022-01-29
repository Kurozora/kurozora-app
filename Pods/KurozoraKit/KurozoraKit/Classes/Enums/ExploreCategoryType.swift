//
//  ExploreCategoryType.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2022.
//

/**
	List of available explore category type types.
*/
public enum ExploreCategoryType: String, Codable {
	// MARK: - Cases
	/// Indicates that the explore category is of the `mostPopularShows` type.
	case mostPopularShows = "most-popular-shows"

	/// Indicates that the explore category is of the `upcomingShows` type.
	case upcomingShows = "upcoming-shows"

	/// Indicates that the explore category is of the `shows` type.
	case shows

	/// Indicates that the explore category is of the `characters` type.
	case characters

	/// Indicates that the explore category is of the `people` type.
	case people

	/// Indicates that the explore category is of the `genres` type.
	case genres

	/// Indicates that the explore category is of the `themes` type.
	case themes
}
