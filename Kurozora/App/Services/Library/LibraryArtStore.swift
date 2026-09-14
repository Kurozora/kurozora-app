//
//  LibraryArtStore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CryptoKit
import Foundation
import ImageIO
import os.log
import UIKit
import UniformTypeIdentifiers
import UserNotifications

private nonisolated let artStoreLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibraryArtStore")

actor LibraryArtStore {
	// MARK: - Properties
	/// Returns the singleton `LibraryArtStore` instance.
	static let shared = LibraryArtStore()

	/// The longest edge stored art is downsampled to, in pixels.
	private static let maxPixelSize: CGFloat = 800.0

	/// The lossy compression quality of stored art.
	private static let compressionQuality: CGFloat = 0.75

	/// The image types a notification attachment accepts.
	private static let attachableTypeIdentifiers: Set<String> = [
		UTType.jpeg.identifier,
		UTType.png.identifier,
		UTType.gif.identifier
	]

	/// The maximum number of concurrent downloads per prefetch call.
	private let downloadConcurrency: Int = 4

	/// URLs currently downloading.
	private var inFlightURLStrings: Set<String> = []

	// MARK: - Initializers
	private init() {}

	// MARK: - Read
	/// Returns the on-disk location of stored art for the given URL.
	///
	/// - Parameter urlString: The source URL of the art.
	static func storedFileURL(forURLString urlString: String) -> URL? {
		guard !urlString.isEmpty,
		      let fileURL = try? Self.fileURL(forURLString: urlString, creatingDirectory: false),
		      FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
		return fileURL
	}

	/// Returns a notification attachment carrying the first of the given URLs that is stored.
	///
	/// - Parameter urlStrings: The source URLs of the art, most specific first.
	///
	/// - Returns: The attachment a notification shows.
	func notificationAttachment(forURLStrings urlStrings: [String]) -> UNNotificationAttachment? {
		for urlString in urlStrings {
			if let attachment = self.notificationAttachment(forURLString: urlString) {
				return attachment
			}
		}

		return nil
	}

	/// Returns a notification attachment carrying the stored art for the given URL.
	///
	/// - Parameter urlString: The source URL of the art.
	///
	/// - Returns: The attachment a notification shows.
	func notificationAttachment(forURLString urlString: String?) -> UNNotificationAttachment? {
		guard let urlString = urlString, !urlString.isEmpty else { return nil }

		guard let fileURL = Self.storedFileURL(forURLString: urlString) else {
			artStoreLogger.error("Art is not stored: \(urlString, privacy: .public)")
			return nil
		}

		// The system takes ownership of the file it is handed.
		guard let attachable = Self.attachableCopy(of: fileURL) else {
			artStoreLogger.error("Art is not attachable: \(urlString, privacy: .public)")
			return nil
		}

		do {
			return try UNNotificationAttachment(
				identifier: urlString,
				url: attachable.url,
				options: [UNNotificationAttachmentOptionsTypeHintKey: attachable.typeIdentifier]
			)
		} catch {
			try? FileManager.default.removeItem(at: attachable.url)
			artStoreLogger.error("Attaching art failed: \(error.localizedDescription)")
			return nil
		}
	}

	/// Returns the total size of the stored art in bytes.
	func totalSizeBytes() -> Int64 {
		guard let directoryURL = try? Self.directoryURL(creatingDirectory: false) else { return 0 }
		guard let fileURLs = try? FileManager.default.contentsOfDirectory(
			at: directoryURL,
			includingPropertiesForKeys: [.fileSizeKey],
			options: .skipsHiddenFiles
		) else { return 0 }

		return fileURLs.reduce(Int64(0)) { totalSize, fileURL in
			let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
			return totalSize + Int64(fileSize)
		}
	}

	// MARK: - Prefetch
	/// Downloads, downsamples, and stores every missing image among the given URLs.
	///
	/// - Parameter urlStrings: The source URLs to prefetch. Already-stored URLs are skipped.
	func prefetch(_ urlStrings: [String]) async {
		let missingURLStrings = Array(Set(urlStrings)).filter { urlString in
			guard !urlString.isEmpty, !self.inFlightURLStrings.contains(urlString) else { return false }
			return Self.storedFileURL(forURLString: urlString) == nil
		}
		guard !missingURLStrings.isEmpty else { return }

		self.inFlightURLStrings.formUnion(missingURLStrings)
		defer { self.inFlightURLStrings.subtract(missingURLStrings) }

		await withTaskGroup(of: Void.self) { group in
			var nextIndex = 0

			while nextIndex < min(self.downloadConcurrency, missingURLStrings.count) {
				let urlString = missingURLStrings[nextIndex]
				group.addTask { await Self.downloadAndStore(urlString) }
				nextIndex += 1
			}

			for await _ in group {
				guard nextIndex < missingURLStrings.count else { continue }
				let urlString = missingURLStrings[nextIndex]
				group.addTask { await Self.downloadAndStore(urlString) }
				nextIndex += 1
			}
		}
	}

	// MARK: - Delete
	/// Removes stored art whose source URL is not in the given set.
	///
	/// - Parameter keepingURLStrings: The source URLs of art that stays.
	func prune(keepingURLStrings: Set<String>) {
		guard let directoryURL = try? Self.directoryURL(creatingDirectory: false) else { return }
		guard let fileURLs = try? FileManager.default.contentsOfDirectory(
			at: directoryURL,
			includingPropertiesForKeys: nil,
			options: .skipsHiddenFiles
		) else { return }

		let validFileNames = Set(keepingURLStrings.map { Self.fileName(forURLString: $0) })

		for fileURL in fileURLs where !validFileNames.contains(fileURL.lastPathComponent) {
			try? FileManager.default.removeItem(at: fileURL)
		}
	}

	/// Removes the stored art for the given source URLs.
	///
	/// - Parameter urlStrings: The source URLs of the art to delete.
	func remove(urlStrings: Set<String>) {
		guard let directoryURL = try? Self.directoryURL(creatingDirectory: false) else { return }

		for urlString in urlStrings where !urlString.isEmpty {
			let fileURL = directoryURL.appendingPathComponent(Self.fileName(forURLString: urlString), isDirectory: false)
			try? FileManager.default.removeItem(at: fileURL)
		}
	}

	/// Removes every stored image.
	func removeAll() {
		guard let directoryURL = try? Self.directoryURL(creatingDirectory: false) else { return }
		try? FileManager.default.removeItem(at: directoryURL)
	}

	// MARK: - Helpers
	private static func downloadAndStore(_ urlString: String) async {
		guard let sourceURL = URL(string: urlString) else { return }

		do {
			let (imageData, response) = try await URLSession.shared.data(from: sourceURL)
			if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 400 {
				return
			}
			guard let storableData = Self.storableArtData(from: imageData) else { return }

			let fileURL = try Self.fileURL(forURLString: urlString, creatingDirectory: true)
			try storableData.write(to: fileURL, options: .atomic)
		} catch {
			artStoreLogger.error("Prefetch failed: \(error.localizedDescription)")
		}
	}

	/// Returns the image data to store, keeping the original bytes when they're already small and within ``maxPixelSize``.
	private static func storableArtData(from sourceData: Data) -> Data? {
		let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
		guard let imageSource = CGImageSourceCreateWithData(sourceData as CFData, sourceOptions) else { return nil }

		let thumbnailOptions = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceCreateThumbnailWithTransform: true,
			kCGImageSourceShouldCacheImmediately: true,
			kCGImageSourceThumbnailMaxPixelSize: Self.maxPixelSize
		] as CFDictionary
		guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions) else { return nil }
		guard let encodedData = Self.encodedArtData(from: downsampledImage) else { return nil }

		if Self.isWithinMaxPixelSize(imageSource), sourceData.count < encodedData.count {
			return sourceData
		}
		return encodedData
	}

	/// Returns whether the image source's longest edge is already within ``maxPixelSize``.
	private static func isWithinMaxPixelSize(_ imageSource: CGImageSource) -> Bool {
		guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
		      let pixelWidth = properties[kCGImagePropertyPixelWidth] as? CGFloat,
		      let pixelHeight = properties[kCGImagePropertyPixelHeight] as? CGFloat else { return false }
		return max(pixelWidth, pixelHeight) <= Self.maxPixelSize
	}

	/// Returns the image encoded as HEIC, falling back to JPEG when HEIC encoding is unavailable.
	private static func encodedArtData(from image: CGImage) -> Data? {
		if let heicData = Self.heicData(from: image) {
			return heicData
		}
		return UIImage(cgImage: image).jpegData(compressionQuality: Self.compressionQuality)
	}

	/// Returns the image encoded as HEIC at ``compressionQuality``.
	private static func heicData(from image: CGImage) -> Data? {
		let mutableData = NSMutableData()
		guard let destination = CGImageDestinationCreateWithData(mutableData, UTType.heic.identifier as CFString, 1, nil) else { return nil }

		let destinationOptions = [kCGImageDestinationLossyCompressionQuality: Self.compressionQuality] as CFDictionary
		CGImageDestinationAddImage(destination, image, destinationOptions)
		guard CGImageDestinationFinalize(destination) else { return nil }

		return mutableData as Data
	}

	/// Returns a temporary copy of the stored art in a type a notification accepts.
	///
	/// - Parameter fileURL: The stored art to copy.
	///
	/// - Returns: The copy's location and uniform type identifier.
	private static func attachableCopy(of fileURL: URL) -> (url: URL, typeIdentifier: String)? {
		guard let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil) else { return nil }
		let sourceType = CGImageSourceGetType(imageSource) as String?

		if let sourceType = sourceType, Self.attachableTypeIdentifiers.contains(sourceType),
		   let fileExtension = UTType(sourceType)?.preferredFilenameExtension,
		   let destinationURL = Self.temporaryURL(withExtension: fileExtension),
		   (try? FileManager.default.copyItem(at: fileURL, to: destinationURL)) != nil {
			return (destinationURL, sourceType)
		}

		guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else { return nil }
		guard let jpegData = UIImage(cgImage: image).jpegData(compressionQuality: Self.compressionQuality) else { return nil }
		guard let destinationURL = Self.temporaryURL(withExtension: "jpg") else { return nil }
		guard (try? jpegData.write(to: destinationURL, options: .atomic)) != nil else { return nil }

		return (destinationURL, UTType.jpeg.identifier)
	}

	private static func temporaryURL(withExtension fileExtension: String) -> URL? {
		return FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString, isDirectory: false)
			.appendingPathExtension(fileExtension)
	}

	private static func fileName(forURLString urlString: String) -> String {
		let digest = SHA256.hash(data: Data(urlString.utf8))
		return digest.map { String(format: "%02x", $0) }.joined() + ".img"
	}

	private static func fileURL(forURLString urlString: String, creatingDirectory: Bool) throws -> URL {
		let directoryURL = try Self.directoryURL(creatingDirectory: creatingDirectory)
		return directoryURL.appendingPathComponent(Self.fileName(forURLString: urlString), isDirectory: false)
	}

	private static func directoryURL(creatingDirectory: Bool) throws -> URL {
		let applicationSupportURL = try FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: creatingDirectory
		)
		var directoryURL = applicationSupportURL.appendingPathComponent("LibraryArt", isDirectory: true)

		if creatingDirectory, !FileManager.default.fileExists(atPath: directoryURL.path) {
			try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

			// The store is re-downloadable; keep it out of device backups.
			var resourceValues = URLResourceValues()
			resourceValues.isExcludedFromBackup = true
			try? directoryURL.setResourceValues(resourceValues)
		}

		return directoryURL
	}
}
