//
//  KurozoraKit+Characters.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/06/2020.
//

import Alamofire
import TRON

extension KurozoraKit {
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
		var parameters: [String: Any] = [
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
}
