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
	static func fetchMetadata(for url: URL) async -> LPLinkMetadata? {
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

	static func cachedMetadata(for url: URL) -> LPLinkMetadata? {
		// Load cached metadata from disk if available
		if let cacheURL = cacheFileURL(for: url),
		   FileManager.default.fileExists(atPath: cacheURL.path),
		   let data = try? Data(contentsOf: cacheURL),
		   let metadata = try? NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data) {
			return metadata
		}
		return nil
	}

	private static func cache(_ metadata: LPLinkMetadata, for url: URL) {
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

	private static func cacheFileURL(for url: URL) -> URL? {
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
}
