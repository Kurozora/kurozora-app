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

	/// Requests access to the photo library with `.addOnly` permissions.
	///
	/// - Returns: A boolean indicating whether access was granted or not.
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

	/// Saves the image from the given URL to the photo library, after checking for necessary permissions.
	///
	/// - Parameter url: The URL of the image to be saved.
	func saveImage(from url: URL) async throws {
		guard await self.requestAccess() else {
			throw SaverError.accessDenied
		}

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

		try await self.performSave(image: image, originalURL: url)
	}

	/// Performs the actual save operation to the photo library, and retries with a PNG conversion if it encounters specific errors that may indicate compatibility issues.
	///
	/// - Parameter image: The `UIImage` to be saved to the photo library.
	private func performSave(image: UIImage, originalURL: URL) async throws {
		do {
			try await PHPhotoLibrary.shared().performChanges {
				PHAssetChangeRequest.creationRequestForAsset(from: image)
			}
		} catch {
			print("----- Initial save failed with error: \(error.localizedDescription)")

			let type = UTType(filenameExtension: originalURL.pathExtension)

			if type == .webP {
				print("----- Detected WebP format. Retrying with PNG conversion...")
				try await self.retrySaveWithConversion(image: image)
			} else {
				throw SaverError.saveFailed(error)
			}
		}
	}

	/// Retries saving the image after converting it to PNG format, which can help bypass certain compatibility issues.
	///
	/// - Parameter image: The original `UIImage` that failed to save, which will be converted to PNG format for the retry attempt.
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
