//
//  YOLOv8OutputDecoder.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import CoreML
import UIKit

/// A bounding box decoded from a YOLOv8 output tensor.
struct YOLOv8Box {
	// MARK: - Properties
	/// The bounding box in normalized image coordinates.
	let rect: CGRect

	/// The detection confidence in the range `[0, 1]`.
	let confidence: Float
}

/// Decodes a YOLOv8 single-class face-detection output tensor into bounding boxes.
///
/// The model's `[1, 5, N]` output holds `[centerX, centerY, width, height, confidence]` per anchor in input pixel coordinates.
enum YOLOv8OutputDecoder {
	// MARK: - Functions
	/// Decodes the output tensor and returns the surviving boxes after thresholding and non-maximum suppression.
	///
	/// - Parameters:
	///   - output: The `[1, 5, N]` shaped tensor produced by a YOLOv8 single-class face model.
	///   - inputSize: The pixel size of the square input fed to the model.
	///   - confidenceThreshold: The minimum confidence required to keep a candidate.
	///   - iouThreshold: The IoU above which overlapping candidates are suppressed.
	/// - Returns: The boxes that survive thresholding and non-maximum suppression, sorted by descending confidence.
	static func decode(
		output: MLMultiArray,
		inputSize: CGFloat,
		confidenceThreshold: Float = 0.25,
		iouThreshold: Float = 0.45
	) -> [YOLOv8Box] {
		guard output.shape.count == 3, output.shape[1].intValue == 5 else {
			return []
		}

		let anchorCount = output.shape[2].intValue
		let pointer = output.dataPointer.bindMemory(to: Float.self, capacity: output.count)

		let centerXOffset = 0
		let centerYOffset = anchorCount
		let widthOffset = anchorCount * 2
		let heightOffset = anchorCount * 3
		let confidenceOffset = anchorCount * 4

		var candidates: [YOLOv8Box] = []
		candidates.reserveCapacity(anchorCount)

		for anchorIndex in 0..<anchorCount {
			let confidence = pointer[confidenceOffset + anchorIndex]

			guard confidence >= confidenceThreshold else {
				continue
			}

			let centerX = CGFloat(pointer[centerXOffset + anchorIndex]) / inputSize
			let centerY = CGFloat(pointer[centerYOffset + anchorIndex]) / inputSize
			let width = CGFloat(pointer[widthOffset + anchorIndex]) / inputSize
			let height = CGFloat(pointer[heightOffset + anchorIndex]) / inputSize

			let rect = CGRect(
				x: centerX - width / 2,
				y: centerY - height / 2,
				width: width,
				height: height
			)

			candidates.append(YOLOv8Box(rect: rect, confidence: confidence))
		}

		return self.nonMaximumSuppression(boxes: candidates, iouThreshold: iouThreshold)
	}

	private static func nonMaximumSuppression(boxes: [YOLOv8Box], iouThreshold: Float) -> [YOLOv8Box] {
		let sorted = boxes.sorted { $0.confidence > $1.confidence }
		var kept: [YOLOv8Box] = []

		for candidate in sorted {
			let overlapsKept = kept.contains { existing in
				self.intersectionOverUnion(candidate.rect, existing.rect) > CGFloat(iouThreshold)
			}

			if !overlapsKept {
				kept.append(candidate)
			}
		}

		return kept
	}

	private static func intersectionOverUnion(_ first: CGRect, _ second: CGRect) -> CGFloat {
		let intersection = first.intersection(second)

		guard !intersection.isNull, intersection.width > 0, intersection.height > 0 else {
			return 0
		}

		let intersectionArea = intersection.width * intersection.height
		let unionArea = first.width * first.height + second.width * second.height - intersectionArea

		guard unionArea > 0 else {
			return 0
		}

		return intersectionArea / unionArea
	}
}
#endif
