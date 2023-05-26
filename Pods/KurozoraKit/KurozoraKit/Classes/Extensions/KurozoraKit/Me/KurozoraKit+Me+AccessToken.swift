//
//  KurozoraKit+AccessToken.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of access tokens for the authenticated user.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get access tokens response.
	public func getAccessTokens(next: String? = nil, limit: Int = 25) -> RequestSender<AccessTokenResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let meAccessTokensIndex = next ?? KKEndpoint.Me.AccessTokens.index.endpointValue
		let request: APIRequest<AccessTokenResponse, KKAPIError> = tron.codable.request(meAccessTokensIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the access token details for the given access token.
	///
	/// - Parameters:
	///    - accessToken: The access token for which the details should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get access token details response.
	public func getDetails(forAccessToken accessToken: String) -> RequestSender<AccessTokenResponse, KKAPIError> {
		let tokenID = accessToken.components(separatedBy: "|")[0]
		let meAccessTokensDetail = KKEndpoint.Me.AccessTokens.details(tokenID).endpointValue
		let request: APIRequest<AccessTokenResponse, KKAPIError> = tron.codable.request(meAccessTokensDetail)
			.method(.get)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	/// Update a access token with the specified data.
	///
	/// - Parameters:
	///    - apnDeviceToken: The updated APN Device Token.
	///
	/// - Returns: An instance of `RequestSender` with the results of the update access token response.
	public func updateAccessToken(withAPNToken apnDeviceToken: String) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"apn_device_token": apnDeviceToken
		]

		// Prepare request
		let tokenID = self.authenticationKey.components(separatedBy: "|")[0]
		let meAccessTokensUpdate = KKEndpoint.Me.AccessTokens.update(tokenID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meAccessTokensUpdate)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Delete the specified access token from the user's active access tokens.
	///
	/// - Parameters:
	///    - accessToken: The access token to be deleted.
	///
	/// - Returns: An instance of `RequestSender` with the results of the delete access token response.
	public func deleteAccessToken(_ accessToken: String) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let tokenID = accessToken.components(separatedBy: "|")[0]
		let meAccessTokensDelete = KKEndpoint.Me.AccessTokens.delete(tokenID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meAccessTokensDelete)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Sign out the given user access token.
	///
	/// - Returns: An instance of `RequestSender` with the results of the sign out response.
	public func signOut() -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let meAccessTokensDelete = KKEndpoint.Me.AccessTokens.delete(self.authenticationKey).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meAccessTokensDelete)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
