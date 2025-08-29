//
//  ImageFetcher.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 07/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import CryptoKit
import UIKit

/// A utility class to fetch images from a url.
struct ImageFetcher {
	// MARK: - Properties
	/// The subdirectory for cached image files.
	private let fileDirectory = "widget"
	/// The prefix for cached image files.
	private let filePrefix = "kurozora-"
	/// The lifetime of the cached image in seconds.
	private let cacheLifetime: TimeInterval = 86400 // 1 day

	/// The cache directory URL.
	private var cacheDirectory: URL {
		if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
			return .cachesDirectory
		} else {
			return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
		}
	}

	/// The shared instance of the ImageFetcher.
	static let shared = ImageFetcher()

	// MARK: - Initializers
	private init() {
		// Create "widget" directory if it doesn't exist
		do {
			let directory = self.cacheDirectory.appendingPathComponent(self.fileDirectory)

			if !FileManager.default.fileExists(atPath: directory.path) {
				try FileManager.default.createDirectory(atPath: directory.relativePath, withIntermediateDirectories: true, attributes: nil)
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	/// The path where the cached image located.
	///
	/// - Parameters:
	///    - url: The URL of the image.
	///
	/// - Returns: The local path of the cached image.
	private func cachePath(for url: URL) -> URL? {
		let hash = SHA256.hash(data: Data(url.absoluteString.utf8)).map { String(format: "%02x", $0) }.joined()
		return self.cacheDirectory.appendingPathComponent("\(self.fileDirectory)/\(self.filePrefix)\(hash)")
	}

	// MARK: - Fetch
	/// Fetch image from the network and cache it locally.
	///
	/// - Parameters:
	///    - url: The URL of the image.
	///
	/// - Returns: The downloaded image if successful, otherwise `nil`.
	func fetchImage(from url: URL?) async throws -> UIImage? {
		guard let url = url else { return nil }

		// If cached image exists, return it directly
		if let cachedImage = self.cachedImage(for: url) {
			return UIImage(data: cachedImage)
		}

		// Download image from URL
		let session = URLSession(configuration: .ephemeral)
		let (imageData, _) = try await session.data(from: url)

		guard let image = UIImage(data: imageData) else { return nil }

		// Spawn another task to cache the downloaded image
		Task {
			try? await self.cache(imageData, for: url)
			self.cleanupCache(olderThan: self.cacheLifetime) // 1 day
		}

		return image
	}

	/// Fetch a random cached image.
	func fetchRandomImage() -> UIImage? {
		let fileManager = FileManager.default
		guard let files = try? fileManager.contentsOfDirectory(
			at: self.cacheDirectory.appendingPathComponent(self.fileDirectory),
			includingPropertiesForKeys: nil,
			options: [.skipsHiddenFiles]
		) else { return nil }

		let cachedImages = files.filter { $0.lastPathComponent.hasPrefix(self.filePrefix) }
		guard !cachedImages.isEmpty else { return nil }

		guard
			let randomImageURL = cachedImages.randomElement(),
			let imageData = try? Data(contentsOf: randomImageURL)
		else { return nil }
		return UIImage(data: imageData)
	}

	// MARK: - Cache
	/// The cached image.
	///
	/// - Parameters:
	///    - url: The URL of the image.
	///
	/// - Returns: The cached image if available, otherwise `nil`.
	func cachedImage(for url: URL) -> Data? {
		guard let path = self.cachePath(for: url) else { return nil }
		return try? Data(contentsOf: path)
	}

	/// Whether a cached image is available.
	func cachedImageAvailable(for url: URL) -> Bool {
		guard let path = self.cachePath(for: url)?.path else { return false }
		return FileManager.default.fileExists(atPath: path)
	}

	/// Save the image locally.
	///
	/// - Parameters:
	///    - imageData: The data of the image.
	///	   - url: The URL of the image.
	private func cache(_ imageData: Data, for url: URL) async throws {
		guard let path = self.cachePath(for: url) else { return }
		try imageData.write(to: path, options: .atomic)
	}

	/// Cleanup cached images older than the specified time interval.
	///
	/// - Parameters:
	///    - seconds: The time interval in seconds.
	private func cleanupCache(olderThan seconds: TimeInterval) {
		let fileManager = FileManager.default
		guard let files = try? fileManager.contentsOfDirectory(
			at: self.cacheDirectory,
			includingPropertiesForKeys: [.contentModificationDateKey],
			options: [.skipsHiddenFiles]
		) else { return }

		let expirationDate = Date().addingTimeInterval(-seconds)

		for file in files where file.lastPathComponent.hasPrefix("kurozora-") {
			if let attrs = try? fileManager.attributesOfItem(atPath: file.path), let modified = attrs[.modificationDate] as? Date, modified < expirationDate {
				try? fileManager.removeItem(at: file)
			}
		}
	}
}
