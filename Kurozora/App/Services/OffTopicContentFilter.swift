//
//  OffTopicContentFilter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import NaturalLanguage
import CoreML

/// Detects whether a piece of user-generated content reads as a request for
/// where or how to watch/read the tracked media.
///
/// Kurozora is a tracking app — it does not stream or host content. This filter
/// is used as a pre-submission nudge on feed messages and reviews to surface a
/// soft warning when a user appears to be asking for external streaming or
/// reading sources, which is off-topic for the app's purpose.
///
/// ### Tiered classification
///
/// 1. On iOS 26+ with Apple Intelligence available, `OffTopicLLMClassifier` is
///    consulted first — it reasons about intent, distinguishing source-seeking
///    requests from past-tense discussion or "why can't I watch in this app?"
///    bug reports.
/// 2. On every other device, and as a fallback when the LLM is unavailable or
///    errors out, the bundled CreateML text classifier
///    (`OffTopicRequestClassifier.mlmodelc`, Transfer Learning + multilingual
///    BERT) makes the call.
/// 3. If both fail or are absent, the filter fails open — no warning shown,
///    posting proceeds normally. Infrastructure problems never block posts.
///
/// All inference happens on-device; nothing leaves the user's device.
final class OffTopicContentFilter {
	// MARK: - Properties
	/// The shared instance of the off-topic content filter.
	static let shared = OffTopicContentFilter()

	/// The natural language model used for classifying posts as a fallback
	/// when the LLM classifier isn't available.
	private let model: NLModel?

	/// Minimum confidence for flagging a post as off-topic source-seeking via
	/// the CoreML fallback path.
	///
	/// Tuned against the validation split — raise to reduce false positives,
	/// lower to catch more edge phrasings.
	private let threshold: Double = 0.80

	/// Posts shorter than this skip inference: too few tokens for a meaningful signal.
	private let minimumCharacters: Int = 8

	/// The label emitted by the classifier for off-topic source-seeking content.
	private let offTopicLabel: String = "off_topic_source_seeking"

	/// The bundled resource name of the compiled CoreML model.
	private let modelResourceName: String = "OffTopicRequestClassifier"

	// MARK: - Initializers
	private init() {
		self.model = Self.loadModel(resourceName: self.modelResourceName)
	}

	// MARK: - Functions
	/// Hints to the system that a classification is imminent, so any heavier
	/// resources (the on-device LLM) can be preloaded.
	///
	/// Cheap when preloading isn't available — safe to call from
	/// `viewDidAppear` on the composer view controllers.
	func prewarm() {
		if #available(iOS 26.0, macOS 26.0, *) {
			OffTopicLLMClassifier.shared.prewarm()
		}
	}

	/// Returns whether the text reads as a request for where or how to watch
	/// or read the tracked media (off-topic for a tracker-only app).
	///
	/// Tries the on-device LLM first on capable devices, then falls back to the
	/// CoreML text classifier. Fails open on every error — posting is never
	/// blocked because the classifier couldn't load or errored.
	///
	/// - Parameter text: The raw text to check. Passed through without
	///                   normalization — BERT embeddings need native casing and
	///                   diacritics for accurate multilingual inference.
	/// - Returns: `true` if the classifier considers the post off-topic
	///            source-seeking; `false` otherwise or on any failure.
	func isOffTopicSourceSeeking(_ text: String) async -> Bool {
		let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard trimmed.count >= self.minimumCharacters else { return false }

		if #available(iOS 26.0, macOS 26.0, *) {
			let llm = OffTopicLLMClassifier.shared
			if llm.isAvailable {
				return await llm.isOffTopicSourceSeeking(trimmed)
			}
		}

		return self.classifyWithCoreML(trimmed)
	}

	// MARK: - Private
	/// Runs the CoreML fallback classifier on already-trimmed text.
	private func classifyWithCoreML(_ trimmed: String) -> Bool {
		guard let model = self.model else { return false }
		let hypotheses = model.predictedLabelHypotheses(for: trimmed, maximumCount: 2)
		let score = hypotheses[self.offTopicLabel] ?? 0.0
		return score >= self.threshold
	}

	/// Attempts to load the compiled CoreML model from the app bundle.
	///
	/// Resolving by resource name (rather than the CoreML-generated Swift class)
	/// keeps this file compilable when the `.mlmodel` has not yet been added to
	/// the target — useful while the training corpus is being assembled.
	///
	/// - Parameter resourceName: The bundle resource name of the compiled model (without extension).
	/// - Returns: An `NLModel` wrapping the loaded classifier, or `nil` if the resource is missing or invalid.
	private static func loadModel(resourceName: String) -> NLModel? {
		guard let modelURL = Bundle.main.url(forResource: resourceName, withExtension: "mlmodelc") else {
			print("---- OffTopicContentFilter: \(resourceName).mlmodelc not in bundle — fail-open.")
			return nil
		}

		do {
			let mlModel = try MLModel(contentsOf: modelURL)
			return try NLModel(mlModel: mlModel)
		} catch {
			print("---- OffTopicContentFilter: Failed to load model — \(error)")
			return nil
		}
	}
}
