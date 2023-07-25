//
//  ReviewTextEditorWorker.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ReviewTextEditorWorkerLogic {
	func rateShow(_ showIdentity: ShowIdentity, rating: Double, review: String?) async -> (isSuccess: Bool, message: String?)
	func rateLiterature(_ literatureIdentity: LiteratureIdentity, rating: Double, review: String?) async -> (isSuccess: Bool, message: String?)
	func rateGame(_ gameIdentity: GameIdentity, rating: Double, review: String?) async -> (isSuccess: Bool, message: String?)
	func rateEpisode(_ episodeIdentity: EpisodeIdentity, rating: Double, review: String?) async -> (isSuccess: Bool, message: String?)
}

// MARK: - WorkerLogic
final class ReviewTextEditorWorker: ReviewTextEditorWorkerLogic {
	func rateShow(_ showIdentity: ShowIdentity, rating: Double, review: String?) async -> (isSuccess: Bool, message: String?) {
		do {
			_ = try await KService.rateShow(showIdentity, with: rating, description: review).value
			return (isSuccess: true, message: nil)
		} catch let error as KKAPIError {
			print("-----", error.message)
			return (isSuccess: false, message: error.message)
		} catch {
			print("-----", error.localizedDescription)
			return (isSuccess: false, message: error.localizedDescription)
		}
	}

	func rateLiterature(_ literatureIdentity: LiteratureIdentity, rating: Double, review: String?) async -> (isSuccess: Bool, message: String?) {
		do {
			_ = try await KService.rateLiterature(literatureIdentity, with: rating, description: review).value
			return (isSuccess: true, message: nil)
		} catch let error as KKAPIError {
			print("-----", error.message)
			return (isSuccess: false, message: error.message)
		} catch {
			print("-----", error.localizedDescription)
			return (isSuccess: false, message: error.localizedDescription)
		}
	}

	func rateGame(_ gameIdentity: GameIdentity, rating: Double, review: String?) async -> (isSuccess: Bool, message: String?) {
		do {
			_ = try await KService.rateGame(gameIdentity, with: rating, description: review).value
			return (isSuccess: true, message: nil)
		} catch let error as KKAPIError {
			print("-----", error.message)
			return (isSuccess: false, message: error.message)
		} catch {
			print("-----", error.localizedDescription)
			return (isSuccess: false, message: error.localizedDescription)
		}
	}

	func rateEpisode(_ episodeIdentity: EpisodeIdentity, rating: Double, review: String?) async -> (isSuccess: Bool, message: String?) {
		do {
			_ = try await KService.rateEpisode(episodeIdentity, with: rating, description: review).value
			return (isSuccess: true, message: nil)
		} catch let error as KKAPIError {
			print("-----", error.message)
			return (isSuccess: false, message: error.message)
		} catch {
			print("-----", error.localizedDescription)
			return (isSuccess: false, message: error.localizedDescription)
		}
	}
}
