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
		case saveFailed(Error)
	}

	static let shared: MediaSaverManager = MediaSaverManager()

	private init() {}

	/// Requests add-only access to the photo library.
	///
	/// - Returns: `true` if access was granted.
	private func requestAccess() async -> Bool {
		let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

		switch status {
		case .authorized, .limited:
			return true
		case .notDetermined:
			let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
			return newStatus == .authorized || newStatus == .limited
		default:
			return false
		}
	}

	/// Saves the image at the given URL to the photo library.
	///
	/// - Parameter url: The URL of the image to save.
	func saveImage(from url: URL) async throws {
		guard await self.requestAccess() else {
			throw SaverError.accessDenied
		}

		let image = try await self.downloadImage(from: url)
		try await self.performSave(image: image, originalURL: url)
	}

	/// Downloads the image at the given URL.
	///
	/// - Parameter url: The URL of the image to download.
	/// - Returns: The downloaded image.
	func downloadImage(from url: URL) async throws -> UIImage {
		let data: Data
		let response: URLResponse

		do {
			(data, response) = try await URLSession.shared.data(from: url)
		} catch {
			throw SaverError.downloadFailed
		}

		guard (response as? HTTPURLResponse)?.statusCode == 200,
		      let image = UIImage(data: data)
		else {
			throw SaverError.invalidData
		}

		return image
	}

	/// Saves the given image to the photo library.
	///
	/// - Parameters:
	///    - image: The image to save.
	///    - originalURL: The URL the image was downloaded from.
	private func performSave(image: UIImage, originalURL: URL) async throws {
		do {
			try await PHPhotoLibrary.shared().performChanges {
				PHAssetChangeRequest.creationRequestForAsset(from: image)
			}
		} catch {
			print("----- Initial save failed with error: \(error.localizedDescription)")

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
			try await PHPhotoLibrary.shared().performChanges {
				PHAssetChangeRequest.creationRequestForAsset(from: fallbackImage)
			}
		} catch {
			print("----- PNG conversion save failed with error: \(error.localizedDescription)")
			throw SaverError.saveFailed(error)
		}
	}
}
