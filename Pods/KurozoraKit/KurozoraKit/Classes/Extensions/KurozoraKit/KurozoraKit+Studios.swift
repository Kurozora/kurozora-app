//
//  KurozoraKit+Studio.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/06/2020.
//

import TRON

extension KurozoraKit {
	///	Fetch the studio details for the given studio identiry.
	///
	/// - Parameters:
	///    - studioIdentity: The studio identity ibject of the studio for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get studio detail response.
	public func getDetails(forStudio studioIdentity: StudioIdentity, including relationships: [String] = [], limit: Int? = nil) -> RequestSender<StudioResponse, KKAPIError> {
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
		let studiosDetails = KKEndpoint.Studios.details(studioIdentity).endpointValue
		let request: APIRequest<StudioResponse, KKAPIError> = tron.codable.request(studiosDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the shows for the given studio identity.
	///
	/// - Parameters:
	///    - studioIdentity: The studio identity object for which the shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get shows response.
	public func getShows(forStudio studioIdentity: StudioIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ShowIdentityResponse, KKAPIError> {
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
		let studiosShows = next ?? KKEndpoint.Studios.shows(studioIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(studiosShows).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the literatures for the given studio identity.
	///
	/// - Parameters:
	///    - studioIdentity: The studio identity object for which the literatures should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get literatures response.
	public func getLiteratures(forStudio studioIdentity: StudioIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<LiteratureIdentityResponse, KKAPIError> {
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
		let studiosLiteratures = next ?? KKEndpoint.Studios.literatures(studioIdentity).endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(studiosLiteratures).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the games for the given studio identity.
	///
	/// - Parameters:
	///    - studioIdentity: The studio identity object for which the games should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get games response.
	public func getGames(forStudio studioIdentity: StudioIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<GameIdentityResponse, KKAPIError> {
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
		let studiosGames = next ?? KKEndpoint.Studios.games(studioIdentity).endpointValue
		let request: APIRequest<GameIdentityResponse, KKAPIError> = tron.codable.request(studiosGames).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
