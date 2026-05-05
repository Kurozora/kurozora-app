//
//  AnimeFaceDetector.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import CoreML
import UIKit
import Vision

/// A face detector backed by an on-device YOLOv8 anime face Core ML model.
final class AnimeFaceDetector: FaceDetector {
	// MARK: - Properties
	let identifier: String

	private let modelResourceName: String
	private let outputLabel: String
	private let inputSize: CGFloat
	private let model: VNCoreMLModel?

	/// See `VisionFaceDetector` for why detection is kept off the cooperative pool.
	private let workQueue = DispatchQueue(
		label: "app.kurozora.face-detection.anime",
		qos: .utility,
		attributes: .concurrent
	)

	// MARK: - Initializers
	/// Creates a detector configured for a specific bundled model.
	///
	/// - Parameters:
	///   - modelResourceName: The base name of the `.mlmodelc` resource in the main bundle.
	///   - outputLabel: The name of the output feature in the compiled Core ML model.
	///   - identifier: The stable identifier sent to the server alongside detection results.
	///   - inputSize: The pixel size of the square input the model expects.
	init(modelResourceName: String, outputLabel: String, identifier: String, inputSize: CGFloat = 640) {
		self.modelResourceName = modelResourceName
		self.outputLabel = outputLabel
		self.identifier = identifier
		self.inputSize = inputSize
		self.model = Self.loadModel(resourceName: modelResourceName)
	}

	// MARK: - Functions
	func detectFocalPoint(in image: UIImage) async -> CGPoint? {
		guard let model = self.model, let cgImage = image.cgImage else {
			return nil
		}

		let outputLabel = self.outputLabel
		let inputSize = self.inputSize

		return await withCheckedContinuation { continuation in
			self.workQueue.async {
				let request = VNCoreMLRequest(model: model)
				request.imageCropAndScaleOption = .scaleFill

				let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])

				do {
					try handler.perform([request])
				} catch {
					continuation.resume(returning: nil)
					return
				}

				guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
					continuation.resume(returning: nil)
					return
				}

				let observation = results.first(where: { $0.featureName == outputLabel }) ?? results.first

				guard let multiArray = observation?.featureValue.multiArrayValue else {
					continuation.resume(returning: nil)
					return
				}

				let boxes = YOLOv8OutputDecoder.decode(output: multiArray, inputSize: inputSize)

				guard let best = boxes.first else {
					continuation.resume(returning: nil)
					return
				}

				continuation.resume(returning: CGPoint(x: best.rect.midX, y: best.rect.midY))
			}
		}
	}

	private static func loadModel(resourceName: String) -> VNCoreMLModel? {
		guard let url = Bundle.main.url(forResource: resourceName, withExtension: "mlmodelc") else {
			return nil
		}

		do {
			let configuration = MLModelConfiguration()
			let coreModel = try MLModel(contentsOf: url, configuration: configuration)
			return try VNCoreMLModel(for: coreModel)
		} catch {
			return nil
		}
	}
}
#endif
