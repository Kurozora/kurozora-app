//
//  KurozoraKit+Episode.swift
//  Kurozora
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
		- Parameter watchStatus: The new watch status by which the episode's current watch status is updated.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateEpisodeWatchStatus(_ episodeID: Int, withWatchStatus watchStatus: WatchStatus, completion completionHandler: @escaping (_ result: Result<WatchStatus, KKError>) -> Void) {
		let animeEpisodesWatched = self.kurozoraKitEndpoints.animeEpisodesWatched.replacingOccurrences(of: "?", with: "\(episodeID)")
		let request: APIRequest<EpisodesUserDetails, KKError> = tron.swiftyJSON.request(animeEpisodesWatched)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.parameters = [
			"watched": watchStatus.rawValue
		]
		request.perform(withSuccess: { episode in
			let watchedStatus = episode.watched ?? false
			completionHandler(.success(watchedStatus ? .watched : .notWatched))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't update episode 😔", subTitle: error.message)
			}
			print("Received mark episode error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
