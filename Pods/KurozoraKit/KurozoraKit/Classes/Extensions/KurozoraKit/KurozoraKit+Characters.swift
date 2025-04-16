//
//  KurozoraKit+Characters.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/06/2020.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the characters index.
	///
	/// - Parameters:
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 5 and the maximum value is 25.
	///    - filter: The filters to apply on the index list.
	///
	/// - Returns: An instance of `RequestSender` with the results of the characters index response.
	public func charactersIndex(next: String? = nil, limit: Int = 5, filter: CharacterFilter?) -> RequestSender<CharacterIdentityResponse, KKAPIError> {
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
		let searchIndex = next ?? KKEndpoint.Characters.index.endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(searchIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the character details for the given character identity.
	///
	/// - Parameters:
	///    - characterIdentity: The character identity object of the character for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get character details response.
	public func getDetails(forCharacter characterIdentity: CharacterIdentity, including relationships: [String] = []) -> RequestSender<CharacterResponse, KKAPIError> {
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
		let charactersDetails = KKEndpoint.Characters.details(characterIdentity).endpointValue
		let request: APIRequest<CharacterResponse, KKAPIError> = tron.codable.request(charactersDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the people for the given character identity.
	///
	/// - Parameters:
	///    - characterIdentity: The character identity object for which the people should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get people response.
	public func getPeople(forCharacter characterIdentity: CharacterIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<PersonIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let charactersPeople = next ?? KKEndpoint.Characters.people(characterIdentity).endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(charactersPeople).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	/// Fetch the shows for the given character identity.
	///
	/// - Parameters:
	///    - characterIdentity: The character identity object for which the shows should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get shows response.
	public func getShows(forCharacter characterIdentity: CharacterIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ShowIdentityResponse, KKAPIError> {
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
		let charactersShows = next ?? KKEndpoint.Characters.shows(characterIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(charactersShows).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the literatures for the given character identity.
	///
	/// - Parameters:
	///    - characterIdentity: The character identity object for which the literatures should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get literatures response.
	public func getLiteratures(forCharacter characterIdentity: CharacterIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<LiteratureIdentityResponse, KKAPIError> {
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
		let charactersLiteratures = next ?? KKEndpoint.Characters.literatures(characterIdentity).endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(charactersLiteratures).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the games for the given character identity.
	///
	/// - Parameters:
	///    - characterIdentity: The character identity object for which the games should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get games response.
	public func getGames(forCharacter characterIdentity: CharacterIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<GameIdentityResponse, KKAPIError> {
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
		let charactersGames = next ?? KKEndpoint.Characters.games(characterIdentity).endpointValue
		let request: APIRequest<GameIdentityResponse, KKAPIError> = tron.codable.request(charactersGames).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the reviews for a the given character identity.
	///
	///	- Parameters:
	///	   - characterIdentity: The character identity object for which the reviews should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get reviews response.
	public func getReviews(forCharacter characterIdentity: CharacterIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ReviewResponse, KKAPIError> {
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
		let charactersReviews = next ?? KKEndpoint.Characters.reviews(characterIdentity).endpointValue
		let request: APIRequest<ReviewResponse, KKAPIError> = tron.codable.request(charactersReviews).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Rate the character with the given character identity.
	///
	/// - Parameters:
	///    - characterIdentity: The id of the character which should be rated.
	///	   - score: The rating to leave.
	///	   - description: The description of the rating.
	///
	/// - Returns: An instance of `RequestSender` with the results of the rate character response.
	public func rateCharacter(_ characterIdentity: CharacterIdentity, with score: Double, description: String?) -> RequestSender<KKSuccess, KKAPIError> {
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
		let charactersRate = KKEndpoint.Characters.rate(characterIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(charactersRate).buildURL(.relativeToBaseURL)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Delete the authenticated user's rating of the specified character.
	///
	/// - Parameters:
	///    - characterIdentity: The id of the character whose rating should be deleted.
	///
	/// - Returns: An instance of `RequestSender` with the results of the delete rating response.
	public func deleteRating(_ characterIdentity: CharacterIdentity) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let charactersDelete = KKEndpoint.Characters.deleteRating(characterIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(charactersDelete).buildURL(.relativeToBaseURL)
			.method(.delete)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
