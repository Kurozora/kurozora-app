//
//  KurozoraKit+Images.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/04/2024.
//

import TRON

extension KurozoraKit {
	/// Fetch a collection of random images.
	///
	/// - Parameters:
	///   - type: The type of the images.
	///   - collection: The collection the images belong to.
	///   - limit: The number of images to fetch. The default value is 1 and the maximum value is 25.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get random images response.
	public func getRandomImages(of kind: MediaKind, from collection: MediaCollection, limit: Int = 1) -> RequestSender<MediaResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		let parameters: [String: Any] = [
			"type": kind.rawValue,
			"collection": collection.rawValue,
			"limit": limit
		]

		// Prepare request
		let imagesRandom = KKEndpoint.Images.random.endpointValue
		let request: APIRequest<MediaResponse, KKAPIError> = tron.codable.request(imagesRandom)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
