//
//  KurozoraKit+Cast.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/02/2022.
//

import TRON

extension KurozoraKit {
	/// Fetch the cast details for the given cast id.
	///
	/// - Parameters:
	///    - castID: The id of the cast for which the details should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the cast details response.
	public func getDetails(forShowCast castIdentity: CastIdentity) -> RequestSender<CastResponse, KKAPIError> {
		// Prepare request
		let castsDetails = KKEndpoint.Cast.showCast(castIdentity).endpointValue
		let request: APIRequest<CastResponse, KKAPIError> = tron.codable.request(castsDetails)
			.method(.get)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	/// Fetch the cast details for the given cast id.
	///
	/// - Parameters:
	///    - castID: The id of the cast for which the details should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the cast details response.
	public func getDetails(forLiteratureCast castIdentity: CastIdentity) -> RequestSender<CastResponse, KKAPIError> {
		// Prepare request
		let castsDetails = KKEndpoint.Cast.literatureCast(castIdentity).endpointValue
		let request: APIRequest<CastResponse, KKAPIError> = tron.codable.request(castsDetails)
			.method(.get)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	/// Fetch the cast details for the given cast id.
	///
	/// - Parameters:
	///    - castID: The id of the cast for which the details should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the cast details response.
	public func getDetails(forGameCast castIdentity: CastIdentity) -> RequestSender<CastResponse, KKAPIError> {
		// Prepare request
		let castsDetails = KKEndpoint.Cast.gameCast(castIdentity).endpointValue
		let request: APIRequest<CastResponse, KKAPIError> = tron.codable.request(castsDetails)
			.method(.get)
			.headers(self.headers)

		// Send request
		return request.sender()
	}
}
