//
//  KurozoraKit+People.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the person details for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The persion identity object of the person for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forPerson personIdentity: PersonIdentity, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Person], KKAPIError>) -> Void) -> DataRequest {
		let peopleDetails = KKEndpoint.Shows.People.details(personIdentity).endpointValue
		let request: APIRequest<PersonResponse, KKAPIError> = tron.codable.request(peopleDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform(withSuccess: { personResponse in
			completionHandler(.success(personResponse.data))
		}, failure: { error in
			print("❌ Received get person details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the characters for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The person identity object for which the characters should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getCharacters(forPerson personIdentity: PersonIdentity, next: String? = nil, limit: Int = 25) -> DataTask<CharacterIdentityResponse> {
		let charactersPeople = next ?? KKEndpoint.Shows.People.characters(personIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(charactersPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		if next == nil {
			request.parameters["limit"] = limit
		}

		request.method = .get
		return request.perform().serializingDecodable(CharacterIdentityResponse.self)
	}

	/// Fetch the shows for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The person identity object for which the shows should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getShows(forPerson personIdentity: PersonIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let charactersShows = next ?? KKEndpoint.Shows.People.shows(personIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(charactersShows).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { showIdentityResponse in
			completionHandler(.success(showIdentityResponse))
		}, failure: { error in
			print("❌ Received get person shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
