//
//  RichLink.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import CryptoKit
import LinkPresentation

@MainActor
class RichLink {
	// MARK: - Properties
	/// The shared instance of `RichLink`.
	static let shared = RichLink()

	/// In-memory cache for fast lookup during scrolling.
	private let memoryCache = NSCache<NSString, LPLinkMetadata>()

	/// Time-to-live for cached metadata. Defaults to 7 days.
	var cacheTTL: TimeInterval = 7 * 24 * 60 * 60

	/// The subdirectory name used to isolate rich link cache files.
	private let cacheSubdirectory = "richlink-cache"

	// MARK: - Initializers
	private init() {
		let notifications: [(Notification.Name, Selector)]
		#if !os(macOS) && !os(watchOS)
		notifications = [
			(UIApplication.didReceiveMemoryWarningNotification, #selector(self.clearMemoryCache)),
			(UIApplication.willTerminateNotification, #selector(self.cleanExpiredCache)),
			(UIApplication.didEnterBackgroundNotification, #selector(self.backgroundCleanExpiredDiskCache))
		]
		#elseif os(macOS)
		notifications = [
			(NSApplication.willResignActiveNotification, #selector(self.cleanExpiredCache))
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
		if let cachedMetadata = cachedMetadata(for: url) {
			return cachedMetadata
		}

		let provider = LPMetadataProvider()
		do {
			let metadata = try await provider.startFetchingMetadata(for: url)
			self.cache(metadata, for: url)
			return metadata
		} catch {
			print("Failed to fetch metadata for URL: \(url.absoluteString), error: \(error.localizedDescription)")
			return nil
		}
	}

	/// Returns the cached `LPLinkMetadata` object for the given URL if available.
	///
	/// Checks the in-memory cache first, then falls back to disk. Validates TTL
	/// on disk hits and evicts stale entries.
	///
	/// - Parameters:
	///    - url: The URL for which to retrieve the `LPLinkMetadata` object.
	func cachedMetadata(for url: URL) -> LPLinkMetadata? {
		let key = url.absoluteString as NSString

		// L1: in-memory cache
		if let metadata = memoryCache.object(forKey: key) {
			return metadata
		}

		// L2: disk cache with TTL validation
		guard let cacheURL = cacheFileURL(for: url) else { return nil }
		let metaURL = cacheURL.deletingPathExtension().appendingPathExtension("meta")

		guard FileManager.default.fileExists(atPath: cacheURL.path) else { return nil }

		// Validate TTL via sidecar
		guard let timestamp = readTimestamp(from: metaURL) else {
			// Orphaned .cache file without .meta — treat as miss, clean up
			try? FileManager.default.removeItem(at: cacheURL)
			return nil
		}

		if Date().timeIntervalSince1970 - timestamp > cacheTTL {
			// Expired — evict both files
			try? FileManager.default.removeItem(at: cacheURL)
			try? FileManager.default.removeItem(at: metaURL)
			return nil
		}

		// Decode and promote to L1
		guard let data = try? Data(contentsOf: cacheURL),
			  let metadata = try? NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data) else {
			// Corrupted — clean up
			try? FileManager.default.removeItem(at: cacheURL)
			try? FileManager.default.removeItem(at: metaURL)
			return nil
		}

		memoryCache.setObject(metadata, forKey: key)
		return metadata
	}

	/// Caches an `LPLinkMetadata` object to disk and in-memory.
	///
	/// - Parameters:
	///   - metadata: An `LPLinkMetadata` object to cache.
	///   - url: The URL associated with the metadata.
	private func cache(_ metadata: LPLinkMetadata, for url: URL) {
		let key = url.absoluteString as NSString

		// L1: in-memory
		memoryCache.setObject(metadata, forKey: key)

		// L2: disk
		guard let cacheURL = cacheFileURL(for: url) else { return }
		guard let data = try? NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: false) else { return }

		do {
			try data.write(to: cacheURL)
			// Write timestamp sidecar after .cache succeeds
			let metaURL = cacheURL.deletingPathExtension().appendingPathExtension("meta")
			writeTimestamp(Date().timeIntervalSince1970, to: metaURL)
		} catch {
			print("Failed to write cached metadata to disk: \(error.localizedDescription)")
		}
	}

	/// Returns the total size of cached rich link files in bytes.
	nonisolated func cacheSize() -> UInt {
		guard let cacheDirectory = self.cacheDirectoryURL() else { return 0 }
		guard FileManager.default.fileExists(atPath: cacheDirectory.path) else { return 0 }

		let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
		var totalSize: UInt = 0

		while let fileURL = enumerator?.nextObject() as? URL {
			let fileSize = UInt((try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
			totalSize += fileSize
		}

		return totalSize
	}

	/// Clears all rich link cached files from disk and in-memory.
	func clearCache() {
		memoryCache.removeAllObjects()

		guard let cacheDirectory = self.cacheDirectoryURL() else { return }
		try? FileManager.default.removeItem(at: cacheDirectory)
	}

	/// Clears only the in-memory cache. Disk cache is preserved.
	@objc private func clearMemoryCache() {
		memoryCache.removeAllObjects()
	}

	/// Cleans expired files from the disk cache based on TTL, then enforces the size ceiling.
	@objc func cleanExpiredCache() {
		guard let cacheDirectory = self.cacheDirectoryURL() else { return }
		guard FileManager.default.fileExists(atPath: cacheDirectory.path) else { return }

		let fileManager = FileManager.default
		guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]) else { return }

		let now = Date().timeIntervalSince1970

		// Pass 1: TTL eviction
		let cacheFiles = files.filter { $0.pathExtension == "cache" }
		for cacheFile in cacheFiles {
			let metaFile = cacheFile.deletingPathExtension().appendingPathExtension("meta")

			guard let timestamp = readTimestamp(from: metaFile) else {
				// Orphaned .cache — remove
				try? fileManager.removeItem(at: cacheFile)
				continue
			}

			if now - timestamp > cacheTTL {
				try? fileManager.removeItem(at: cacheFile)
				try? fileManager.removeItem(at: metaFile)
			}
		}

		// Pass 2: Size ceiling (50 MB)
		let maxCacheSize: UInt = 50 * 1024 * 1024
		let currentSize = cacheSize()

		guard currentSize > maxCacheSize else { return }

		// Re-enumerate after TTL pass
		guard let remainingFiles = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else { return }

		// Sort .meta files by timestamp (oldest first) to evict oldest entries
		let metaFiles = remainingFiles.filter { $0.pathExtension == "meta" }
		let sortedByAge = metaFiles.compactMap { metaFile -> (meta: URL, cache: URL, timestamp: TimeInterval)? in
			guard let timestamp = readTimestamp(from: metaFile) else { return nil }
			let cacheFile = metaFile.deletingPathExtension().appendingPathExtension("cache")
			return (metaFile, cacheFile, timestamp)
		}.sorted { $0.timestamp < $1.timestamp }

		var sizeFreed: UInt = 0
		for entry in sortedByAge {
			if currentSize - sizeFreed <= maxCacheSize { break }
			let fileSize = UInt((try? entry.cache.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
			try? fileManager.removeItem(at: entry.cache)
			try? fileManager.removeItem(at: entry.meta)
			sizeFreed += fileSize
		}
	}

	// MARK: - Private Helpers

	/// Returns the isolated cache directory URL, creating it if needed.
	///
	/// This is `nonisolated` so it can be used from `cacheSize()`.
	private nonisolated func cacheDirectoryURL() -> URL? {
		guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
			return nil
		}

		let directory = cachesDirectory.appendingPathComponent(cacheSubdirectory)
		try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
		return directory
	}

	/// Returns the local file URL of the cached metadata for the given URL.
	private nonisolated func cacheFileURL(for url: URL) -> URL? {
		guard let cacheDirectory = self.cacheDirectoryURL() else { return nil }

		guard let data = url.absoluteString.data(using: .utf8) else { return nil }

		let hash = SHA256.hash(data: data)
		let fileName = hash.compactMap { digest in
			return String(format: "%02x", digest)
		}.joined()
		return cacheDirectory.appendingPathComponent(fileName).appendingPathExtension("cache")
	}

	/// Writes a timestamp to a sidecar file.
	private nonisolated func writeTimestamp(_ timestamp: TimeInterval, to url: URL) {
		var value = timestamp
		let data = Data(bytes: &value, count: MemoryLayout<TimeInterval>.size)
		try? data.write(to: url)
	}

	/// Reads a timestamp from a sidecar file.
	private nonisolated func readTimestamp(from url: URL) -> TimeInterval? {
		guard let data = try? Data(contentsOf: url),
			  data.count == MemoryLayout<TimeInterval>.size else { return nil }
		return data.withUnsafeBytes { $0.load(as: TimeInterval.self) }
	}

	#if !os(macOS) && !os(watchOS)
	/// Cleans expired caches from disk storage when the app is in the background.
	@objc private func backgroundCleanExpiredDiskCache() {
		let sharedApplication = UIApplication.shared
		var backgroundTask: UIBackgroundTaskIdentifier = .invalid
		backgroundTask = sharedApplication.beginBackgroundTask(withName: "Kurozora:backgroundCleanExpiredCache") {
			sharedApplication.endBackgroundTask(backgroundTask)
			backgroundTask = .invalid
		}

		Task.detached(priority: .utility) { [weak self] in
			await self?.cleanExpiredCache()
			sharedApplication.endBackgroundTask(backgroundTask)
			backgroundTask = .invalid
		}
	}
	#endif
}
