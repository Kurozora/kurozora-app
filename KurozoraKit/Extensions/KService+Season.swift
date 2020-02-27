//
//  KService+Season.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KService {
	/**
		Fetch the episodes for the given season id.

		- Parameter seasonID: The id of the season for which the episodes should be fetched.
		- Parameter successHandler: A closure returning an Episodes object.
		- Parameter episodes: The returned Episodes object.
	*/
	func getEpisodes(forSeasonID seasonID: Int?, withSuccess successHandler: @escaping (_ episodes: Episodes?) -> Void) {
		guard let seasonID = seasonID else { return }

		let request: APIRequest<Episodes, JSONError> = tron.swiftyJSON.request("anime-seasons/\(seasonID)/episodes")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
//			"kuro-auth": User.authToken
		]
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
