//
//  ImageFetcher.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 07/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation

/// A utility class to fetch images from a url.
struct ImageFetcher {
	/// Fetch image from the network.
	///
	/// - Parameters:
	///  - url: The URL of the image.
	static func fetchImage(from url: URL?) async -> URL? {
		guard let url = url else { return nil }

		do {
			let (localURL, _) = try await URLSession.shared.download(from: url)
			return localURL
		} catch {
			return nil
		}
	}
}
