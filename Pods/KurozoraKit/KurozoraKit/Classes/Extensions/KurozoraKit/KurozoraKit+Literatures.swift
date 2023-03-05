//
//  KurozoraKit+Literature.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/02/2023.
//

import Alamofire
import TRON

extension KurozoraKit {
	///	Fetch the literature details for the given literature identity.
	///
	///	- Parameter literatureIdentity: The id of the literature for which the details should be fetched.
	///	- Parameter relationships: The relationships to include in the response.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forLiterature literatureIdentity: LiteratureIdentity, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Literature], KKAPIError>) -> Void) -> DataRequest {
		let literaturesDetails = KKEndpoint.Literatures.details(literatureIdentity).endpointValue
		let request: APIRequest<LiteratureResponse, KKAPIError> = tron.codable.request(literaturesDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform(withSuccess: { literatureResponse in
			completionHandler(.success(literatureResponse.data))
		}, failure: { error in
			print("❌ Received get literature details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	///	Fetch the person details for the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the person details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getPeople(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> DataTask<PersonIdentityResponse> {
		let literaturesPeople = next ?? KKEndpoint.Literatures.people(literatureIdentity).endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(literaturesPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(PersonIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the cast details for the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the cast details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getCast(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> DataTask<CastIdentityResponse> {
		let literaturesCast = next ?? KKEndpoint.Literatures.cast(literatureIdentity).endpointValue
		let request: APIRequest<CastIdentityResponse, KKAPIError> = tron.codable.request(literaturesCast).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(CastIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the character details for the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the character details should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getCharacters(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> DataTask<CharacterIdentityResponse> {
		let literaturesCharacters = next ?? KKEndpoint.Literatures.characters(literatureIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(literaturesCharacters).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(CharacterIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the related literatures for a the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the related literatures should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getRelatedLiteratures(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> DataTask<RelatedLiteratureResponse> {
		let literaturesRelatedLiteratures = next ?? KKEndpoint.Literatures.relatedLiteratures(literatureIdentity).endpointValue
		let request: APIRequest<RelatedLiteratureResponse, KKAPIError> = tron.codable.request(literaturesRelatedLiteratures).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(RelatedLiteratureResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the related shows for a the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the related shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getRelatedShows(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> DataTask<RelatedShowResponse> {
		let literaturesRelatedShows = next ?? KKEndpoint.Literatures.relatedShows(literatureIdentity).endpointValue
		let request: APIRequest<RelatedShowResponse, KKAPIError> = tron.codable.request(literaturesRelatedShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(RelatedShowResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the related games for a the given literature identity.
	///
	///	- Parameters:
	///	   - literatureIdentity: The literature identity object for which the related games should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getRelatedGames(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> DataTask<RelatedGameResponse> {
		let literaturesRelatedGames = next ?? KKEndpoint.Literatures.relatedGames(literatureIdentity).endpointValue
		let request: APIRequest<RelatedGameResponse, KKAPIError> = tron.codable.request(literaturesRelatedGames).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(RelatedGameResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the studios for a the given literature identity.
	///
	///	- Parameter literatureIdentity: The literature identity object for which the studios should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getStudios(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> DataTask<StudioIdentityResponse> {
		let literaturesSeasons = next ?? KKEndpoint.Literatures.studios(literatureIdentity).endpointValue
		let request: APIRequest<StudioIdentityResponse, KKAPIError> = tron.codable.request(literaturesSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(StudioIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the more by studio section for a the given literature identity.
	///
	///	- Parameter literatureIdentity: The literature identity object for which the studio literatures should be fetched.
	///	- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getMoreByStudio(forLiterature literatureIdentity: LiteratureIdentity, next: String? = nil, limit: Int = 25) -> DataTask<LiteratureIdentityResponse> {
		let literaturesSeasons = next ?? KKEndpoint.Literatures.moreByStudio(literatureIdentity).endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(literaturesSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(LiteratureIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	/// Rate the literature with the given literature identity.
	///
	/// - Parameter literatureIdentity: The id of the literature which should be rated.
	///	- Parameter score: The rating to leave.
	///	- Parameter description: The description of the rating.
	///	- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func rateLiterature(_ literatureIdentity: LiteratureIdentity, with score: Double, description: String?, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) -> DataRequest {
		let literaturesRate = KKEndpoint.Literatures.rate(literatureIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(literaturesRate).buildURL(.relativeToBaseURL)

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
				UIApplication.topViewController?.presentAlertController(title: "Can't Rate Literature 😔", message: error.message)
			}
			print("❌ Received literature rating error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the cast details for the given literature identity.
	///
	/// - Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	/// - Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	/// - Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	/// - Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getUpcomingLiteratures(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<LiteratureIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let upcomingLiteratures = next ?? KKEndpoint.Literatures.upcoming.endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(upcomingLiteratures).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { literatureIdentityResponse in
			completionHandler(.success(literatureIdentityResponse))
		}, failure: { error in
			print("❌ Received get upcoming literatures error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
