//
//  KurozoraKit+Recap.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/01/2024.
//

import TRON

extension KurozoraKit {
	/// Fetch the recap list.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get recap list response.
	public func getRecaps() -> RequestSender<RecapResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let recapIndex = KKEndpoint.Me.Recap.index.endpointValue
		let request: APIRequest<RecapResponse, KKAPIError> = tron.codable.request(recapIndex)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch recaps for the specified year.
	///
	/// - Parameters:
	///    - year: The year for which the recaps are fetched.
	///    - month: The month for which the recaps are fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get recap item response.
	public func getRecap(for year: String, month: String) -> RequestSender<RecapItemResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let recapDetails = KKEndpoint.Me.Recap.details(year, month).endpointValue
		let request: APIRequest<RecapItemResponse, KKAPIError> = tron.codable.request(recapDetails).buildURL(.relativeToBaseURL)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
