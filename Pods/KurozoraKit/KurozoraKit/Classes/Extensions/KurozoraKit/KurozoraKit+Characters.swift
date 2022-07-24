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
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forCharacter characterIdentity: CharacterIdentity, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Character], KKAPIError>) -> Void) -> DataRequest {
		let character = KKEndpoint.Shows.Characters.details(characterIdentity).endpointValue
		let request: APIRequest<CharacterResponse, KKAPIError> = tron.codable.request(character)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform(withSuccess: { characterResponse in
			completionHandler(.success(characterResponse.data))
		}, failure: { error in
			print("❌ Received get character details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the people for the given character identity.
	///
	/// - Parameters:
	///    - characterIdentity: The character identity object for which the people should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getPeople(forCharacter characterIdentity: CharacterIdentity, next: String? = nil, limit: Int = 25) -> DataTask<PersonIdentityResponse> {
		let charactersPeople = next ?? KKEndpoint.Shows.Characters.people(characterIdentity).endpointValue
		let request: APIRequest<PersonIdentityResponse, KKAPIError> = tron.codable.request(charactersPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		if next == nil {
			request.parameters["limit"] = limit
		}

		request.method = .get
		return request.perform().serializingDecodable(PersonIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	/// Fetch the shows for the given character identity.
	///
	/// - Parameters:
	///    - characterIdentity: The character identity object for which the shows should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getShows(forCharacter characterIdentity: CharacterIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let charactersShows = next ?? KKEndpoint.Shows.Characters.shows(characterIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(charactersShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { showIdentityResponse in
			completionHandler(.success(showIdentityResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Character's Shows 😔", message: error.message)
			}
			print("❌ Received get character shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
