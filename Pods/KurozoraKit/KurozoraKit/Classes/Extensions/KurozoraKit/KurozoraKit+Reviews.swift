//
//  KurozoraKit+Reviews.swift
//  Pods
//
//  Created by Khoren Katklian on 09/04/2025.
//

import TRON

extension KurozoraKit {
	/// Delete the specified review.
	///
	/// - Parameters:
	///    - reviewIdentity: The id of the review to delete.
	///
	/// - Returns: An instance of `RequestSender` with the results of the delete rating response.
	public func delete(_ reviewIdentity: ReviewIdentity) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let reviewsDelete = KKEndpoint.Reviews.delete(reviewIdentity).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(reviewsDelete).buildURL(.relativeToBaseURL)
			.method(.delete)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
