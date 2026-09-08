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

/// A face detector backed by an on-device YOLOv8 anime face Core ML model, isolated to its own serial dispatch queue.
@available(iOS 17.0, *)
final actor AnimeFaceDetector: FaceDetector {
	// MARK: - Properties
	nonisolated let identifier: String

	nonisolated var unownedExecutor: UnownedSerialExecutor {
		return self.workQueue.asUnownedSerialExecutor()
	}

	private let outputLabel: String
	private let inputSize: CGFloat
	private let modelResourceName: String
	private lazy var model: VNCoreMLModel? = self.loadModel()

	/// See `VisionFaceDetector` for why detection is kept off the cooperative pool.
	private nonisolated let workQueue = DispatchSerialQueue(label: "app.kurozora.face-detection.anime", qos: .utility)

	// MARK: - Initializers
	/// Creates a detector configured for a specific bundled model.
	///
	/// - Parameters:
	///   - modelResourceName: The base name of the `.mlmodelc` resource in the main bundle.
	///   - outputLabel: The name of the output feature in the compiled Core ML model.
	///   - identifier: The stable identifier sent to the server alongside detection results.
	///   - inputSize: The pixel size of the square input the model expects.
	init(modelResourceName: String, outputLabel: String, identifier: String, inputSize: CGFloat = 640) {
		self.outputLabel = outputLabel
		self.identifier = identifier
		self.inputSize = inputSize
		self.modelResourceName = modelResourceName
	}

	// MARK: - Functions
	func detectFocalPoint(in image: UIImage) async -> CGPoint? {
		guard let model = self.model, let cgImage = image.cgImage else {
			return nil
		}

		let request = VNCoreMLRequest(model: model)
		request.imageCropAndScaleOption = .scaleFill

		let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])

		do {
			try handler.perform([request])
		} catch {
			return nil
		}

		guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
			return nil
		}

		let observation = results.first(where: { $0.featureName == self.outputLabel }) ?? results.first

		guard let multiArray = observation?.featureValue.multiArrayValue else {
			return nil
		}

		let boxes = YOLOv8OutputDecoder.decode(output: multiArray, inputSize: self.inputSize)

		guard let best = boxes.first else {
			return nil
		}

		return CGPoint(x: best.rect.midX, y: best.rect.midY)
	}

	private func loadModel() -> VNCoreMLModel? {
		guard let url = Bundle.main.url(forResource: self.modelResourceName, withExtension: "mlmodelc") else {
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
