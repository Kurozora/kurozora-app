//
//  KurozoraKit+FavoriteShow.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import TRON

extension KurozoraKit {
	/**
		Fetch the favorite shows list for the authenticated user.

		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFavoriteShows(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowResponse, KKAPIError>) -> Void) {
		let meFavoriteShowIndex = next ?? KKEndpoint.Me.FavoriteShow.index.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(meFavoriteShowIndex).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Favorites 😔", message: error.message)
			}
			print("❌ Received get favorites error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Update the `FavoriteStatus` value of a show in the authenticated user's library.

		- Parameter showID: The id of the show whose favorite status should be updated.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateFavoriteShowStatus(_ showID: Int, completion completionHandler: @escaping (_ result: Result<FavoriteStatus, KKAPIError>) -> Void) {
		let meFavoriteShowUpdate = KKEndpoint.Me.FavoriteShow.update.endpointValue
		let request: APIRequest<FavoriteShowResponse, KKAPIError> = tron.codable.request(meFavoriteShowUpdate)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .post
		request.parameters = [
			"anime_id": showID,
		]
		request.perform(withSuccess: { favoriteShowResponse in
			completionHandler(.success(favoriteShowResponse.data.favoriteStatus))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Update Favorite Status 😔", message: error.message)
			}
			print("❌ Received update favorite status error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
