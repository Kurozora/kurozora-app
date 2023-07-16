//
//  URL+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation
import UIKit.UIApplication

extension URL {
	// MARK: - Properties
	/// The deep link URL to the App Store page of Kurozora.
	static let appStoreURL = URL(string: "itms-apps://apps.apple.com/us/app/kurozora/id1476153872")

	/// The deep link URL to the App Store's EULA.
	static let appStoreEULA = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")

	/// The Discord invitation URL of Kurozora.
	static let discordPageURL = URL(string: "https://discord.gg/f3QFzGqsah")

	/// The GitHub URL of Kurozora.
	static let githubURL = URL(string: "https://github.com/Kurozora")

	/// The deep link URL to the Medium page of Kurozora.
	static let mediumPageDeepLink = URL(string: "medium://@kurozora")

	/// The Medium page URL of Kurozora.
	static let mediumPageURL = URL(string: "https://medium.com/@kurozora")

	/// The deep link URL to the App Store rating page of Kurozora.
	static let rateURL = URL(string: "itms-apps://apps.apple.com/us/app/kurozora/id1476153872?action=write-review")

	/// The deep link URL to the Subscription Management page of the user.
	static let subscriptionManagement = URL(string: "itms://apps.apple.com/account/subscriptions")

	/// The deep link URL to the Twitter page of Kurozora.
	static let twitterPageDeepLink = URL(string: "twitter://user?id=991929359052177409")

	/// The Twitter page URL of Kurozora.
	static let twitterPageURL = URL(string: "https://www.twitter.com/KurozoraApp")

	// MARK: - Functions
	/// Returns the preferred `URL` to open by the app.
	///
	/// Replaces the scheme of the url with ther user's preferred scheme if the scheme can be opened by the system, otherwise the url is returned as is.
	///
	/// - Returns: the preferred `URL` to open by the app.
	func withPreferredScheme() -> URL {
		guard let scheme = self.scheme?.appending("://") else { return self }
		let kBrowser = UserSettings.defaultBrowser
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
