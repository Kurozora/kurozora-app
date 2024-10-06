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
	static let gitHubPageURL = URL(string: "https://github.com/Kurozora")

	/// The Mastodon page URL of Kurozora.
	static let mastodonPageURL = URL(string: "https://mastodon.social/@kurozora")

	/// The deep link URL to the App Store rating page of Kurozora.
	static let rateURL = URL(string: "itms-apps://apps.apple.com/us/app/kurozora/id1476153872?action=write-review")

	/// The deep link URL to the Subscription Management page of the user.
	static let subscriptionManagement = URL(string: "itms://apps.apple.com/account/subscriptions")

	/// The deep link URL to the Twitter page of Kurozora.
	static let twitterPageDeepLink = URL(string: "twitter://user?id=991929359052177409")

	/// The Twitter page URL of Kurozora.
	static let twitterPageURL = URL(string: "https://www.twitter.com/KurozoraApp")

	/// Kuro-chan's Signal sticker pack URL.
	static let signalStickerURL = URL(string: "https://signal.art/addstickers/#pack_id=3fc173cd8f028c47523f1917f11c5925&pack_key=2d9508edc1568dc85cd67f3cd2c92e11a7499f800f264de223a56b6299a6c984")

	/// Kuro-chan's Telegram sticker pack URL.
	static let telegramStickerURL = URL(string: "https://t.me/addstickers/KuroChanVT")

	// MARK: - Functions
	/// The Amazon Music URL for the given ID.
	///
	/// - Parameter amazonID: The song's ID on Amazon Music.
	///
	/// - Returns: The Amazon Music URL for the given ID.
	static func amazonMusicURL(amazonID: String) -> URL? {
		return URL(string: "https://amazon.com/music/player/albums/\(amazonID)")
	}

	/// The Deezer URL for the given ID.
	///
	/// - Parameter deezerID: The song's ID on Deezer.
	///
	/// - Returns: The Deezer URL for the given ID.
	static func deezerURL(deezerID: Int) -> URL? {
		return URL(string: "https://deezer.com/track/\(deezerID)")
	}

	/// The Spotify URL for the given ID.
	///
	/// - Parameter spotifyID: The song's ID on Spotify.
	///
	/// - Returns: The Spotify URL for the given ID.
	static func spotifyURL(spotifyID: String) -> URL? {
		return URL(string: "https://open.spotify.com/track/\(spotifyID)")
	}

	/// The YouTube URL for the given ID.
	///
	/// - Parameter youtubeID: The song's ID on YouTube.
	///
	/// - Returns: The YouTube URL for the given ID.
	static func youtubeURL(youtubeID: String) -> URL? {
		return URL(string: "https://music.youtube.com/watch?v=\(youtubeID)")
	}

	/// The root domain of the URL or domain name.
	var rootDomain: String? {
		return self.host?.replacingOccurrences(of: "www.", with: "")
	}

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

	/// Returns true if the extension is an image.
	public var isImageURL: Bool {
		return [
			"jpg", "jpeg", "jpgxl",
			"png", "apng", "avif",
			"gif", "webp",
			"bmp", "tiff"
		].contains(self.pathExtension)
	}

	/// Returns true if the scheme is `HTTP` or `HTTPS`
	public var isWebURL: Bool {
		return self.scheme?.starts(with: "http") ?? false
	}
}
