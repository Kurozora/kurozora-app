//
//  KurozoraKit+Episode.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the episode details for the given episode identity.
	///
	/// - Parameter episodeIdentity: The episode identity object of the episode for which the details should be fetched.
	/// - Parameter relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getDetails(forEpisode episodeIdentity: EpisodeIdentity, including relationships: [String] = []) -> DataTask<EpisodeResponse> {
		let episodesDetails = KKEndpoint.Shows.Episodes.details(episodeIdentity).endpointValue
		let request: APIRequest<EpisodeResponse, KKAPIError> = tron.codable.request(episodesDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform().serializingDecodable(EpisodeResponse.self)
	}

	/// Update an episode's watch status.
	///
	///	- Parameter episodeIdentity: The episode identity object of the episode that should be marked as watched/unwatched.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func updateEpisodeWatchStatus(_ episodeIdentity: EpisodeIdentity) -> DataTask<WatchStatus> {
		let episodesWatched = KKEndpoint.Shows.Episodes.watched(episodeIdentity).endpointValue
		let request: APIRequest<EpisodeUpdateResponse, KKAPIError> = tron.codable.request(episodesWatched)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .post
		return request.perform().serializingDecodable(WatchStatus.self)
	}

	/// Rate the episode with the given episode identity.
	///
	/// - Parameter episodeIdentity: The episode identity object of the episode which should be rated.
	/// - Parameter score: The rating to leave.
	///	- Parameter description: The description of the rating.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func rateEpisode(_ episodeIdentity: EpisodeIdentity, with score: Double, description: String?) -> DataTask<KKSuccess> {
		let showsEpisodesRate = KKEndpoint.Shows.Episodes.rate(episodeIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(showsEpisodesRate)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters = [
			"rating": score
		]
		if let description = description {
			request.parameters["description"] = description
		}

		request.method = .post
		return request.perform().serializingDecodable(KKSuccess.self)
	}
}
