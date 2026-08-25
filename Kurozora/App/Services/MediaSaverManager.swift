//
//  MediaSaverManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Photos
import UIKit

@MainActor
struct MediaSaverManager {
	enum SaverError: Error {
		case accessDenied
		case invalidData
		case downloadFailed
		case destinationUnavailable
		case saveFailed(Error)
	}

	static let shared: MediaSaverManager = MediaSaverManager()

	private init() {}

	/// Saves the image at the given URL to the destination chosen in Settings.
	///
	/// - Parameter url: The URL of the image to save.
	/// - Returns: The destination the image was written to.
	@discardableResult
	func saveImage(from url: URL) async throws -> MediaSaveDestination {
		switch MediaSaveDestination.current {
		case .photoLibrary:
			try await self.saveToPhotoLibrary(from: url)
			return .photoLibrary
		case .folder:
			try await self.saveToChosenFolder(from: url)
			return .folder
		}
	}

	/// Saves the images at the given URLs to the destination chosen in Settings.
	///
	/// - Parameter urls: The URLs of the images to save.
	/// - Returns: The destination the images were written to.
	@discardableResult
	func saveImages(from urls: [URL]) async throws -> MediaSaveDestination {
		var destination = MediaSaveDestination.current

		for url in urls {
			destination = try await self.saveImage(from: url)
		}

		return destination
	}

	/// Copies the image at the given URL to a temporary location.
	///
	/// - Parameter url: The URL of the image to copy.
	/// - Returns: The URL the image was written to.
	func stageImage(from url: URL) async throws -> URL {
		let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		return try await self.saveImage(from: url, to: directory)
	}

	/// Writes the image at the given URL into the given folder.
	///
	/// - Parameters:
	///    - url: The URL of the image to save.
	///    - directory: The folder to write into.
	/// - Returns: The URL the image was written to.
	@discardableResult
	func saveImage(from url: URL, to directory: URL) async throws -> URL {
		let data = try await self.downloadData(from: url)

		do {
			try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
		} catch {
			throw SaverError.saveFailed(error)
		}

		let destinationURL = self.availableURL(for: url, in: directory)

		do {
			try data.write(to: destinationURL, options: .atomic)
		} catch {
			throw SaverError.saveFailed(error)
		}

		return destinationURL
	}

	/// Downloads the image at the given URL.
	///
	/// - Parameter url: The URL of the image to download.
	/// - Returns: The downloaded image.
	func downloadImage(from url: URL) async throws -> UIImage {
		let data = try await self.downloadData(from: url)

		guard let image = UIImage(data: data) else {
			throw SaverError.invalidData
		}

		return image
	}

	/// Downloads the data at the given URL.
	///
	/// - Parameter url: The URL to download.
	/// - Returns: The downloaded data.
	func downloadData(from url: URL) async throws -> Data {
		let data: Data
		let response: URLResponse

		do {
			(data, response) = try await URLSession.shared.data(from: url)
		} catch {
			throw SaverError.downloadFailed
		}

		guard (response as? HTTPURLResponse)?.statusCode == 200 else {
			throw SaverError.invalidData
		}

		return data
	}

	/// Writes the image at the given URL into the folder chosen in Settings.
	///
	/// - Parameter url: The URL of the image to save.
	private func saveToChosenFolder(from url: URL) async throws {
		guard let directory = MediaSaveDestination.chosenDirectory else {
			throw SaverError.destinationUnavailable
		}

		let isAccessing = directory.startAccessingSecurityScopedResource()
		defer {
			if isAccessing {
				directory.stopAccessingSecurityScopedResource()
			}
		}

		try await self.saveImage(from: url, to: directory)
	}

	/// Saves the image at the given URL to the photo library.
	///
	/// - Parameter url: The URL of the image to save.
	private func saveToPhotoLibrary(from url: URL) async throws {
		let groupsIntoAlbum = UserSettings.mediaSaveToKurozoraAlbum

		guard await self.requestAccess(for: groupsIntoAlbum ? .readWrite : .addOnly) else {
			throw SaverError.accessDenied
		}

		let image = try await self.downloadImage(from: url)
		let album = groupsIntoAlbum ? await self.album(named: MediaSaveDestination.folderName) : nil

		try await self.performSave(image: image, originalURL: url, album: album)
	}

	/// Requests access to the photo library.
	///
	/// - Parameter level: The level of access to request.
	/// - Returns: `true` if access was granted.
	private func requestAccess(for level: PHAccessLevel) async -> Bool {
		let status = PHPhotoLibrary.authorizationStatus(for: level)

		switch status {
		case .authorized, .limited:
			return true
		case .notDetermined:
			let newStatus = await PHPhotoLibrary.requestAuthorization(for: level)
			return newStatus == .authorized || newStatus == .limited
		default:
			return false
		}
	}

	/// Saves the given image to the photo library.
	///
	/// - Parameters:
	///    - image: The image to save.
	///    - originalURL: The URL the image was downloaded from.
	///    - album: The album to add the image to.
	private func performSave(image: UIImage, originalURL: URL, album: PHAssetCollection?) async throws {
		do {
			try await self.createAsset(from: image, in: album)
		} catch {
			print("----- Initial save failed with error: \(error.localizedDescription)")

			if album != nil {
				try await self.performSave(image: image, originalURL: originalURL, album: nil)
				return
			}

			let type = UTType(filenameExtension: originalURL.pathExtension)

			if type == .webP {
				print("----- Detected WebP format. Retrying with PNG conversion.")
				try await self.retrySaveWithConversion(image: image)
			} else {
				throw SaverError.saveFailed(error)
			}
		}
	}

	/// Saves the given image to the photo library as PNG.
	///
	/// - Parameter image: The image to convert and save.
	private func retrySaveWithConversion(image: UIImage) async throws {
		guard let pngData = image.pngData(),
		      let fallbackImage = UIImage(data: pngData)
		else {
			throw SaverError.invalidData
		}

		do {
			try await self.createAsset(from: fallbackImage, in: nil)
		} catch {
			print("----- PNG conversion save failed with error: \(error.localizedDescription)")
			throw SaverError.saveFailed(error)
		}
	}

	/// Creates a photo library asset from the given image.
	///
	/// - Parameters:
	///    - image: The image to create an asset from.
	///    - album: The album to add the asset to.
	private func createAsset(from image: UIImage, in album: PHAssetCollection?) async throws {
		try await PHPhotoLibrary.shared().performChanges {
			let request = PHAssetChangeRequest.creationRequestForAsset(from: image)

			guard
				let album = album,
				let placeholder = request.placeholderForCreatedAsset,
				let albumRequest = PHAssetCollectionChangeRequest(for: album)
			else {
				return
			}

			albumRequest.addAssets([placeholder] as NSFastEnumeration)
		}
	}

	/// Returns the album with the given name, creating it when it doesn't exist yet.
	///
	/// - Parameter name: The name of the album.
	/// - Returns: The matching album.
	private func album(named name: String) async -> PHAssetCollection? {
		let options = PHFetchOptions()
		options.predicate = NSPredicate(format: "title = %@", name)

		let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
		if let existingAlbum = albums.firstObject {
			return existingAlbum
		}

		var identifier: String?

		do {
			try await PHPhotoLibrary.shared().performChanges {
				let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
				identifier = request.placeholderForCreatedAssetCollection.localIdentifier
			}
		} catch {
			print("----- Could not create the album with error: \(error.localizedDescription)")
			return nil
		}

		guard let identifier = identifier else { return nil }
		return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier], options: nil).firstObject
	}

	/// Returns a URL inside the given folder that no file occupies yet.
	///
	/// - Parameters:
	///    - url: The URL the image was downloaded from.
	///    - directory: The folder to write into.
	/// - Returns: An unoccupied URL.
	private func availableURL(for url: URL, in directory: URL) -> URL {
		let name = url.deletingPathExtension().lastPathComponent
		let baseName = name.isEmpty ? "Image" : name
		let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension

		var candidate = directory.appendingPathComponent("\(baseName).\(fileExtension)")
		var suffix = 2

		while FileManager.default.fileExists(atPath: candidate.path) {
			candidate = directory.appendingPathComponent("\(baseName) \(suffix).\(fileExtension)")
			suffix += 1
		}

		return candidate
	}
}
