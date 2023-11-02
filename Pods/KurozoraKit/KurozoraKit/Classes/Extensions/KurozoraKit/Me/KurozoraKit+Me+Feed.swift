//
//  KurozoraKit+Me+Feed.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/09/2020.
//

import TRON

extension KurozoraKit {
	/// Fetch a list of authenticated user's feed messages.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get feed messages response.
	public func getFeedMessages(next: String? = nil, limit: Int = 25) -> RequestSender<FeedMessageResponse, KKAPIError> {
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
		let meFeedMessages = next ?? KKEndpoint.Me.Feed.messages.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(meFeedMessages).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
