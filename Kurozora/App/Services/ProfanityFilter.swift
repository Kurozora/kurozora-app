//
//  ProfanityFilter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import NaturalLanguage
import CoreML

final class ProfanityFilter {
	// MARK: - Properties
	/// The shared instance of the profanity filter.
	static let shared = ProfanityFilter()

	/// The NL model used for profanity classification.
	private let model: NLModel?

	/// The bundled resource name of the compiled CoreML model.
	private let modelResourceName: String = "ProfanityClassifier"

	// MARK: - Initializers
	private init() {
		self.model = Self.loadModel(resourceName: self.modelResourceName)
	}

	// MARK: - Functions
	/// Returns whether the given text is classified as offensive.
	///
	/// The input is normalized (leet speak, homoglyphs, diacritics stripped)
	/// before inference. Returns `false` if the model failed to load (fail-open).
	///
	/// - Parameter text: The raw text to check.
	/// - Returns: `true` if the text is classified as offensive.
	func containsProfanity(_ text: String) -> Bool {
		let normalized = text.normalizedForProfanityCheck
		guard let label = self.model?.predictedLabel(for: normalized) else { return false }
		return label == "offensive"
	}

	/// Loads the compiled CoreML model with the given resource name from the main bundle.
	///
	/// - Parameter resourceName: The base name of the `.mlmodelc` resource.
	///
	/// - Returns: The natural language model, if the resource exists and loads.
	private static func loadModel(resourceName: String) -> NLModel? {
		guard let modelURL = Bundle.main.url(forResource: resourceName, withExtension: "mlmodelc") else {
			print("---- ProfanityFilter: \(resourceName).mlmodelc not in bundle, fail-open.")
			return nil
		}

		do {
			let mlModel = try MLModel(contentsOf: modelURL)
			return try NLModel(mlModel: mlModel)
		} catch {
			print("---- ProfanityFilter: Failed to load model: \(error)")
			return nil
		}
	}
}
