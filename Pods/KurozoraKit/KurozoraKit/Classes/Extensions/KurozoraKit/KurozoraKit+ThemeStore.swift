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
	/// - Parameters:
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getThemeStore(completion completionHandler: @escaping (_ result: Result<[AppTheme], KKAPIError>) -> Void) {
		let themeStoreIndex = KKEndpoint.ThemeStore.index.endpointValue
		let request: APIRequest<AppThemeResponse, KKAPIError> = tron.codable.request(themeStoreIndex)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		request.perform(withSuccess: { themeResponse in
			completionHandler(.success(themeResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Theme Store 😔", message: error.message)
			}
			print("❌ Received get themes error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the app theme details for the given app theme id.
	///
	/// - Parameters:
	///    - themeID: The id of the theme for which the details should be fetched.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getDetails(forAppThemeID appThemeID: Int, completion completionHandler: @escaping (_ result: Result<[AppTheme], KKAPIError>) -> Void) {
		let themeStoreDetails = KKEndpoint.ThemeStore.details(appThemeID).endpointValue
		let request: APIRequest<AppThemeResponse, KKAPIError> = tron.codable.request(themeStoreDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		request.perform(withSuccess: { themeResponse in
			completionHandler(.success(themeResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Theme Store Details 😔", message: error.message)
			}
			print("❌ Received get theme store details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
