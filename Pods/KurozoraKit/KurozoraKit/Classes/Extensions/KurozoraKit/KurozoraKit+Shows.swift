//
//  KurozoraKit+Show.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the shows index.
	///
	/// - Parameters:
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 5 and the maximum value is 25.
	///    - filter: The filters to apply on the index list.
	///
	/// - Returns: An instance of `RequestSender` with the results of the shows index response.
	public func showsIndex(next: String? = nil, limit: Int = 5, filter: ShowFilter?) -> RequestSender<ShowIdentityResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		var parameters: [String: Any] = [:]
		if next == nil {
			parameters = [
				"limit": limit
			]

			if let filter = filter {
				let filters: [String: Any] = filter.toFilterArray().compactMapValues { value in
					return value
				}

				do {
					let filterData = try JSONSerialization.data(withJSONObject: filters, options: [])
					parameters["filter"] = filterData.base64EncodedString()
				} catch {
					print("❌ Encode error: Could not make base64 string from filter data", filters)
				}
			}
		}

		// Prepare request
		let searchIndex = next ?? KKEndpoint.Shows.index([]).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(searchIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the show details for the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The identity of the show for which the details should be fetched.
	///	   - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get show detail response.
	public func getDetails(forShow showIdentity: ShowIdentity, including relationships: [String] = []) -> RequestSender<ShowResponse, KKAPIError> {
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
		let showsDetails = KKEndpoint.Shows.details(showIdentity).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(showsDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the show details for the given show identities.
	///
	///	- Parameters:
	///	   - showIdentities: The identity of the show for which the details should be fetched.
	///	   - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get show detail response.
	public func getDetails(forShows showIdentities: [ShowIdentity], including relationships: [String] = []) -> RequestSender<ShowResponse, KKAPIError> {
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
		let showsDetails = KKEndpoint.Shows.index(showIdentities).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(showsDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the person details for the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the person details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get people response.
	public func getPeople(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<PersonIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let showsPeople = next ?? KKEndpoint.Shows.people(showIdentity).endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(showsPeople).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the cast details for the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the cast details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get cast response.
	public func getCast(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<CastIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let showsCast = next ?? KKEndpoint.Shows.cast(showIdentity).endpointValue
		let request: APIRequest<CastIdentityResponse, KKAPIError> = tron.codable.request(showsCast).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the character details for the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the character details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get charaters response.
	public func getCharacters(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<CharacterIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let showsCharacters = next ?? KKEndpoint.Shows.characters(showIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(showsCharacters).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the related shows for a the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the related shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get related shows response.
	public func getRelatedShows(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<RelatedShowResponse, KKAPIError> {
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
		let showsRelatedShows = next ?? KKEndpoint.Shows.relatedShows(showIdentity).endpointValue
		let request: APIRequest<RelatedShowResponse, KKAPIError> = tron.codable.request(showsRelatedShows).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the related literatures for a the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the related literatures should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get related literatures response.
	public func getRelatedLiteratures(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<RelatedLiteratureResponse, KKAPIError> {
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
		let showsRelatedLiteratures = next ?? KKEndpoint.Shows.relatedLiteratures(showIdentity).endpointValue
		let request: APIRequest<RelatedLiteratureResponse, KKAPIError> = tron.codable.request(showsRelatedLiteratures).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the related games for a the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the related games should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get related games response.
	public func getRelatedGames(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<RelatedGameResponse, KKAPIError> {
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
		let showsRelatedGames = next ?? KKEndpoint.Shows.relatedGames(showIdentity).endpointValue
		let request: APIRequest<RelatedGameResponse, KKAPIError> = tron.codable.request(showsRelatedGames).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the reviews for a the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the reviews should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get reviews response.
	public func getReviews(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ReviewResponse, KKAPIError> {
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
		let showsReviews = next ?? KKEndpoint.Shows.reviews(showIdentity).endpointValue
		let request: APIRequest<ReviewResponse, KKAPIError> = tron.codable.request(showsReviews).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the seasons for a the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the seasons should be fetched.
	///	   - reversed: Whethert the list is reversed in order. Default is `false`.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get seasons response.
	public func getSeasons(forShow showIdentity: ShowIdentity, reversed: Bool = false, next: String? = nil, limit: Int = 25) -> RequestSender<SeasonIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit,
			"reversed": reversed
		]

		// Prepare request
		let showsSeasons = next ?? KKEndpoint.Shows.seasons(showIdentity).endpointValue
		let request: APIRequest<SeasonIdentityResponse, KKAPIError> = tron.codable.request(showsSeasons).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	/// Fetch the songs for a the given show identity.
	///
	///	- Parameters:
	///	   - showIdentity: The show identity object for which the songs should be fetched.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get songs response.
	public func getSongs(forShow showIdentity: ShowIdentity, limit: Int = 25) -> RequestSender<ShowSongResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let showsSongs = KKEndpoint.Shows.songs(showIdentity).endpointValue
		let request: APIRequest<ShowSongResponse, KKAPIError> = tron.codable.request(showsSongs).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the studios for a the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the studios should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get studios response.
	public func getStudios(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<StudioIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let showsSeasons = next ?? KKEndpoint.Shows.studios(showIdentity).endpointValue
		let request: APIRequest<StudioIdentityResponse, KKAPIError> = tron.codable.request(showsSeasons).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the more by studio section for a the given show identity.
	///
	///	- Parameter showIdentity: The show identity object for which the studio shows should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get more by studio response.
	public func getMoreByStudio(forShow showIdentity: ShowIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ShowIdentityResponse, KKAPIError> {
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
		let showsSeasons = next ?? KKEndpoint.Shows.moreByStudio(showIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(showsSeasons).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Rate the show with the given show identity.
	///
	/// - Parameters:
	///    - showIdentity: The id of the show which should be rated.
	///	   - score: The rating to leave.
	///	   - description: The description of the rating.
	///
	/// - Returns: An instance of `RequestSender` with the results of the rate show response.
	public func rateShow(_ showIdentity: ShowIdentity, with score: Double, description: String?) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		var parameters: [String: Any] = [
			"rating": score
		]
		if let description = description {
			parameters["description"] = description
		}

		// Prepare request
		let showsRate = KKEndpoint.Shows.rate(showIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(showsRate).buildURL(.relativeToBaseURL)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the cast details for the given show identity.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get upcoming shows response.
	public func getUpcomingShows(next: String? = nil, limit: Int = 25) -> RequestSender<ShowIdentityResponse, KKAPIError> {
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
		let upcomingShows = next ?? KKEndpoint.Shows.upcoming.endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(upcomingShows).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
