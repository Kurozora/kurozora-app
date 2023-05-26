//
//  KurozoraKit+Misc.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 9/12/2022.
//

import TRON

extension KurozoraKit {
	///	Fetch meta info.
	///
	/// - Returns: An instance of `RequestSender` with the results of the meta response.
	public func getInfo() -> RequestSender<MetaResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let metaRepsonse = KKEndpoint.Misc.info.endpointValue
		let request: APIRequest<MetaResponse, KKAPIError> = tron.codable.request(metaRepsonse)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch settings used to enable additional features in the app.
	///k
	/// - Returns: An instance of `RequestSender` with the results of the settings response.
	public func getSettings() -> RequestSender<SettingsResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let settingsRepsonse = KKEndpoint.Misc.settings.endpointValue
		let request: APIRequest<SettingsResponse, KKAPIError> = tron.codable.request(settingsRepsonse)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
