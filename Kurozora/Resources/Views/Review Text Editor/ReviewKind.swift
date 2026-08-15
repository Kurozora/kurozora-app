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

	// MARK: - Properties
	/// The identifier of the wrapped model.
	var modelID: KurozoraItemID {
		switch self {
		case .character(let character): return character.id
		case .episode(let episode): return episode.id
		case .game(let game): return game.id
		case .literature(let literature): return literature.id
		case .person(let person): return person.id
		case .show(let show): return show.id
		case .song(let song): return song.id
		case .studio(let studio): return studio.id
		}
	}

	// MARK: - Functions
	/// Submits the user's rating and review for the wrapped model.
	///
	/// - Parameters:
	///    - rating: The rating value.
	///    - description: The optional review text.
	///    - note: The optional private note.
	///
	/// - Returns: `true` when the submission succeeds.
	func rate(using rating: Double, description: String?, note: String?) async throws(APIError) -> Bool {
		do {
			_ = try await self.rateRequest(score: rating)
				.description(description)
				.note(note)
				.response()

			return true
		} catch let error as APIError {
			print(error.localizedDescription)
			throw error
		} catch {
			print(error.localizedDescription)
			return false
		}
	}

	/// Fetches the rating categories of the wrapped model with the user's scores.
	///
	/// - Returns: The rating categories of the wrapped model. Empty when the model has none.
	func ratingCategories() async throws(APIError) -> [RatingCategory] {
		let ratingCategoriesRequest: RatingCategoriesRequest

		switch self {
		case .character: ratingCategoriesRequest = KService.ratingCategories(for: .characters)
		case .episode: ratingCategoriesRequest = KService.ratingCategories(for: .episodes)
		case .game: ratingCategoriesRequest = KService.ratingCategories(for: .games)
		case .literature: ratingCategoriesRequest = KService.ratingCategories(for: .literatures)
		case .person: ratingCategoriesRequest = KService.ratingCategories(for: .people)
		case .show: ratingCategoriesRequest = KService.ratingCategories(for: .shows)
		case .song: ratingCategoriesRequest = KService.ratingCategories(for: .songs)
		case .studio: ratingCategoriesRequest = KService.ratingCategories(for: .studios)
		}

		do {
			let ratingCategoryResponse = try await ratingCategoriesRequest
				.scores(of: self.modelID)
				.response()

			return ratingCategoryResponse.data
		} catch let error as APIError {
			print(error.localizedDescription)
			throw error
		} catch {
			print(error.localizedDescription)
			return []
		}
	}

	/// Submits the user's detailed rating and review for the wrapped model.
	///
	/// - Parameters:
	///    - ratingCategories: The scored rating categories.
	///    - description: The optional review text. Composed from the categories when absent.
	///    - note: The optional private note.
	///
	/// - Returns: `true` when the submission succeeds.
	func rate(categoryScores ratingCategories: [RatingCategory], description: String?, note: String?) async throws(APIError) -> Bool {
		let score = ratingCategories.weightedStarRating

		do {
			_ = try await self.rateRequest(score: score)
				.categoryScores(ratingCategories)
				.description(description)
				.note(note)
				.response()

			return true
		} catch let error as APIError {
			print(error.localizedDescription)
			throw error
		} catch {
			print(error.localizedDescription)
			return false
		}
	}

	/// Returns the rating request of the wrapped model.
	///
	/// - Parameter score: The rating to submit.
	private func rateRequest(score: Double) -> RateRequest {
		switch self {
		case .character(let character):
			return KService.rate(CharacterIdentity(id: character.id), score: score)
		case .episode(let episode):
			return KService.rate(EpisodeIdentity(id: episode.id), score: score)
		case .game(let game):
			return KService.rate(GameIdentity(id: game.id), score: score)
		case .literature(let literature):
			return KService.rate(LiteratureIdentity(id: literature.id), score: score)
		case .person(let person):
			return KService.rate(PersonIdentity(id: person.id), score: score)
		case .show(let show):
			return KService.rate(ShowIdentity(id: show.id), score: score)
		case .song(let song):
			return KService.rate(SongIdentity(id: song.id), score: score)
		case .studio(let studio):
			return KService.rate(StudioIdentity(id: studio.id), score: score)
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
