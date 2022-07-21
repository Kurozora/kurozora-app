//
//  KurozoraKit+Show.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import Alamofire
import TRON

extension KurozoraKit {
	///	Fetch the show details for the given show identity.
	///
	///	- Parameter showID: The id of the show for which the details should be fetched.
	///	- Parameter relationships: The relationships to include in the response.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forShow showIdentity: ShowIdentity, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Show], KKAPIError>) -> Void) -> DataRequest {
		let showsDetails = KKEndpoint.Shows.details(showIdentity).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(showsDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse.data))
		}, failure: { error in
			print("❌ Received get show details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	///	Fetch the person details for the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the person details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getPeople(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> DataTask<PersonIdentityResponse> {
		let showsPeople = next ?? KKEndpoint.Shows.people(showIdentity).endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(showsPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(PersonIdentityResponse.self)
	}

	///	Fetch the cast details for the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the cast details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getCast(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> DataTask<CastIdentityResponse> {
		let showsCast = next ?? KKEndpoint.Shows.cast(showIdentity).endpointValue
		let request: APIRequest<CastIdentityResponse, KKAPIError> = tron.codable.request(showsCast).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(CastIdentityResponse.self)
	}

	///	Fetch the character details for the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the character details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getCharacters(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> DataTask<CharacterIdentityResponse> {
		let showsCharacters = next ?? KKEndpoint.Shows.characters(showIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(showsCharacters).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(CharacterIdentityResponse.self)
	}

	///	Fetch the related shows for a the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the related shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getRelatedShows(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> DataTask<RelatedShowResponse> {
		let showsRelatedShows = next ?? KKEndpoint.Shows.relatedShows(showIdentity).endpointValue
		let request: APIRequest<RelatedShowResponse, KKAPIError> = tron.codable.request(showsRelatedShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(RelatedShowResponse.self)
	}

	///	Fetch the seasons for a the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the seasons should be fetched.
	///	   - reversed: Whethert the list is reversed in order. Default is `false`.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getSeasons(forShow showIdentity: ShowIdentity, reversed: Bool = false, next: String? = nil, limit: Int = 25) -> DataTask<SeasonIdentityResponse> {
		let showsSeasons = next ?? KKEndpoint.Shows.seasons(showIdentity).endpointValue
		let request: APIRequest<SeasonIdentityResponse, KKAPIError> = tron.codable.request(showsSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit
		request.parameters["reversed"] = reversed

		request.method = .get
		return request.perform().serializingDecodable(SeasonIdentityResponse.self)
	}

	/// Fetch the songs for a the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the songs should be fetched.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getSongs(forShow showIdentity: ShowIdentity, limit: Int = 25) -> DataTask<ShowSongResponse> {
		let showsSongs = KKEndpoint.Shows.songs(showIdentity).endpointValue
		let request: APIRequest<ShowSongResponse, KKAPIError> = tron.codable.request(showsSongs).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(ShowSongResponse.self)
	}

	///	Fetch the studios for a the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the studios should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getStudios(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> DataTask<StudioIdentityResponse> {
		let showsSeasons = next ?? KKEndpoint.Shows.studios(showIdentity).endpointValue
		let request: APIRequest<StudioIdentityResponse, KKAPIError> = tron.codable.request(showsSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(StudioIdentityResponse.self)
	}

	///	Fetch the more by studio section for a the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the studio shows should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getMoreByStudio(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> DataTask<ShowIdentityResponse> {
		let showsSeasons = next ?? KKEndpoint.Shows.moreByStudio(showIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(showsSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(ShowIdentityResponse.self)
	}

	/// Rate the show with the given show identity.
	///
	/// - Parameter showID: The id of the show which should be rated.
	///	- Parameter score: The rating to leave.
	///	- Parameter description: The description of the rating.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func rateShow(_ showIdentity: ShowIdentity, with score: Double, description: String?, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) -> DataRequest {
		let showsRate = KKEndpoint.Shows.rate(showIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(showsRate).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .post
		request.parameters = [
			"rating": score
		]
		if let description = description {
			request.parameters["description"] = description
		}

		return request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Rate Show 😔", message: error.message)
			}
			print("❌ Received show rating error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the cast details for the given show identity.
	///
	/// - Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	/// - Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	/// - Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getUpcomingShows(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let upcomingShows = next ?? KKEndpoint.Shows.upcoming.endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(upcomingShows).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { showIdentityResponse in
			completionHandler(.success(showIdentityResponse))
		}, failure: { error in
			print("❌ Received get upcoming shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
