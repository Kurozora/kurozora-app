//
//  ReviewKind.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

/// A wrapper around any model that can be rated and reviewed.
enum ReviewKind {
	case character(_ character: Character)
	case episode(_ episode: Episode)
	case game(_ game: Game)
	case literature(_ literature: Literature)
	case person(_ person: Person)
	case show(_ show: Show)
	case song(_ song: Song)
	case studio(_ studio: Studio)

	// MARK: - Functions
	/// Submits the user's rating and review for the wrapped model.
	///
	/// - Parameters:
	///    - rating: The rating value.
	///    - description: The optional review text.
	///
	/// - Returns: `true` when the submission succeeds.
	func rate(using rating: Double, description: String?) async throws(APIError) -> Bool {
		switch self {
		case .character(let character):
			return try await character.rate(using: rating, description: description) != nil
		case .episode(let episode):
			return try await episode.rate(using: rating, description: description) != nil
		case .game(let game):
			return try await game.rate(using: rating, description: description) != nil
		case .literature(let literature):
			return try await literature.rate(using: rating, description: description) != nil
		case .person(let person):
			return try await person.rate(using: rating, description: description) != nil
		case .show(let show):
			return try await show.rate(using: rating, description: description) != nil
		case .song(let song):
			return try await song.rate(using: rating, description: description) != nil
		case .studio(let studio):
			return try await studio.rate(using: rating, description: description) != nil
		}
	}

	/// Deletes the user's rating and review for the wrapped model.
	///
	/// - Returns: `true` when the deletion succeeds.
	func deleteRating() async throws(APIError) -> Bool {
		switch self {
		case .character(let character): return try await character.deleteRating()
		case .episode(let episode): return try await episode.deleteRating()
		case .game(let game): return try await game.deleteRating()
		case .literature(let literature): return try await literature.deleteRating()
		case .person(let person): return try await person.deleteRating()
		case .show(let show): return try await show.deleteRating()
		case .song(let song): return try await song.deleteRating()
		case .studio(let studio): return try await studio.deleteRating()
		}
	}
}
