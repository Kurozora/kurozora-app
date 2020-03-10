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
		Watch or unwatch an episode with the given episode id.

		- Parameter watched: The integer indicating whether to mark the episode as watched or not watched. (0 = not watched, 1 = watched)
		- Parameter episodeID: The id of the episode that should be marked as watched/unwatched.
		- Parameter successHandler: A closure returning a boolean indicating whether watch/unwatch is successful.
		- Parameter isSuccess: A boolean value indicating whether watch/unwatch is successful.
	*/
	func mark(asWatched watched: Int, forEpisode episodeID: Int, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let animeEpisodesWatched = self.kurozoraEndpoints.animeEpisodesWatched.replacingOccurrences(of: "?", with: "\(episodeID)")
		let request: APIRequest<EpisodesUserDetails, JSONError> = tron.swiftyJSON.request(animeEpisodesWatched)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .post
		request.parameters = [
			"watched": watched
		]
		request.perform(withSuccess: { episode in
			if let watchedStatus = episode.watched {
				successHandler(watchedStatus)
			}
		}, failure: { error in
			SCLAlertView().showError("Can't update episode 😔", subTitle: error.message)
			print("Received mark episode error: \(error.message ?? "No message available")")
		})
	}
}
