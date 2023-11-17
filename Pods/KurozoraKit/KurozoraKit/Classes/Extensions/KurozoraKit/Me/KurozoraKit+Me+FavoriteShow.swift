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
	///
	/// - Returns: An instance of `RequestSender` with the results of the get favorites response.
	public func getFavorites(from libraryKind: KKLibrary.Kind, next: String? = nil, limit: Int = 25) -> RequestSender<FavoriteLibraryResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"limit": limit
		]

		// Prepare request
		let meFavoritesIndex = next ?? KKEndpoint.Me.Favorites.index.endpointValue
		let request: APIRequest<FavoriteLibraryResponse, KKAPIError> = tron.codable.request(meFavoritesIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Update the `FavoriteStatus` value of a model in the authenticated user's library.
	///
	/// - Parameters:
	///    - libraryKind: To which library the model belongs.
	///    - modelID: The id of the model whose favorite status should be updated.
	///
	/// - Returns: An instance of `RequestSender` with the results of the update favorite status response.
	public func updateFavoriteStatus(inLibrary libraryKind: KKLibrary.Kind, modelID: String) -> RequestSender<FavoriteResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"model_id": modelID,
		]

		// Prepare request
		let meFavoritesUpdate = KKEndpoint.Me.Favorites.update.endpointValue
		let request: APIRequest<FavoriteResponse, KKAPIError> = tron.codable.request(meFavoritesUpdate)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
