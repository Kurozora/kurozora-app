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
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getEpisodes(forSeasonID seasonID: Int, completion completionHandler: @escaping (_ result: Result<Episodes, KKError>) -> Void) {
		let animeSeasonsEpisodes = self.kurozoraKitEndpoints.animeSeasonsEpisodes.replacingOccurrences(of: "?", with: "\(seasonID)")
		let request: APIRequest<Episodes, KKError> = tron.swiftyJSON.request(animeSeasonsEpisodes)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { episodes in
			completionHandler(.success(episodes))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get episodes list 😔", subTitle: error.message)
			}
			print("Received get show episodes error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
