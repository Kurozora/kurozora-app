//
//  KurozoraKit+Literature.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/02/2023.
//

import TRON

extension KurozoraKit {
	/// Fetch the literatures index.
	///
	/// - Parameters:
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 5 and the maximum value is 25.
	///    - filter: The filters to apply on the index list.
	///
	/// - Returns: An instance of `RequestSender` with the results of the literatures index response.
	public func literaturesIndex(next: String? = nil, limit: Int = 5, filter: LiteratureFilter?) -> RequestSender<LiteratureIdentityResponse, KKAPIError> {
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
		let searchIndex = next ?? KKEndpoint.Literatures.index.endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(searchIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the literature details for the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The identity of the literature for which the details should be fetched.
	///	   - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get literature detail response.
	public func getDetails(forLiterature literatureIdentity: LiteratureIdentity, including relationships: [String] = []) -> RequestSender<LiteratureResponse, KKAPIError> {
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
		let literaturesDetails = KKEndpoint.Literatures.details(literatureIdentity).endpointValue
		let request: APIRequest<LiteratureResponse, KKAPIError> = tron.codable.request(literaturesDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the person details for the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the person details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get people response.
	public func getPeople(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<PersonIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let literaturesPeople = next ?? KKEndpoint.Literatures.people(literatureIdentity).endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(literaturesPeople).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the cast details for the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the cast details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get cast response.
	public func getCast(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<CastIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let literaturesCast = next ?? KKEndpoint.Literatures.cast(literatureIdentity).endpointValue
		let request: APIRequest<CastIdentityResponse, KKAPIError> = tron.codable.request(literaturesCast).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the character details for the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the character details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get characters response.
	public func getCharacters(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<CharacterIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let literaturesCharacters = next ?? KKEndpoint.Literatures.characters(literatureIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(literaturesCharacters).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the related literatures for a the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the related literatures should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get related literatures response.
	public func getRelatedLiteratures(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<RelatedLiteratureResponse, KKAPIError> {
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
		let literaturesRelatedLiteratures = next ?? KKEndpoint.Literatures.relatedLiteratures(literatureIdentity).endpointValue
		let request: APIRequest<RelatedLiteratureResponse, KKAPIError> = tron.codable.request(literaturesRelatedLiteratures).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the related shows for a the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the related shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get related shows response.
	public func getRelatedShows(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<RelatedShowResponse, KKAPIError> {
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
		let literaturesRelatedShows = next ?? KKEndpoint.Literatures.relatedShows(literatureIdentity).endpointValue
		let request: APIRequest<RelatedShowResponse, KKAPIError> = tron.codable.request(literaturesRelatedShows).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the related games for a the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the related games should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get related games response.
	public func getRelatedGames(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<RelatedGameResponse, KKAPIError> {
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
		let literaturesRelatedGames = next ?? KKEndpoint.Literatures.relatedGames(literatureIdentity).endpointValue
		let request: APIRequest<RelatedGameResponse, KKAPIError> = tron.codable.request(literaturesRelatedGames).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the reviews for a the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the reviews should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get reviews response.
	public func getReviews(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ReviewResponse, KKAPIError> {
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
		let literaturesReviews = next ?? KKEndpoint.Literatures.reviews(literatureIdentity).endpointValue
		let request: APIRequest<ReviewResponse, KKAPIError> = tron.codable.request(literaturesReviews).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
	///	Fetch the studios for a the given literature identity.
	///
	///	- Parameter literatureIdentity: The literature identity object for which the studios should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get studios response.
	public func getStudios(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<StudioIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let literaturesSeasons = next ?? KKEndpoint.Literatures.studios(literatureIdentity).endpointValue
		let request: APIRequest<StudioIdentityResponse, KKAPIError> = tron.codable.request(literaturesSeasons).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the more by studio section for a the given literature identity.
	///
	///	- Parameter literatureIdentity: The literature identity object for which the studio literatures should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get more by studio response.
	public func getMoreByStudio(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<LiteratureIdentityResponse, KKAPIError> {
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
		let literaturesSeasons = next ?? KKEndpoint.Literatures.moreByStudio(literatureIdentity).endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(literaturesSeasons).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Rate the literature with the given literature identity.
	///
	/// - Parameters:
	///    - literatureID: The id of the literature which should be rated.
	///	   - score: The rating to leave.
	///	   - description: The description of the rating.
	///
	/// - Returns: An instance of `RequestSender` with the results of the rate literature response.
	public func rateLiterature(_ literatureIdentity: LiteratureIdentity, with score: Double, description: String?) -> RequestSender<KKSuccess, KKAPIError> {
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
		let literaturesRate = KKEndpoint.Literatures.rate(literatureIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(literaturesRate).buildURL(.relativeToBaseURL)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the cast details for the given literature identity.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get upcoming literatures response.
	public func getUpcomingLiteratures(next: String? = nil, limit: Int = 25) -> RequestSender<LiteratureIdentityResponse, KKAPIError> {
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
		let upcomingLiteratures = next ?? KKEndpoint.Literatures.upcoming.endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(upcomingLiteratures).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
