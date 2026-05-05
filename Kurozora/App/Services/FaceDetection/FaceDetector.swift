//
//  FaceDetector.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import UIKit

/// A detected face's normalized focal point and the detector that produced it.
struct FaceDetectionResult {
	// MARK: - Properties
	/// The normalized focal point in image coordinates.
	let focalPoint: CGPoint

	/// The identifier of the detector that produced the result.
	let detectorIdentifier: String
}

/// A type that locates the most prominent face in an image.
protocol FaceDetector {
	/// The stable identifier of the detector.
	var identifier: String { get }

	/// Returns the highest-confidence face's bounding-box center in normalized image coordinates.
	///
	/// - Parameter image: The image to inspect.
	/// - Returns: The normalized focal point, or `nil` if no face was found.
	func detectFocalPoint(in image: UIImage) async -> CGPoint?
}
#endif
