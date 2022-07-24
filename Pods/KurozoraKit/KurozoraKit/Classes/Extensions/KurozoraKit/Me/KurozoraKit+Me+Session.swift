//
//  KurozoraKit+Session.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the list of sessions for the authenticated user.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getSessions(next: String? = nil, limit: Int = 25) -> DataTask<SessionIdentityResponse> {
		let meSessionsIndex = next ?? KKEndpoint.Me.Sessions.index.endpointValue
		let request: APIRequest<SessionIdentityResponse, KKAPIError> = tron.codable.request(meSessionsIndex).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(SessionIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	/// Fetch the session details for the given session id.
	///
	/// - Parameters:
	///    - sessionIdentity: The `SessionIdentity` object for which the details should be fetched.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getDetails(forSession sessionIdentity: SessionIdentity) -> DataTask<SessionResponse> {
		let meSessionsDetail = KKEndpoint.Me.Sessions.details(sessionIdentity).endpointValue
		let request: APIRequest<SessionResponse, KKAPIError> = tron.codable.request(meSessionsDetail)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .get
		return request.perform().serializingDecodable(SessionResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	/// Delete the specified session from the user's active sessions.
	///
	/// - Parameters:
	///    - sessionIdentity: The `SessionIdentity` object to be deleted.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func deleteSession(_ sessionIdentity: SessionIdentity) -> DataTask<KKSuccess> {
		let meSessionsDelete = KKEndpoint.Me.Sessions.delete(sessionIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meSessionsDelete)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		return request.perform().serializingDecodable(KKSuccess.self, decoder: self.tron.codable.modelDecoder)
	}
}
