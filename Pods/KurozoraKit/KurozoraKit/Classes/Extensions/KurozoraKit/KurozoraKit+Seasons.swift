//
//  KurozoraKit+Season.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the season details for the given season identity.
	///
	/// - Parameters:
	///    - seasonIdentity: The season identity object for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getDetails(forSeason seasonIdentity: SeasonIdentity, including relationships: [String] = []) -> DataTask<SeasonResponse> {
		let seasonsDetails = KKEndpoint.Shows.Seasons.details(seasonIdentity).endpointValue
		let request: APIRequest<SeasonResponse, KKAPIError> = tron.codable.request(seasonsDetails)

		request.headers = headers

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform().serializingDecodable(SeasonResponse.self)
	}

	/// Fetch the episodes for the given season identity.
	///
	/// - Parameters:
	///    - seasonIdentity: The season identity  object of the season for which the episodes should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - hideFillers: A boolean indicating whether fillers should be included in the request.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getEpisodes(forSeason seasonIdentity: SeasonIdentity, next: String? = nil, limit: Int = 25, hideFillers: Bool = false) -> DataTask<EpisodeIdentityResponse> {
		let seasonsEpisodes = next ?? KKEndpoint.Shows.Seasons.episodes(seasonIdentity).endpointValue
		let request: APIRequest<EpisodeIdentityResponse, KKAPIError> = tron.codable.request(seasonsEpisodes).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit
		request.parameters["hide_fillers"] = hideFillers ? 1 : 0

		request.method = .get
		return request.perform().serializingDecodable(EpisodeIdentityResponse.self)
	}
}
