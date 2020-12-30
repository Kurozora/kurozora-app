//
//  KurozoraKit+Season.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON

extension KurozoraKit {
	/**
		Fetch the season details for the given season id.

		- Parameter seasonID: The id of the season for which the details should be fetched.
		- Parameter relationships: The relationships to include in the response.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forSeasonID seasonID: Int, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Season], KKAPIError>) -> Void) {
		let seasonsDetails = KKEndpoint.Shows.Seasons.details(seasonID).endpointValue
		let request: APIRequest<SeasonResponse, KKAPIError> = tron.codable.request(seasonsDetails)

		request.headers = headers

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		request.perform(withSuccess: { seasonResponse in
			completionHandler(.success(seasonResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Season's Details 😔", message: error.message)
			}
			print("❌ Received get season details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the episodes for the given season id.

		- Parameter seasonID: The id of the season for which the episodes should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getEpisodes(forSeasonID seasonID: Int, completion completionHandler: @escaping (_ result: Result<[Episode], KKAPIError>) -> Void) {
		let seasonsEpisodes = KKEndpoint.Shows.Seasons.episodes(seasonID).endpointValue
		let request: APIRequest<EpisodeResponse, KKAPIError> = tron.codable.request(seasonsEpisodes)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { episodeResponse in
			completionHandler(.success(episodeResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Episodes List 😔", message: error.message)
			}
			print("❌ Received get show episodes error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}