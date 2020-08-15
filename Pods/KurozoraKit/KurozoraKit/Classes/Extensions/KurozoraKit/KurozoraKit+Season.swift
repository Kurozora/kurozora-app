//
//  KurozoraKit+Season.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the episodes for the given season id.

		- Parameter seasonID: The id of the season for which the episodes should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getEpisodes(forSeasonID seasonID: Int, completion completionHandler: @escaping (_ result: Result<[Episode], KKAPIError>) -> Void) {
		let animeSeasonsEpisodes = self.kurozoraKitEndpoints.animeSeasonsEpisodes.replacingOccurrences(of: "?", with: "\(seasonID)")
		let request: APIRequest<EpisodeResponse, KKAPIError> = tron.codable.request(animeSeasonsEpisodes)

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
				SCLAlertView().showError("Can't get episodes list 😔", subTitle: error.message)
			}
			print("❌ Received get show episodes error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
