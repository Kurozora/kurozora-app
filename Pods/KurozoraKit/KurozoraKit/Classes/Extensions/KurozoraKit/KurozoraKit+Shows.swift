//
//  KurozoraKit+Show.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
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
	///	- Parameter showIdentity: The show identity object for which the person details should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getPeople(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<PersonIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let showsPeople = next ?? KKEndpoint.Shows.people(showIdentity).endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(showsPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { personIdentityResponse in
			completionHandler(.success(personIdentityResponse))
		}, failure: { error in
			print("❌ Received get show people error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	///	Fetch the cast details for the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the cast details should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getCast(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<CastIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let showsCast = next ?? KKEndpoint.Shows.cast(showIdentity).endpointValue
		let request: APIRequest<CastIdentityResponse, KKAPIError> = tron.codable.request(showsCast).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { castIdentityResponse in
			completionHandler(.success(castIdentityResponse))
		}, failure: { error in
			print("❌ Received get show cast error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	///	Fetch the character details for the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the character details should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getCharacters(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<CharacterIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let showsCharacters = next ?? KKEndpoint.Shows.characters(showIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(showsCharacters).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { characterIdentityResponse in
			completionHandler(.success(characterIdentityResponse))
		}, failure: { error in
			print("❌ Received get show characters error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	///	Fetch the related shows for a the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the related shows should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getRelatedShows(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<RelatedShowResponse, KKAPIError>) -> Void) -> DataRequest {
		let showsRelatedShows = next ?? KKEndpoint.Shows.relatedShows(showIdentity).endpointValue
		let request: APIRequest<RelatedShowResponse, KKAPIError> = tron.codable.request(showsRelatedShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { relatedShowResponse in
			completionHandler(.success(relatedShowResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Related Shows 😔", message: error.message)
			}
			print("❌ Received get related shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	///	Fetch the seasons for a the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the seasons should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getSeasons(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<SeasonIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let showsSeasons = next ?? KKEndpoint.Shows.seasons(showIdentity).endpointValue
		let request: APIRequest<SeasonIdentityResponse, KKAPIError> = tron.codable.request(showsSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { seasonIdentityResponse in
			completionHandler(.success(seasonIdentityResponse))
		}, failure: { error in
			print("❌ Received get show seasons error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the songs for a the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the songs should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getSongs(forShow showIdentity: ShowIdentity, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowSongResponse, KKAPIError>) -> Void) -> DataRequest {
		let showsSongs = KKEndpoint.Shows.songs(showIdentity).endpointValue
		let request: APIRequest<ShowSongResponse, KKAPIError> = tron.codable.request(showsSongs).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { showSongResponse in
			completionHandler(.success(showSongResponse))
		}, failure: { error in
			print("❌ Received get show songs error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	///	Fetch the studios for a the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the studios should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getStudios(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<StudioIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let showsSeasons = next ?? KKEndpoint.Shows.studios(showIdentity).endpointValue
		let request: APIRequest<StudioIdentityResponse, KKAPIError> = tron.codable.request(showsSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { studioIdentityResponse in
			completionHandler(.success(studioIdentityResponse))
		}, failure: { error in
			print("❌ Received get show seasons error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
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

	/// Fetch a list of shows matching the search query.
	///
	/// - Parameter show: The search query by which the search list should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func search(forShow show: String, next: String? = nil, completion completionHandler: @escaping (_ result: Result<ShowResponse, KKAPIError>) -> Void) -> DataRequest {
		let showsSearch = next ?? KKEndpoint.Shows.search.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(showsSearch).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		if next == nil {
			request.parameters = [
				"query": show
			]
		}
		return request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse))
		}, failure: { error in
			print("❌ Received show search error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
