//
//  FaceDetectionContext.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The kind of media entity an image represents.
enum FaceDetectionEntityKind: String, Codable {
	case person
	case character
}

/// The metadata routed to the DEBUG face-detection pipeline on a successful image load.
struct FaceDetectionContext {
	// MARK: - Properties
	/// The CDN URL the image was loaded from.
	let mediaURL: URL

	/// The kind of media entity the image represents.
	let kind: FaceDetectionEntityKind
}
