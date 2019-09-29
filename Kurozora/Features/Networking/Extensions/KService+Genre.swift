//
//  KService+Genre.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KService {
	/**
		Fetch the list of genres.

		- Parameter successHandler: A closure returning a GenreElement array.
		- Parameter genres: The returned GenreElement array.
	*/
	func getGenres(withSuccess successHandler: @escaping (_ genres: [GenreElement]?) -> Void) {
		let request: APIRequest<Genres, JSONError> = tron.swiftyJSON.request("genres")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { genres in
			if let success = genres.success {
				if success {
					successHandler(genres.genres)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get genres list 😔", subTitle: error.message)
			print("Received get genres error: \(error)")
		})
	}
}
