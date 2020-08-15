//
//  KurozoraKit+Episode.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Update an episode's watch status.

		- Parameter episodeID: The id of the episode that should be marked as watched/unwatched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateEpisodeWatchStatus(_ episodeID: Int, completion completionHandler: @escaping (_ result: Result<WatchStatus, KKAPIError>) -> Void) {
		let animeEpisodesWatched = self.kurozoraKitEndpoints.animeEpisodesWatched.replacingOccurrences(of: "?", with: "\(episodeID)")
		let request: APIRequest<EpisodeUpdateResponse, KKAPIError> = tron.codable.request(animeEpisodesWatched)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.perform(withSuccess: { episodeUpdateResponse in
			completionHandler(.success(episodeUpdateResponse.data.watchStatus))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't update episode 😔", subTitle: error.message)
			}
			print("❌ Received mark episode error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
