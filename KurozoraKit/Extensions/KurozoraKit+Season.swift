//
//  KurozoraKit+Season.swift
//  Kurozora
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
		- Parameter successHandler: A closure returning an Episodes object.
		- Parameter episodes: The returned Episodes object.
	*/
	func getEpisodes(forSeasonID seasonID: Int, withSuccess successHandler: @escaping (_ episodes: Episodes?) -> Void) {
		let animeSeasonsEpisodes = self.kurozoraKitEndpoints.animeSeasonsEpisodes.replacingOccurrences(of: "?", with: "\(seasonID)")
		let request: APIRequest<Episodes, JSONError> = tron.swiftyJSON.request(animeSeasonsEpisodes)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .get
		request.perform(withSuccess: { episodes in
			if let success = episodes.success {
				if success {
					successHandler(episodes)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get episodes list 😔", subTitle: error.message)
			print("Received get show episodes error: \(error.message ?? "No message available")")
		})
	}
}
