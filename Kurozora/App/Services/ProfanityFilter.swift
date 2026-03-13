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

	// MARK: - Initializers
	private init() {
		do {
			let mlModel = try ProfanityClassifier(configuration: MLModelConfiguration()).model
			self.model = try NLModel(mlModel: mlModel)
		} catch {
			print("---- ProfanityFilter: Failed to load ProfanityClassifier model — \(error)")
			self.model = nil
		}
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
}
