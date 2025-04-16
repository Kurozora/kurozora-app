//
//  KurozoraKit+Episode.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the episode details for the given episode identity.
	///
	/// - Parameters:
	///    - episodeIdentity: The episode identity object of the episode for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get episode detail response.
	public func getDetails(forEpisode episodeIdentity: EpisodeIdentity, including relationships: [String] = []) -> RequestSender<EpisodeResponse, KKAPIError> {
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
		let episodesDetails = KKEndpoint.Episodes.details(episodeIdentity).endpointValue
		let request: APIRequest<EpisodeResponse, KKAPIError> = tron.codable.request(episodesDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the suggested episodes based on the given episode identity.
	///
	/// - Parameters:
	///    - episodeIdentity: The episode identity object of the episode for which the suggestions should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get suggestions response.
	public func getSuggestions(forEpisode episodeIdentity: EpisodeIdentity) -> RequestSender<EpisodeResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let episodesSuggestions = KKEndpoint.Episodes.suggestions(episodeIdentity).endpointValue
		let request: APIRequest<EpisodeResponse, KKAPIError> = tron.codable.request(episodesSuggestions)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Update an episode's watch status.
	///
	///	- Parameter episodeIdentity: The episode identity object of the episode that should be marked as watched/unwatched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the update episode watch status response.
	public func updateEpisodeWatchStatus(_ episodeIdentity: EpisodeIdentity) -> RequestSender<EpisodeUpdateResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let episodesWatched = KKEndpoint.Episodes.watched(episodeIdentity).endpointValue
		let request: APIRequest<EpisodeUpdateResponse, KKAPIError> = tron.codable.request(episodesWatched)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Rate the episode with the given episode identity.
	///
	/// - Parameters:
	///    - episodeIdentity: The episode identity object of the episode which should be rated.
	///    - score: The rating to leave.
	///	   - description: The description of the rating.
	///
	/// - Returns: An instance of `RequestSender` with the results of the rate episode response.
	public func rateEpisode(_ episodeIdentity: EpisodeIdentity, with score: Double, description: String?) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		var parameters: [String: Any] = [
			"rating": score
		]
		if let description = description {
			parameters["description"] = description
		}
		
		// Prepare request
		let episodesRate = KKEndpoint.Episodes.rate(episodeIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(episodesRate)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the reviews for a the given episode identity.
	///
	///	- Parameters:
	///	   - episodeIdentity: The episode identity object for which the reviews should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get reviews response.
	public func getReviews(forEpisode episodeIdentity: EpisodeIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ReviewResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let episodesReviews = next ?? KKEndpoint.Episodes.reviews(episodeIdentity).endpointValue
		let request: APIRequest<ReviewResponse, KKAPIError> = tron.codable.request(episodesReviews).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
