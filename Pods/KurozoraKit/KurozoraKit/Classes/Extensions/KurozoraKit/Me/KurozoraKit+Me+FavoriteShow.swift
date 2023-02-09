//
//  KurozoraKit+Favorite.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import TRON

extension KurozoraKit {
	/// Fetch the favorites list for the authenticated user.
	///
	/// - Parameters:
	///    - libraryKind: From which library to get the favorites.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getFavorites(from libraryKind: KKLibrary.Kind, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowResponse, KKAPIError>) -> Void) {
		let meFavoritesIndex = next ?? KKEndpoint.Me.Favorites.index.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(meFavoritesIndex).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.parameters = [
			"library": libraryKind.rawValue,
			"limit": limit
		]

		request.method = .get
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Favorites 😔", message: error.message)
			}
			print("❌ Received get favorites error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Update the `FavoriteStatus` value of a model in the authenticated user's library.
	///
	/// - Parameters:
	///    - libraryKind: From which library to get the favorites.
	///    - modelID: The id of the model whose favorite status should be updated.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func updateFavoriteStatus(inLibrary libraryKind: KKLibrary.Kind, modelID: String, completion completionHandler: @escaping (_ result: Result<FavoriteStatus, KKAPIError>) -> Void) {
		let meFavoritesUpdate = KKEndpoint.Me.Favorites.update.endpointValue
		let request: APIRequest<FavoriteResponse, KKAPIError> = tron.codable.request(meFavoritesUpdate)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.parameters = [
			"library": libraryKind.rawValue,
			"model_id": modelID,
		]
		request.perform(withSuccess: { favoriteResponse in
			completionHandler(.success(favoriteResponse.data.favoriteStatus))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Update Favorite Status 😔", message: error.message)
			}
			print("❌ Received update favorite status error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
