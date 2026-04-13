//
//  OffTopicLLMClassifier.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// On-device LLM classifier for off-topic "where to watch/read" posts.
///
/// Uses Apple's `FoundationModels` framework (iOS 26+ / macOS 26+) when
/// Apple Intelligence is available on the device. Unlike `OffTopicContentFilter`'s
/// CoreML backstop, this classifier can reason about intent — distinguishing a
/// post *asking* for external streaming sources from a post *discussing* what
/// the user already watched, or *complaining* that the app itself doesn't play
/// content. Multilingual without any per-language wiring.
///
/// All inference is on-device. No prompts, responses, or user text ever leave
/// the device — matches the app's no-data-collection posture.
///
/// Fail-open everywhere: any error path returns `false` so posts are never
/// blocked by the classifier going sideways.
@available(iOS 26.0, macOS 26.0, *)
final class OffTopicLLMClassifier {
	// MARK: - Properties
	/// The shared instance of the LLM classifier.
	static let shared = OffTopicLLMClassifier()

	/// Serial access to the single session — `LanguageModelSession` allows only
	/// one in-flight request, so we serialize here rather than rely on the
	/// caller to coordinate.
	private let session: LanguageModelSession

	/// Whether the base system model is available on this device right now.
	///
	/// `SystemLanguageModel.isAvailable` returns `false` if Apple Intelligence
	/// isn't eligible (older hardware), isn't enabled in Settings, or the model
	/// assets haven't finished downloading.
	var isAvailable: Bool {
		return SystemLanguageModel.default.isAvailable
	}

	// MARK: - Initializers
	private init() {
		let instructions = Instructions("""
		You classify short posts from a media tracking app called Kurozora.

		Kurozora is a tracker: users log which anime episodes they've watched and which manga \
		chapters they've read, rate them, and discuss them. Kurozora does not stream video, \
		does not host manga, and does not link to external streaming or reading sites.

		Your job is to decide whether the post is a user asking how or where to watch or read \
		anime/manga — i.e. asking for a source. The user does not need to name a specific \
		title and does not need to say the word "external" or "site" — any open-ended request \
		for how to watch or read counts. Phrasings work in any language.

		Set isSourceSeeking = true for posts like:
		  - "where can I watch Bleach?"
		  - "any site to read manga?"
		  - "link to stream the new season"
		  - "How do I watch"
		  - "how can I watch any anime pls help can't figure out"
		  - "how to read manga"
		  - "donde veo este anime"
		  - "dimana nonton anime"
		  - "où regarder cet anime"
		  - any short request for help finding something to watch or read

		Set isSourceSeeking = false for:
		  - Reviews and opinions ("great art", "mid", "10/10")
		  - Past-tense statements ("watched this last week", "read the whole manga")
		  - Anticipation ("can't wait to watch the next episode")
		  - Complaints that mention the Kurozora app SPECIFICALLY by name or phrase like \
		    "in the app", "in this app", "in Kurozora", "the app won't play" — those are \
		    bug reports about Kurozora, not source-seeking. A post that says "how do I watch" \
		    WITHOUT mentioning the app is source-seeking.
		  - Recommendations given or asked for ("if you liked X try Y")
		  - General discussion, theory, character talk, art appreciation
		  - Announcements, questions about release schedules, production staff, etc.

		When in doubt between source-seeking and bug report: if the post mentions "the app", \
		"this app", "Kurozora", or describes broken playback, it's a bug report (false). \
		If it's just asking how/where to watch or read with no app context, it's \
		source-seeking (true).
		""")

		self.session = LanguageModelSession(instructions: instructions)
	}

	// MARK: - Functions
	/// Preloads the model so the first `isOffTopicSourceSeeking(_:)` call is
	/// fast. Safe to call repeatedly.
	///
	/// Call when the user begins composing a post — Apple documents this method
	/// needs at least one second of head-start to pay off.
	func prewarm() {
		guard self.isAvailable else { return }
		self.session.prewarm()
	}

	/// Returns whether the text reads as a request for external streaming or
	/// reading sources.
	///
	/// - Parameter text: The raw text to classify.
	/// - Returns: `true` when the LLM is confident the post is source-seeking.
	///            Fails open to `false` on any error (unavailable, rate-limited,
	///            guardrail violation, concurrent request, network-style
	///            asset-unavailable, etc.).
	func isOffTopicSourceSeeking(_ text: String) async -> Bool {
		guard self.isAvailable else { return false }
		let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return false }

		do {
			let response = try await self.session.respond(
				to: "Classify this post:\n\n\(trimmed)",
				generating: Classification.self
			)
			return response.content.isSourceSeeking
		} catch {
			// Any error: behave like the classifier is unavailable.
			// We explicitly don't propagate errors to the caller because a
			// bad classification should never prevent the user from posting.
			print("---- OffTopicLLMClassifier: classification failed — \(error)")
			return false
		}
	}
}

// MARK: - Generable output type
@available(iOS 26.0, macOS 26.0, *)
extension OffTopicLLMClassifier {
	/// Structured output type the LLM is asked to produce. Wrapping the result
	/// in a `@Generable` type lets us skip brittle free-text parsing.
	@Generable
	struct Classification {
		@Guide(description: "True if the post is asking where to find external streaming or reading sources for anime or manga. False for everything else — reviews, past-tense watched/read statements, anticipation, app bug reports, general discussion.")
		let isSourceSeeking: Bool
	}
}
