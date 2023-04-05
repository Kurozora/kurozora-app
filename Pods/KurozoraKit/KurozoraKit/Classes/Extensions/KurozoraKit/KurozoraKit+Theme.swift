//
//  KurozoraKit+Theme.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of themes.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get themes response.
	public func getThemes() -> RequestSender<ThemeResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let themesIndex = KKEndpoint.Shows.Themes.index.endpointValue
		let request: APIRequest<ThemeResponse, KKAPIError> = tron.codable.request(themesIndex)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the theme details for the given theme identity.
	///
	/// - Parameters:
	///    - themeIdentity: The theme identity object of the theme for which the details should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get theme detaisl response.
	public func getDetails(forTheme themeIdentity: ThemeIdentity) -> RequestSender<ThemeResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let themesDetails = KKEndpoint.Shows.Themes.details(themeIdentity).endpointValue
		let request: APIRequest<ThemeResponse, KKAPIError> = tron.codable.request(themesDetails)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
