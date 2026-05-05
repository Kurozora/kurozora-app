//
//  FaceDetectorRegistry.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import Foundation

/// The static registry of `ChainedFaceDetector`s indexed by `FaceDetectionEntityKind`.
///
/// Person images use Apple Vision with the anime detector as fallback; character images flip the order.
enum FaceDetectorRegistry {
	// MARK: - Properties
	private static let animeFaceDetector = AnimeFaceDetector(
		modelResourceName: "AnimeFaceDetector",
		outputLabel: "output0",
		identifier: "deepghs-anime-v1.4-s"
	)

	private static let visionFaceDetector = VisionFaceDetector()

	private static let personChain = ChainedFaceDetector(
		primary: visionFaceDetector,
		fallback: animeFaceDetector
	)

	private static let characterChain = ChainedFaceDetector(
		primary: animeFaceDetector,
		fallback: visionFaceDetector
	)

	// MARK: - Functions
	/// Returns the chained detector configured for the given media entity kind.
	///
	/// - Parameter kind: The kind of media entity whose image is being detected.
	/// - Returns: The chained detector for the kind.
	static func detector(for kind: FaceDetectionEntityKind) -> ChainedFaceDetector {
		switch kind {
		case .person:
			return self.personChain
		case .character:
			return self.characterChain
		}
	}
}
#endif
