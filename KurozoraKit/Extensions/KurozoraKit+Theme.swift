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

		- Parameter successHandler: A closure returning a ThemesElement array.
		- Parameter themes: The returned ThemesElement array.
	*/
	public func getThemes(withSuccess successHandler: @escaping (_ themes: [ThemesElement]?) -> Void) {
		let themes = self.kurozoraKitEndpoints.themes
		let request: APIRequest<Themes, JSONError> = tron.swiftyJSON.request(themes)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { themes in
			if let success = themes.success {
				if success {
					successHandler(themes.themes)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get themes 😔", subTitle: error.message)
			print("Received get themes error: \(error.message ?? "No message available")")
		})
	}
}
