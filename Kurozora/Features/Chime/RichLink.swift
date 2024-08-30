//
//  RichLink.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import CryptoKit
import LinkPresentation

class RichLink {
	// MARK: - Properties
	/// The shared instance of `RichLink`.
	public static let shared = RichLink()

	// MARK: - Initializers
	private init() {
		let notifications: [(Notification.Name, Selector)]
		#if !os(macOS) && !os(watchOS)
		notifications = [
			(UIApplication.didReceiveMemoryWarningNotification, #selector(clearCache)),
			(UIApplication.willTerminateNotification, #selector(clearCache)),
			(UIApplication.didEnterBackgroundNotification, #selector(backgroundCleanExpiredDiskCache))
		]
		#elseif os(macOS)
		notifications = [
			(NSApplication.willResignActiveNotification, #selector(cleanExpiredCache))
		]
		#else
		notifications = []
		#endif
		notifications.forEach {
			NotificationCenter.default.addObserver(self, selector: $0.1, name: $0.0, object: nil)
		}
	}

	// MARK: - Functions
	/// Fetches the `LPLinkMetadata` object from cache for the given URL if available,
	/// otherwise creates a new `LPLinkMetadata` object from the URL and caches the
	/// result.
	///
	/// - Parameters:
	///    - url: The URL of the metadata.
	///
	/// - Returns: The cached `LPLinkMetadata` object.
	func fetchMetadata(for url: URL) async -> LPLinkMetadata? {
		// Check if the metadata is already cached
		if let cachedMetadata = cachedMetadata(for: url) {
			return cachedMetadata
		}

		// Fetch metadata from the network
		let provider = LPMetadataProvider()
		do {
			let metadata = try await provider.startFetchingMetadata(for: url)
			// Cache the fetched metadata
			self.cache(metadata, for: url)
			return metadata
		} catch {
			// Handle error
			print("Failed to fetch metadata for URL: \(url.absoluteString), error: \(error.localizedDescription)")
			return nil
		}
	}

	/// Returns the cached `LPLinkMetadata` object for the given URL if available.
	///
	/// - Parameters:
	///    - url: The URL for which to retrieve the `LPLinkMetadata` object.
	func cachedMetadata(for url: URL) -> LPLinkMetadata? {
		// Load cached metadata from disk if available
		if let cacheURL = cacheFileURL(for: url),
		   FileManager.default.fileExists(atPath: cacheURL.path),
		   let data = try? Data(contentsOf: cacheURL),
		   let metadata = try? NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data) {
			return metadata
		}
		return nil
	}

	/// Caches an `LPLinkMetadata` object to disk.
	///
	/// - Parameters:
	///   - metadata: An `LPLinkMetadata` object to cache.
	private func cache(_ metadata: LPLinkMetadata, for url: URL) {
		// Archive metadata and save it to disk
		if let cacheURL = cacheFileURL(for: url),
		   let data = try? NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: false) {
			do {
				try data.write(to: cacheURL)
			} catch {
				print("Failed to write cached metadata to disk: \(error.localizedDescription)")
			}
		}
	}

	/// Returns the local file URL of the cached metadata for the given URL.
	///
	/// - Parameters:
	///    - url: The URL of the metadata.
	///
	/// - Returns: The file URL of the cached metadata.
	private func cacheFileURL(for url: URL) -> URL? {
		// Get the URL for the application's private data directory
		guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
			return nil
		}

		// Generate a unique file URL based on the URL string
		guard let data = url.absoluteString.data(using: .utf8) else {
			return nil
		}

		let hash = SHA256.hash(data: data)
		let fileName = hash.compactMap { digest in
			return String(format: "%02x", digest)
		}.joined()
		return cacheDirectory.appendingPathComponent(fileName)
	}

	/// Returns the total size of cached files in the app's cache directory in bytes.
	func cacheSize() -> UInt {
		guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
			return 0
		}

		let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
		var totalSize: UInt = 0

		while let fileURL = enumerator?.nextObject() as? URL {
			let fileSize: UInt = UInt((try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
			totalSize += fileSize
		}

		return totalSize
	}

	/// Clear the cache by removing all files in the cache directory.
	@objc func clearCache() {
		guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
			return
		}

		let fileManager = FileManager.default
		if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
			for file in files {
				try? fileManager.removeItem(at: file)
			}
		}
	}

	/// Cleans the expired files from the disk cache.
	@objc private func cleanExpiredCache() {
		let maxCacheSize: UInt = 50 * 1024 * 1024
		let currentCacheSize = self.cacheSize()

		if currentCacheSize > maxCacheSize {
			guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
				return
			}

			let fileManager = FileManager.default
			if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) {
				let sortedFiles = files.sorted { file1, file2 in
					let date1 = (try? file1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
					let date2 = (try? file2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
					return date1 < date2
				}

				var sizeFreed: UInt = 0
				for file in sortedFiles {
					if currentCacheSize - sizeFreed <= maxCacheSize {
						break
					}
					let fileSize = UInt((try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
					try? fileManager.removeItem(at: file)
					sizeFreed += fileSize
				}
			}
		}
	}

	#if !os(macOS) && !os(watchOS)
	/// Clears the expired caches from disk storage when the app is in the background.
	@objc private func backgroundCleanExpiredDiskCache() {
		let sharedApplication = UIApplication.shared

		func endBackgroundTask(_ task: inout UIBackgroundTaskIdentifier) {
			sharedApplication.endBackgroundTask(task)
			task = UIBackgroundTaskIdentifier.invalid
		}

		var backgroundTask: UIBackgroundTaskIdentifier!
		backgroundTask = sharedApplication.beginBackgroundTask(withName: "Kurozora:backgroundCleanExpiredCache") {
			endBackgroundTask(&backgroundTask!)
		}

		self.cleanExpiredCache()
		endBackgroundTask(&backgroundTask!)
	}
	#endif
}
