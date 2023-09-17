//
//  KurozoraKit+Genre.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of genres.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get genres response.
	public func getGenres() -> RequestSender<GenreResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let genresIndex = KKEndpoint.Genres.index.endpointValue
		let request: APIRequest<GenreResponse, KKAPIError> = tron.codable.request(genresIndex)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the genre details for the given genre identity.
	///
	/// - Parameters:
	///    - genreIdentity: The genre identity object of the genre for which the details should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get genre detaisl response.
	public func getDetails(forGenre genreIdentity: GenreIdentity) -> RequestSender<GenreResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let genresDetails = KKEndpoint.Genres.details(genreIdentity).endpointValue
		let request: APIRequest<GenreResponse, KKAPIError> = tron.codable.request(genresDetails)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
