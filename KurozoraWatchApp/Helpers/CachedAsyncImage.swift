//
//  CachedAsyncImage.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CryptoKit
import SwiftUI

/// A SwiftUI view that loads and caches images from a URL using SHA256-based disk caching.
struct CachedAsyncImage<Placeholder: View>: View {
	// MARK: - Properties
	let url: URL?
	let placeholder: () -> Placeholder

	@State private var image: Image?
	@State private var isLoading = false

	// MARK: - Constants
	private static var fileDirectory: String {
		"widget-watch"
	}

	private static var filePrefix: String {
		"kurozora-"
	}

	private static var cacheLifetime: TimeInterval {
		43200 // 12 hours
	}

	// MARK: - Body
	var body: some View {
		Group {
			if let image = image {
				image
					.resizable()
					.aspectRatio(contentMode: .fill)
			} else {
				self.placeholder()
			}
		}
		.task(id: self.url) {
			await self.loadImage()
		}
	}

	// MARK: - Functions
	private func loadImage() async {
		guard !self.isLoading, let url = url else { return }
		self.isLoading = true
		defer { isLoading = false }

		// Check disk cache
		if let cachedData = Self.cachedImage(for: url),
		   let uiImage = platformImage(from: cachedData)
		{
			self.image = Image(uiImage: uiImage)
			return
		}

		// Download
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			guard let uiImage = platformImage(from: data) else { return }
			self.image = Image(uiImage: uiImage)

			// Cache in background
			Task.detached {
				await Self.cache(data, for: url)
				await Self.cleanupCache(olderThan: Self.cacheLifetime)
			}
		} catch {
			NSLog("CachedAsyncImage fetch failed: %@", error.localizedDescription)
		}
	}

	private func platformImage(from data: Data) -> WKImage? {
		return WKImage(data: data)
	}

	// MARK: - Cache
	private static var cacheDirectory: URL {
		.cachesDirectory
	}

	private static func cachePath(for url: URL) -> URL {
		let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
			.map { String(format: "%02x", $0) }
			.joined()
		return self.cacheDirectory.appendingPathComponent("\(self.fileDirectory)/\(self.filePrefix)\(hash)")
	}

	private static func cachedImage(for url: URL) -> Data? {
		let path = self.cachePath(for: url)
		return try? Data(contentsOf: path)
	}

	private static func cache(_ data: Data, for url: URL) {
		let directory = self.cacheDirectory.appendingPathComponent(self.fileDirectory)
		if !FileManager.default.fileExists(atPath: directory.path) {
			try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
		}
		let path = self.cachePath(for: url)
		try? data.write(to: path, options: .atomic)
	}

	private static func cleanupCache(olderThan seconds: TimeInterval) {
		let fileManager = FileManager.default
		let directory = self.cacheDirectory.appendingPathComponent(self.fileDirectory)
		guard let files = try? fileManager.contentsOfDirectory(
			at: directory,
			includingPropertiesForKeys: [.contentModificationDateKey],
			options: [.skipsHiddenFiles]
		) else { return }

		let expirationDate = Date().addingTimeInterval(-seconds)
		for file in files where file.lastPathComponent.hasPrefix(self.filePrefix) {
			if let attrs = try? fileManager.attributesOfItem(atPath: file.path),
			   let modified = attrs[.modificationDate] as? Date,
			   modified < expirationDate
			{
				try? fileManager.removeItem(at: file)
			}
		}
	}
}

// MARK: - watchOS Image Wrapper
/// Lightweight wrapper to decode image data on watchOS using CoreGraphics.
private struct WKImage {
	let cgImage: CGImage

	init?(data: Data) {
		guard let provider = CGDataProvider(data: data as CFData),
		      let image = CGImage(
		      	jpegDataProviderSource: provider,
		      	decode: nil,
		      	shouldInterpolate: true,
		      	intent: .defaultIntent
		      ) ?? CGImage(
		      	pngDataProviderSource: provider,
		      	decode: nil,
		      	shouldInterpolate: true,
		      	intent: .defaultIntent
		      )
		else {
			return nil
		}
		self.cgImage = image
	}
}

private extension Image {
	init(uiImage: WKImage) {
		self.init(decorative: uiImage.cgImage, scale: 2.0)
	}
}

// MARK: - Convenience Initializer
extension CachedAsyncImage where Placeholder == Color {
	init(url: URL?) {
		self.url = url
		self.placeholder = { Color.gray.opacity(0.3) }
	}
}

extension CachedAsyncImage where Placeholder == AnyView {
	init(url: String?, placeholder: @escaping () -> some View) {
		if let urlString = url, let parsed = URL(string: urlString) {
			self.url = parsed
		} else {
			self.url = nil
		}
		self.placeholder = { AnyView(placeholder()) }
	}
}
