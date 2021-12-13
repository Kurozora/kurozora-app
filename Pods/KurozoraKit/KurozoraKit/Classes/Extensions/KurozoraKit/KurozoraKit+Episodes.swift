//
//  KurozoraKit+Episode.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON

extension KurozoraKit {
	/**
		Fetch the episode details for the given episode id.

		- Parameter episodeID: The id of the episode for which the details should be fetched.
		- Parameter relationships: The relationships to include in the response.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forEpisodeID episodeID: Int, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Episode], KKAPIError>) -> Void) {
		let episodesDetails = KKEndpoint.Shows.Episodes.details(episodeID).endpointValue
		let request: APIRequest<EpisodeResponse, KKAPIError> = tron.codable.request(episodesDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		request.perform(withSuccess: { episodeResponse in
			completionHandler(.success(episodeResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Episode's Details 😔", message: error.message)
			}
			print("❌ Received get episode details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Update an episode's watch status.

		- Parameter episodeID: The id of the episode that should be marked as watched/unwatched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateEpisodeWatchStatus(_ episodeID: Int, completion completionHandler: @escaping (_ result: Result<WatchStatus, KKAPIError>) -> Void) {
		let episodesWatched = KKEndpoint.Shows.Episodes.watched(episodeID).endpointValue
		let request: APIRequest<EpisodeUpdateResponse, KKAPIError> = tron.codable.request(episodesWatched)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .post
		request.perform(withSuccess: { episodeUpdateResponse in
			completionHandler(.success(episodeUpdateResponse.data.watchStatus))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Update Episode 😔", message: error.message)
			}
			print("❌ Received mark episode error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Rate the show with the given show id.

		- Parameter episodeID: The id of the show which should be rated.
		- Parameter score: The rating to leave.
		- Parameter description: The description of the rating.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func rateEpisode(_ episodeID: Int, with score: Double, description: String?, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let showsRate = KKEndpoint.Shows.Episodes.rate(episodeID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(showsRate)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .post
		request.parameters = [
			"rating": score
		]
		if let description = description {
			request.parameters["description"] = description
		}

		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Rate Show 😔", message: error.message)
			}
			print("❌ Received show rating error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
