//
//  KurozoraKit+Game.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/03/2023.
//

import Alamofire
import TRON

extension KurozoraKit {
	///	Fetch the game details for the given game identity.
	///
	///	- Parameter gameIdentity: The id of the game for which the details should be fetched.
	///	- Parameter relationships: The relationships to include in the response.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forGame gameIdentity: GameIdentity, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Game], KKAPIError>) -> Void) -> DataRequest {
		let gamesDetails = KKEndpoint.Games.details(gameIdentity).endpointValue
		let request: APIRequest<GameResponse, KKAPIError> = tron.codable.request(gamesDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform(withSuccess: { gameResponse in
			completionHandler(.success(gameResponse.data))
		}, failure: { error in
			print("❌ Received get game details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	///	Fetch the person details for the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the person details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getPeople(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> DataTask<PersonIdentityResponse> {
		let gamesPeople = next ?? KKEndpoint.Games.people(gameIdentity).endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(gamesPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(PersonIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the cast details for the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the cast details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getCast(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> DataTask<CastIdentityResponse> {
		let gamesCast = next ?? KKEndpoint.Games.cast(gameIdentity).endpointValue
		let request: APIRequest<CastIdentityResponse, KKAPIError> = tron.codable.request(gamesCast).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(CastIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the character details for the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the character details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getCharacters(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> DataTask<CharacterIdentityResponse> {
		let gamesCharacters = next ?? KKEndpoint.Games.characters(gameIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(gamesCharacters).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(CharacterIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the related games for a the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the related games should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getRelatedGames(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> DataTask<RelatedGameResponse> {
		let gamesRelatedGames = next ?? KKEndpoint.Games.relatedGames(gameIdentity).endpointValue
		let request: APIRequest<RelatedGameResponse, KKAPIError> = tron.codable.request(gamesRelatedGames).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(RelatedGameResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the related shows for a the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the related shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getRelatedShows(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> DataTask<RelatedShowResponse> {
		let gamesRelatedShows = next ?? KKEndpoint.Games.relatedShows(gameIdentity).endpointValue
		let request: APIRequest<RelatedShowResponse, KKAPIError> = tron.codable.request(gamesRelatedShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(RelatedShowResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the related literatures for a the given game identity.
	///
	///	- Parameters:
	///	   - gameIdentity: The game identity object for which the related literatures should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getRelatedLiteratures(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> DataTask<RelatedLiteratureResponse> {
		let gamesRelatedLiteratures = next ?? KKEndpoint.Games.relatedLiteratures(gameIdentity).endpointValue
		let request: APIRequest<RelatedLiteratureResponse, KKAPIError> = tron.codable.request(gamesRelatedLiteratures).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(RelatedLiteratureResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the studios for a the given game identity.
	///
	///	- Parameter gameIdentity: The game identity object for which the studios should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getStudios(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> DataTask<StudioIdentityResponse> {
		let gamesSeasons = next ?? KKEndpoint.Games.studios(gameIdentity).endpointValue
		let request: APIRequest<StudioIdentityResponse, KKAPIError> = tron.codable.request(gamesSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(StudioIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the more by studio section for a the given game identity.
	///
	///	- Parameter gameIdentity: The game identity object for which the studio games should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getMoreByStudio(forGame gameIdentity: GameIdentity, next: String? = nil, limit: Int = 25) -> DataTask<GameIdentityResponse> {
		let gamesSeasons = next ?? KKEndpoint.Games.moreByStudio(gameIdentity).endpointValue
		let request: APIRequest<GameIdentityResponse, KKAPIError> = tron.codable.request(gamesSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(GameIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	/// Rate the game with the given game identity.
	///
	/// - Parameter gameIdentity: The id of the game which should be rated.
	///	- Parameter score: The rating to leave.
	///	- Parameter description: The description of the rating.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func rateGame(_ gameIdentity: GameIdentity, with score: Double, description: String?, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) -> DataRequest {
		let gamesRate = KKEndpoint.Games.rate(gameIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(gamesRate).buildURL(.relativeToBaseURL)

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
				UIApplication.topViewController?.presentAlertController(title: "Can't Rate Game 😔", message: error.message)
			}
			print("❌ Received game rating error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the cast details for the given game identity.
	///
	/// - Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	/// - Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	/// - Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getUpcomingGames(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<GameIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let upcomingGames = next ?? KKEndpoint.Games.upcoming.endpointValue
		let request: APIRequest<GameIdentityResponse, KKAPIError> = tron.codable.request(upcomingGames).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { gameIdentityResponse in
			completionHandler(.success(gameIdentityResponse))
		}, failure: { error in
			print("❌ Received get upcoming games error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
