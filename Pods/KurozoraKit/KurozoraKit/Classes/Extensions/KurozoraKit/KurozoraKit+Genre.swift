//
//  KurozoraKit+Genre.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the list of genres.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getGenres(completion completionHandler: @escaping (_ result: Result<[GenreElement], KKError>) -> Void) {
		let genres = self.kurozoraKitEndpoints.genres
		let request: APIRequest<Genres, KKError> = tron.swiftyJSON.request(genres)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { genres in
			completionHandler(.success(genres.genres ?? []))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get genres list 😔", subTitle: error.message)
			}
			print("Received get genres error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
