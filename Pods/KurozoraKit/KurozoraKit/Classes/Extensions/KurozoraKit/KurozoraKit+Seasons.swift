//
//  KurozoraKit+Season.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the season details for the given season identity.
	///
	/// - Parameters:
	///    - seasonIdentity: The season identity object for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get season details response.
	public func getDetails(forSeason seasonIdentity: SeasonIdentity, including relationships: [String] = []) -> RequestSender<SeasonResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		var parameters: [String: Any] = [:]
		if !relationships.isEmpty {
			parameters["include"] = relationships.joined(separator: ",")
		}

		// Prepare request
		let seasonsDetails = KKEndpoint.Shows.Seasons.details(seasonIdentity).endpointValue
		let request: APIRequest<SeasonResponse, KKAPIError> = tron.codable.request(seasonsDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the episodes for the given season identity.
	///
	/// - Parameters:
	///    - seasonIdentity: The season identity  object of the season for which the episodes should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - hideFillers: A boolean indicating whether fillers should be included in the request.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get season episodes response.
	public func getEpisodes(forSeason seasonIdentity: SeasonIdentity, next: String? = nil, limit: Int = 25, hideFillers: Bool = false) -> RequestSender<EpisodeIdentityResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit,
			"hide_fillers": hideFillers ? 1 : 0
		]

		// Prepare request
		let seasonsEpisodes = next ?? KKEndpoint.Shows.Seasons.episodes(seasonIdentity).endpointValue
		let request: APIRequest<EpisodeIdentityResponse, KKAPIError> = tron.codable.request(seasonsEpisodes).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Update an season's watch status.
	///
	///	- Parameter seasonIdentity: The season identity object of the season that should be marked as watched/unwatched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the update season watch status response.
	public func updateSeasonWatchStatus(_ seasonIdentity: SeasonIdentity) -> RequestSender<SeasonUpdateResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let seasonsWatched = KKEndpoint.Shows.Seasons.watched(seasonIdentity).endpointValue
		let request: APIRequest<SeasonUpdateResponse, KKAPIError> = tron.codable.request(seasonsWatched)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
