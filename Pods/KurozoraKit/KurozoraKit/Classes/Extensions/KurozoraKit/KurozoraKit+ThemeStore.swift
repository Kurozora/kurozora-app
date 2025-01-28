//
//  KurozoraKit+AppTheme.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of app themes from AppTheme Store.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get theme store response.
	public func getThemeStore() -> RequestSender<AppThemeResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let themeStoreIndex = KKEndpoint.ThemeStore.index.endpointValue
		let request: APIRequest<AppThemeResponse, KKAPIError> = tron.codable.request(themeStoreIndex)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the app theme details for the given app theme id.
	///
	/// - Parameters:
	///    - appThemeID: The id of the theme for which the details should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get theme details response.
	public func getDetails(forAppThemeID appThemeID: String) -> RequestSender<AppThemeResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let themeStoreDetails = KKEndpoint.ThemeStore.details(appThemeID).endpointValue
		let request: APIRequest<AppThemeResponse, KKAPIError> = tron.codable.request(themeStoreDetails)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
