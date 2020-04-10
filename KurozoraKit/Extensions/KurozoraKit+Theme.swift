//
//  KurozoraKit+Theme.swift
//  Kurozora
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
	public func getThemes(completion completionHandler: @escaping (_ result: Result<[ThemesElement], KKError>) -> Void) {
		let themes = self.kurozoraKitEndpoints.themes
		let request: APIRequest<Themes, KKError> = tron.swiftyJSON.request(themes)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { themes in
			completionHandler(.success(themes.themes ?? []))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get themes 😔", subTitle: error.message)
			}
			print("Received get themes error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
