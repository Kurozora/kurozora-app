//
//  KurozoraKit+Game.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/03/2023.
//

import TRON

extension KurozoraKit {
	///	Fetch the game details for the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The identity of the game for which the details should be fetched.
	///	   - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get game detail response.
	public func getDetails(forGame gameIdentity: GameIdentity, including relationships: [String] = []) -> RequestSender<GameResponse, KKAPIError> {
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
		let gamesDetails = KKEndpoint.Games.details(gameIdentity).endpointValue
		let request: APIRequest<GameResponse, KKAPIError> = tron.codable.request(gamesDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the person details for the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the person details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get people response.
	public func getPeople(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<PersonIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let gamesPeople = next ?? KKEndpoint.Games.people(gameIdentity).endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(gamesPeople).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the cast details for the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the cast details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get cast response.
	public func getCast(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<CastIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let gamesCast = next ?? KKEndpoint.Games.cast(gameIdentity).endpointValue
		let request: APIRequest<CastIdentityResponse, KKAPIError> = tron.codable.request(gamesCast).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the character details for the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the character details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get characters response.
	public func getCharacters(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<CharacterIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let gamesCharacters = next ?? KKEndpoint.Games.characters(gameIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(gamesCharacters).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the related games for a the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the related games should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get related games response.
	public func getRelatedGames(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<RelatedGameResponse, KKAPIError> {
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
		let gamesRelatedGames = next ?? KKEndpoint.Games.relatedGames(gameIdentity).endpointValue
		let request: APIRequest<RelatedGameResponse, KKAPIError> = tron.codable.request(gamesRelatedGames).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the related shows for a the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the related shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get related shows response.
	public func getRelatedShows(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<RelatedShowResponse, KKAPIError> {
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
		let gamesRelatedShows = next ?? KKEndpoint.Games.relatedShows(gameIdentity).endpointValue
		let request: APIRequest<RelatedShowResponse, KKAPIError> = tron.codable.request(gamesRelatedShows).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the related literatures for a the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the related literatures should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get related literatures response.
	public func getRelatedLiteratures(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<RelatedLiteratureResponse, KKAPIError> {
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
		let gamesRelatedLiteratures = next ?? KKEndpoint.Games.relatedLiteratures(gameIdentity).endpointValue
		let request: APIRequest<RelatedLiteratureResponse, KKAPIError> = tron.codable.request(gamesRelatedLiteratures).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the reviews for a the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the reviews should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get reviews response.
	public func getReviews(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ReviewResponse, KKAPIError> {
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
		let gamesReviews = next ?? KKEndpoint.Games.reviews(gameIdentity).endpointValue
		let request: APIRequest<ReviewResponse, KKAPIError> = tron.codable.request(gamesReviews).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the studios for a the given game identity.
	///
	///	- Parameter gameIdentity: The game identity object for which the studios should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get studios response.
	public func getStudios(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<StudioIdentityResponse, KKAPIError> {
		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let gamesSeasons = next ?? KKEndpoint.Games.studios(gameIdentity).endpointValue
		let request: APIRequest<StudioIdentityResponse, KKAPIError> = tron.codable.request(gamesSeasons).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///	Fetch the more by studio section for a the given game identity.
	///
	///	- Parameter gameIdentity: The game identity object for which the studio games should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get more by studio response.
	public func getMoreByStudio(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<GameIdentityResponse, KKAPIError> {
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
		let gamesSeasons = next ?? KKEndpoint.Games.moreByStudio(gameIdentity).endpointValue
		let request: APIRequest<GameIdentityResponse, KKAPIError> = tron.codable.request(gamesSeasons).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Rate the game with the given game identity.
	///
	/// - Parameters:
	///    - gameID: The id of the game which should be rated.
	///	   - score: The rating to leave.
	///	   - description: The description of the rating.
	///
	/// - Returns: An instance of `RequestSender` with the results of the rate game response.
	public func rateGame(_ gameIdentity: GameIdentity, with score: Double, description: String?) -> RequestSender<KKSuccess, KKAPIError> {
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
		let gamesRate = KKEndpoint.Games.rate(gameIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(gamesRate).buildURL(.relativeToBaseURL)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the cast details for the given game identity.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get upcoming games response.
	public func getUpcomingGames(next: String? = nil, limit: Int = 25) -> RequestSender<GameIdentityResponse, KKAPIError> {
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
		let upcomingGames = next ?? KKEndpoint.Games.upcoming.endpointValue
		let request: APIRequest<GameIdentityResponse, KKAPIError> = tron.codable.request(upcomingGames).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
