//
//  ChainedFaceDetector.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import UIKit

/// A face detector that tries a primary detector first and falls through to a fallback.
final class ChainedFaceDetector {
	// MARK: - Properties
	/// The identifier of the primary detector. Used as the dedup key so a failed primary doesn't keep retrying every session.
	let primaryIdentifier: String

	private let primary: FaceDetector
	private let fallback: FaceDetector

	// MARK: - Initializers
	/// Creates a chain that prefers `primary` and falls back to `fallback`.
	///
	/// - Parameters:
	///   - primary: The detector tried first.
	///   - fallback: The detector tried when the primary returns `nil`.
	init(primary: FaceDetector, fallback: FaceDetector) {
		self.primary = primary
		self.fallback = fallback
		self.primaryIdentifier = primary.identifier
	}

	// MARK: - Functions
	/// Returns the focal point of the most prominent face along with the detector that produced it.
	///
	/// - Parameter image: The image to inspect.
	/// - Returns: The detection result, or `nil` if both detectors found no face.
	func detect(in image: UIImage) async -> FaceDetectionResult? {
		if let primaryFocalPoint = await self.primary.detectFocalPoint(in: image) {
			return FaceDetectionResult(focalPoint: primaryFocalPoint, detectorIdentifier: self.primary.identifier)
		}

		if let fallbackFocalPoint = await self.fallback.detectFocalPoint(in: image) {
			return FaceDetectionResult(focalPoint: fallbackFocalPoint, detectorIdentifier: self.fallback.identifier)
		}

		return nil
	}
}
#endif
