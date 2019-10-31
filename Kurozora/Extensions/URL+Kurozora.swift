//
//  URL+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension URL {
	static let twitterPageDeepLink = URL(string: "twitter://user?id=991929359052177409")
	static let twitterPageURL = URL(string: "https://www.twitter.com/KurozoraApp")
	static let mediumPageDeepLink = URL(string: "medium://@kurozora")
	static let mediumPageURL = URL(string: "https://medium.com/@kurozora")
	static let rateURL = URL(string: "itms-apps://apps.apple.com/gb/app/id1442061397?action=write-review")

	/// Replaces the scheme of the url with ther user's preferred scheme if the scheme can be opened by the system, otherwise the url is returned as is.
	func withPreferredScheme() -> URL {
		guard let scheme = self.scheme?.appending("://") else { return self }
		let kBrowser = KBrowser(rawValue: UserSettings.defaultBrowser) ?? .safari
		guard kBrowser.schemeValue(for: scheme) != "" else { return self }

		var urlWithPreferredScheme = self
		if let kBrowserShortSchemeUrl = kBrowser.shortSchemeUrlValue(for: scheme), UIApplication.shared.canOpenURL(kBrowserShortSchemeUrl) {
			let urlStringWithNewScheme = "\(self)".replacingOccurrences(of: scheme, with: kBrowser.schemeValue(for: scheme))
			if let newUrlWithNewScheme = URL(string: urlStringWithNewScheme) {
				urlWithPreferredScheme = newUrlWithNewScheme
			}
		}
		return urlWithPreferredScheme
	}
}
