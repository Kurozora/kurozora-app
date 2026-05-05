//
//  FaceDetectionPayload.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import Foundation

/// A single face-detection result staged for batch submission.
struct FaceDetectionEntry: Codable {
	// MARK: - Properties
	/// The Kurozora media row ID the result belongs to.
	let mediaID: Int

	/// The normalized horizontal focal point.
	let focalX: Double?

	/// The normalized vertical focal point.
	let focalY: Double?

	/// The identifier of the detector that produced the result, or `"none"` when no face was found.
	let detectorID: String

	enum CodingKeys: String, CodingKey {
		case mediaID = "media_id"
		case focalX = "focal_x"
		case focalY = "focal_y"
		case detectorID = "detector_id"
	}
}

/// The request body POSTed to `/v1/face-detections/batch`.
struct FaceDetectionBatchPayload: Codable {
	// MARK: - Properties
	/// The batched detection entries.
	let data: [FaceDetectionEntry]
}
#endif
