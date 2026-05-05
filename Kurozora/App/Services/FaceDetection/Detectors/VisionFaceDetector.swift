//
//  VisionFaceDetector.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import UIKit
import Vision

/// A face detector backed by Apple's Vision framework face rectangle request.
final class VisionFaceDetector: FaceDetector {
	// MARK: - Properties
	let identifier: String = "vision-1"

	/// `VNImageRequestHandler.perform` is synchronous; routing it through a dedicated queue keeps the cooperative pool from starving under load.
	private let workQueue = DispatchQueue(
		label: "app.kurozora.face-detection.vision",
		qos: .utility,
		attributes: .concurrent
	)

	// MARK: - Functions
	func detectFocalPoint(in image: UIImage) async -> CGPoint? {
		guard let cgImage = image.cgImage else {
			return nil
		}

		return await withCheckedContinuation { continuation in
			self.workQueue.async {
				let request = VNDetectFaceRectanglesRequest()
				let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])

				do {
					try handler.perform([request])
				} catch {
					continuation.resume(returning: nil)
					return
				}

				guard
					let observations = request.results,
					let bestObservation = observations.max(by: { lhs, rhs in lhs.confidence < rhs.confidence })
				else {
					continuation.resume(returning: nil)
					return
				}

				let boundingBox = bestObservation.boundingBox
				let centerX = boundingBox.midX
				let centerY = 1 - boundingBox.midY

				continuation.resume(returning: CGPoint(x: centerX, y: centerY))
			}
		}
	}
}
#endif
