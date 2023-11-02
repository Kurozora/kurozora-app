//
//  KurozoraKit+Session.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of sessions for the authenticated user.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get sessions response.
	public func getSessions(next: String? = nil, limit: Int = 25) -> RequestSender<SessionIdentityResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let meSessionsIndex = next ?? KKEndpoint.Me.Sessions.index.endpointValue
		let request: APIRequest<SessionIdentityResponse, KKAPIError> = tron.codable.request(meSessionsIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the session details for the given session id.
	///
	/// - Parameters:
	///    - sessionIdentity: The `SessionIdentity` object for which the details should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get session detail response.
	public func getDetails(forSession sessionIdentity: SessionIdentity) -> RequestSender<SessionResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let meSessionsDetail = KKEndpoint.Me.Sessions.details(sessionIdentity).endpointValue
		let request: APIRequest<SessionResponse, KKAPIError> = tron.codable.request(meSessionsDetail)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Delete the specified session from the user's active sessions.
	///
	/// - Parameters:
	///    - sessionIdentity: The `SessionIdentity` object to be deleted.
	///
	/// - Returns: An instance of `RequestSender` with the results of the delete session response.
	public func deleteSession(_ sessionIdentity: SessionIdentity) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let meSessionsDelete = KKEndpoint.Me.Sessions.delete(sessionIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meSessionsDelete)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
