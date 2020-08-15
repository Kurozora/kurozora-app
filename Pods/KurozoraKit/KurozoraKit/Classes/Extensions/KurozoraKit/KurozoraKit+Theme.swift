//
//  KurozoraKit+Theme.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the list of themes.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getThemes(completion completionHandler: @escaping (_ result: Result<[Theme], KKAPIError>) -> Void) {
		let themes = self.kurozoraKitEndpoints.themes
		let request: APIRequest<ThemeResponse, KKAPIError> = tron.codable.request(themes)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { themeResponse in
			completionHandler(.success(themeResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get themes 😔", subTitle: error.message)
			}
			print("❌ Received get themes error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
