//
//  KurozoraKit+Theme.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the list of themes.
	///
	/// - Parameters:
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getThemes(completion completionHandler: @escaping (_ result: Result<[Theme], KKAPIError>) -> Void) -> DataRequest {
		let themesIndex = KKEndpoint.Shows.Themes.index.endpointValue
		let request: APIRequest<ThemeResponse, KKAPIError> = tron.codable.request(themesIndex)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		return request.perform(withSuccess: { themeResponse in
			completionHandler(.success(themeResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Themes 😔", message: error.message)
			}
			print("❌ Received get themes error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the theme details for the given theme identity.
	///
	/// - Parameters:
	///    - themeIdentity: The theme identity object of the theme for which the details should be fetched.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forTheme themeIdentity: ThemeIdentity, completion completionHandler: @escaping (_ result: Result<[Theme], KKAPIError>) -> Void) -> DataRequest {
		let themesDetails = KKEndpoint.Shows.Themes.details(themeIdentity).endpointValue
		let request: APIRequest<ThemeResponse, KKAPIError> = tron.codable.request(themesDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		return request.perform(withSuccess: { themeResponse in
			completionHandler(.success(themeResponse.data))
		}, failure: { error in
			print("❌ Received get theme details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
