//
//  Search.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/05/2022.
//

/// A root object that stores information about a search resource.
public struct Search: Codable, Sendable {
	// MARK: - Properties
	/// A collection of characters.
	public let characters: CharacterIdentityResponse?

	/// A collection of episodes.
	public let episodes: EpisodeIdentityResponse?

	/// A collection of games.
	public let games: GameIdentityResponse?

	/// A collection of literatures.
	public let literatures: LiteratureIdentityResponse?

	/// A collection of people.
	public let people: PersonIdentityResponse?

	/// A collection of seasons.
	public let seasons: SeasonIdentityResponse?

	/// A collection of shows.
	public let shows: ShowIdentityResponse?

	/// A collection of songs.
	public let songs: SongIdentityResponse?

	/// A collection of studios.
	public let studios: StudioIdentityResponse?

	/// A collection of users.
	public let users: UserIdentityResponse?
}
