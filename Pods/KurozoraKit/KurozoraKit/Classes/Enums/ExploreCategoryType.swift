//
//  ExploreCategoryType.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2022.
//

/// List of available explore category type types.
public enum ExploreCategoryType: String, Codable {
	// MARK: - Cases
	/// Indicates that the explore category is of the `mostPopularShows` type.
	case mostPopularShows = "most-popular-shows"

	/// Indicates that the explore category is of the `upcomingShows` type.
	case upcomingShows = "upcoming-shows"

	/// Indicates that the explore category is of the `upcomingShows` type.
	case newShows = "new-shows"

	/// Indicates that the explore category is of the `shows` type.
	case shows

	/// Indicates that the explore category is of the `mostPopularLiteratures` type.
	case mostPopularLiteratures = "most-popular-literatures"

	/// Indicates that the explore category is of the `upcomingLiteratures` type.
	case upcomingLiteratures = "upcoming-literatures"

	/// Indicates that the explore category is of the `upcomingLiteratures` type.
	case newLiteratures = "new-literatures"

	/// Indicates that the explore category is of the `literatures` type.
	case literatures

	/// Indicates that the explore category is of the `mostPopularGames` type.
	case mostPopularGames = "most-popular-games"

	/// Indicates that the explore category is of the `upcomingGames` type.
	case upcomingGames = "upcoming-games"

	/// Indicates that the explore category is of the `newGames` type.
	case newGames = "new-games"

	/// Indicates that the explore category is of the `games` type.
	case games

	/// Indicates that the explore category is of the `upNextEpisodes` type.
	case upNextEpisodes = "up-next-episodes"

	/// Indicates that the explore category is of the `episodes` type.
	case episodes

	/// Indicates that the explore category is of the `songs` type.
	case songs

	/// Indicates that the explore category is of the `characters` type.
	case characters

	/// Indicates that the explore category is of the `people` type.
	case people

	/// Indicates that the explore category is of the `genres` type.
	case genres

	/// Indicates that the explore category is of the `themes` type.
	case themes

	/// Indicates that the explore category is of the `recap` type.
	case recap
}
