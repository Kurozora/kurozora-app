//
//  ReviewSubject.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// A wrapper around any model that can be rated and reviewed.
enum ReviewSubject {
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

	/// The kind discriminator of the wrapped model.
	var noteKind: ReviewKind {
		switch self {
		case .character: return .characters
		case .episode: return .episodes
		case .game: return .games
		case .literature: return .literatures
		case .person: return .people
		case .show: return .shows
		case .song: return .songs
		case .studio: return .studios
		}
	}

	// MARK: - Functions
	/// Returns the user's stored note on the wrapped model.
	@MainActor
	func storedNote() -> String? {
		guard let userSlug = User.current?.attributes.slug else { return nil }

		return NoteStore.shared.note(for: self.modelID.rawValue, userSlug: userSlug, kind: self.noteKind)
	}

	/// Writes the user's note on the wrapped model, clearing it when the body is empty.
	///
	/// - Parameter note: The note to write.
	func setNote(_ note: String?) async {
		do {
			_ = try await KService.setNote(on: self.modelID, kind: self.noteKind, body: note).response()

			if let userSlug = User.current?.attributes.slug {
				await NoteStore.shared.apply(note, itemID: self.modelID.rawValue, userSlug: userSlug, kind: self.noteKind)
			}
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Submits the user's rating and review for the wrapped model.
	///
	/// - Parameters:
	///    - rating: The rating value.
	///    - description: The optional review text.
	///    - isSpoiler: Whether the review contains spoiler material.
	///    - recommendation: The reviewer's recommendation.
	///
	/// - Returns: `true` when the submission succeeds.
	func rate(using rating: Double, description: String?, isSpoiler: Bool, recommendation: ReviewRecommendation?) async throws(APIError) -> Bool {
		do {
			var rateRequest = self.rateRequest(score: rating)
				.description(description)
				.isSpoiler(isSpoiler)

			if let recommendation {
				rateRequest = rateRequest.recommendation(recommendation)
			}

			let reviewIdentity = try await rateRequest.response().data.first

			await self.applyToLocalLibrary(score: rating, description: description, isSpoiler: isSpoiler, recommendation: recommendation)
			self.postReviewDidUpdate(for: reviewIdentity)
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
	///    - isSpoiler: Whether the review contains spoiler material.
	///    - recommendation: The reviewer's recommendation.
	///
	/// - Returns: `true` when the submission succeeds.
	func rate(categoryScores ratingCategories: [RatingCategory], description: String?, isSpoiler: Bool, recommendation: ReviewRecommendation?) async throws(APIError) -> Bool {
		let score = ratingCategories.weightedStarRating

		do {
			var rateRequest = self.rateRequest(score: score)
				.categoryScores(ratingCategories)
				.description(description)
				.isSpoiler(isSpoiler)

			if let recommendation {
				rateRequest = rateRequest.recommendation(recommendation)
			}

			let reviewIdentity = try await rateRequest.response().data.first

			await self.applyToLocalLibrary(score: score, description: description, isSpoiler: isSpoiler, recommendation: recommendation)
			self.postReviewDidUpdate(for: reviewIdentity)
			return true
		} catch let error as APIError {
			print(error.localizedDescription)
			throw error
		} catch {
			print(error.localizedDescription)
			return false
		}
	}

	/// Announces the submitted review so the open lists refresh that one row.
	///
	/// - Parameter reviewIdentity: The identity of the submitted review.
	private func postReviewDidUpdate(for reviewIdentity: ReviewIdentity?) {
		guard let reviewIdentity = reviewIdentity else { return }

		NotificationCenter.default.post(name: .KReviewDidUpdate, object: nil, userInfo: ["reviewID": reviewIdentity.id])
	}

	/// The library kind of the wrapped model. `nil` when the model is not trackable in the library.
	private var libraryKind: LibraryKind? {
		switch self {
		case .game: return .games
		case .literature: return .literatures
		case .show: return .shows
		case .character, .episode, .person, .song, .studio: return nil
		}
	}

	/// Writes the submitted rating to the wrapped model's local library entry.
	///
	/// - Parameters:
	///    - score: The submitted rating.
	///    - description: The submitted review text.
	///    - isSpoiler: Whether the submitted review contains spoiler material.
	///    - recommendation: The submitted recommendation.
	private func applyToLocalLibrary(score: Double, description: String?, isSpoiler: Bool, recommendation: ReviewRecommendation?) async {
		guard let libraryKind = self.libraryKind, let userSlug = User.current?.attributes.slug else { return }

		await LibraryStore.shared.applyRating(score: score, description: description, isSpoiler: isSpoiler, recommendation: recommendation, forTrackableID: self.modelID.rawValue, userSlug: userSlug, kind: libraryKind)
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
	/// The deletion is announced by whichever path learns the review's identity.
	///
	/// - Returns: `true` when the deletion succeeds.
	func deleteRating() async throws(APIError) -> Bool {
		return try await self.deleteRatingRequest()
	}

	/// Sends the deletion of the user's rating and review for the wrapped model.
	///
	/// - Returns: `true` when the deletion succeeds.
	private func deleteRatingRequest() async throws(APIError) -> Bool {
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
