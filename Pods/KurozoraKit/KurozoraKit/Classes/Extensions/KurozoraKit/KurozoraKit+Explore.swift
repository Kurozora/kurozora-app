//
//  KurozoraKit+Explore.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 16/08/2020.
//

import TRON

extension KurozoraKit {
	/**
		Fetch the explore page content. Explore page can be filtered by a specific genre by passing the genre id.

		Leaving the `genreID` empty or passing `nil` will return the global explore page which contains hand picked and staff curated shows.

		- Parameter genreID: The id of a genre by which the explore page should be filtered.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getExplore(_ genreID: Int? = nil, completion completionHandler: @escaping (_ result: Result<[ExploreCategory], KKAPIError>) -> Void) {
		let exploreIndex = KKEndpoint.Explore.index.endpointValue
		let request: APIRequest<ExploreCategoryResponse, KKAPIError> = tron.codable.request(exploreIndex)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if genreID != nil || genreID != 0 {
			if let genreID = genreID {
				request.parameters = [
					"genre_id": String(genreID)
				]
			}
		}

		request.method = .get
		request.perform(withSuccess: { exploreCategoryResponse in
			completionHandler(.success(exploreCategoryResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Explore Page 😔", message: error.message)
			}
			print("❌ Received explore error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
