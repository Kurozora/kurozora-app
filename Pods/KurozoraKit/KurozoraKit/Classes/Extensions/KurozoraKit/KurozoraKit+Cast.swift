//
//  KurozoraKit+Cast.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/02/2022.
//

import TRON
import Alamofire

extension KurozoraKit {
	/// Fetch the cast details for the given cast id.
	///
	/// - Parameters:
	///    - castID: The id of the cast for which the details should be fetched.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getDetails(forCast castIdentity: CastIdentity) -> DataTask<CastResponse> {
		let castsDetails = KKEndpoint.Shows.Cast.details(castIdentity).endpointValue
		let request: APIRequest<CastResponse, KKAPIError> = tron.codable.request(castsDetails)

		request.headers = headers

		request.method = .get
		return request.perform().serializingDecodable(CastResponse.self, decoder: self.tron.codable.modelDecoder)
	}
}
