//
//  KurozoraKit+People.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the peopel index.
	///
	/// - Parameters:
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 5 and the maximum value is 25.
	///    - filter: The filters to apply on the index list.
	///
	/// - Returns: An instance of `RequestSender` with the results of the peopel index response.
	public func peopelIndex(next: String? = nil, limit: Int = 5, filter: PersonFilter?) -> RequestSender<PersonIdentityResponse, KKAPIError> {
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
		let searchIndex = next ?? KKEndpoint.People.index.endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(searchIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the person details for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The persion identity object of the person for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get person details response.
	public func getDetails(forPerson personIdentity: PersonIdentity, including relationships: [String] = []) -> RequestSender<PersonResponse, KKAPIError> {
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
		let peopleDetails = KKEndpoint.People.details(personIdentity).endpointValue
		let request: APIRequest<PersonResponse, KKAPIError> = tron.codable.request(peopleDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the characters for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The person identity object for which the characters should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get characters response.
	public func getCharacters(forPerson personIdentity: PersonIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<CharacterIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let charactersPeople = next ?? KKEndpoint.People.characters(personIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(charactersPeople).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the shows for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The person identity object for which the shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get shows response.
	public func getShows(forPerson personIdentity: PersonIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ShowIdentityResponse, KKAPIError> {
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
		let peopleShows = next ?? KKEndpoint.People.shows(personIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(peopleShows).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the literatures for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The person identity object for which the literatures should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get literatures response.
	public func getLiteratures(forPerson personIdentity: PersonIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<LiteratureIdentityResponse, KKAPIError> {
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
		let peopleLiteratures = next ?? KKEndpoint.People.literatures(personIdentity).endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(peopleLiteratures).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the games for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The person identity object for which the games should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get games response.
	public func getGames(forPerson personIdentity: PersonIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<GameIdentityResponse, KKAPIError> {
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
		let peopleGames = next ?? KKEndpoint.People.games(personIdentity).endpointValue
		let request: APIRequest<GameIdentityResponse, KKAPIError> = tron.codable.request(peopleGames).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the reviews for a the given person identity.
	///
	///	- Parameters:
	///	   - personIdentity: The person identity object for which the reviews should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get reviews response.
	public func getReviews(forPerson personIdentity: PersonIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ReviewResponse, KKAPIError> {
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
		let peopleReviews = next ?? KKEndpoint.People.reviews(personIdentity).endpointValue
		let request: APIRequest<ReviewResponse, KKAPIError> = tron.codable.request(peopleReviews).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Rate the person with the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The id of the person which should be rated.
	///	   - score: The rating to leave.
	///	   - description: The description of the rating.
	///
	/// - Returns: An instance of `RequestSender` with the results of the rate person response.
	public func ratePerson(_ personIdentity: PersonIdentity, with score: Double, description: String?) -> RequestSender<KKSuccess, KKAPIError> {
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
		let peopleRate = KKEndpoint.People.rate(personIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(peopleRate).buildURL(.relativeToBaseURL)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
