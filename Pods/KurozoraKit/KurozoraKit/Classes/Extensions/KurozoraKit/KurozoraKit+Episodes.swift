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
		let episodesDetails = KKEndpoint.Shows.Episodes.details(episodeIdentity).endpointValue
		let request: APIRequest<EpisodeResponse, KKAPIError> = tron.codable.request(episodesDetails)
			.method(.get)
			.parameters(parameters)
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
		let episodesWatched = KKEndpoint.Shows.Episodes.watched(episodeIdentity).endpointValue
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
		let showsEpisodesRate = KKEndpoint.Shows.Episodes.rate(episodeIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(showsEpisodesRate)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
