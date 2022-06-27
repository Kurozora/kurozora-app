//
//  KurozoraKit+Season.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON
import Alamofire

extension KurozoraKit {
	/// Fetch the season details for the given season identity.
	///
	/// - Parameters:
	///    - seasonIdentity: The season identity object for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forSeason seasonIdentity: SeasonIdentity, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Season], KKAPIError>) -> Void) -> DataRequest {
		let seasonsDetails = KKEndpoint.Shows.Seasons.details(seasonIdentity).endpointValue
		let request: APIRequest<SeasonResponse, KKAPIError> = tron.codable.request(seasonsDetails)

		request.headers = headers

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform(withSuccess: { seasonResponse in
			completionHandler(.success(seasonResponse.data))
		}, failure: { error in
			print("❌ Received get season details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the episodes for the given season identity.
	///
	/// - Parameters:
	///    - seasonIdentity: The season identity  object of the season for which the episodes should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - hideFillers: A boolean indicating whether fillers should be included in the request.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getEpisodes(forSeasonID seasonIdentity: SeasonIdentity, next: String? = nil, limit: Int = 25, hideFillers: Bool = false, completion completionHandler: @escaping (_ result: Result<EpisodeIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let seasonsEpisodes = next ?? KKEndpoint.Shows.Seasons.episodes(seasonIdentity).endpointValue
		let request: APIRequest<EpisodeIdentityResponse, KKAPIError> = tron.codable.request(seasonsEpisodes).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit
		request.parameters["hide_fillers"] = hideFillers ? 1 : 0

		request.method = .get
		return request.perform(withSuccess: { episodeIdentityResponse in
			completionHandler(.success(episodeIdentityResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Episodes List 😔", message: error.message)
			}
			print("❌ Received get show episodes error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
