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
		let peopleDetails = KKEndpoint.People.details(personIdentity).endpointValue
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
			print("┌ Server message:", error.message)
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
		let charactersPeople = next ?? KKEndpoint.People.characters(personIdentity).endpointValue
		let request: APIRequest<CharacterIdentityResponse, KKAPIError> = tron.codable.request(charactersPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		if next == nil {
			request.parameters["limit"] = limit
		}

		request.method = .get
		return request.perform().serializingDecodable(CharacterIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the shows for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The person identity object for which the shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getShows(forPerson personIdentity: PersonIdentity, next: String? = nil, limit: Int = 25) -> DataTask<ShowIdentityResponse> {
		let peopleShows = next ?? KKEndpoint.People.shows(personIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(peopleShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(ShowIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	/// Fetch the literatures for the given person identity.
	///
	/// - Parameters:
	///    - personIdentity: The person identity object for which the literatures should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getLiteratures(forPerson personIdentity: PersonIdentity, next: String? = nil, limit: Int = 25) -> DataTask<LiteratureIdentityResponse> {
		let peopleLiteratures = next ?? KKEndpoint.People.literatures(personIdentity).endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(peopleLiteratures).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(LiteratureIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}
}
