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
		- Parameter successHandler: A closure returning a `WatchStatus` value indicating the episode's watch status.
		- Parameter isSuccess: A `WatchStatus` value indicating the episode's watch status.
	*/
	public func updateEpisodeWatchStatus(_ episodeID: Int, withWatchStatus watchStatus: WatchStatus, withSuccess successHandler: @escaping (_ watchStatus: WatchStatus) -> Void) {
		let animeEpisodesWatched = self.kurozoraKitEndpoints.animeEpisodesWatched.replacingOccurrences(of: "?", with: "\(episodeID)")
		let request: APIRequest<EpisodesUserDetails, JSONError> = tron.swiftyJSON.request(animeEpisodesWatched)

		request.headers = headers
		request.headers["kuro-auth"] = self._userAuthToken

		request.method = .post
		request.parameters = [
			"watched": watchStatus.rawValue
		]
		request.perform(withSuccess: { episode in
			if let watchedStatus = episode.watched {
				successHandler(watchedStatus ? .watched : .notWatched)
			}
		}, failure: { error in
			SCLAlertView().showError("Can't update episode 😔", subTitle: error.message)
			print("Received mark episode error: \(error.message ?? "No message available")")
		})
	}
}
