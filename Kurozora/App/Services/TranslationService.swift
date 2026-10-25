//
//  TranslationService.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import NaturalLanguage
import SwiftUI
@preconcurrency import Translation
import UIKit

/// Translates ``TranslatableContent`` into the reader's language on device, preserving its inline formatting.
///
/// The service owns all translation state. Read it with ``state(for:)`` and observe
/// ``Foundation/NSNotification/Name/KTranslationDidUpdate`` for changes.
@available(iOS 26.4, macCatalyst 26.4, *)
@MainActor
final class TranslationService {
	// MARK: - Properties
	/// The shared feed translation service.
	static let shared = TranslationService()

	/// Whether the device can translate on device.
	static let isSupported: Bool = {
		#if targetEnvironment(simulator)
		return false
		#else
		return true
		#endif
	}()

	/// The languages the on-device models can translate.
	private var supportedLanguages: [Locale.Language] = []

	/// The resolved target language, recomputed after the reader changes their preferences.
	private var cachedTargetLanguage: Locale.Language?

	/// The detected source language of each piece of content, including content found ineligible.
	private var detectedLanguages: [TranslationIdentity: Locale.Language?] = [:]

	/// The translated body of each piece of content, keyed by identity and target language.
	private var translatedBodies: [TranslationKey: NSAttributedString] = [:]

	/// The content the reader is currently shown the translation of.
	private var revealedIdentities: Set<TranslationIdentity> = []

	/// The content with a translation in flight.
	private var translatingIdentities: Set<TranslationIdentity> = []

	/// The content whose most recent translation attempt failed.
	private var failedIdentities: Set<TranslationIdentity> = []

	/// The content already handed to automatic translation.
	private var autoTranslatedIdentities: Set<TranslationIdentity> = []

	/// The content waiting to be translated, keyed by identity.
	private var pendingTranslations: [TranslationIdentity: PendingTranslation] = [:]

	/// Whether ``pendingTranslations`` is currently being drained.
	private var isDraining: Bool = false

	/// The minimum number of characters content needs before its language is detected.
	private let minimumCharacters: Int = 2

	/// The minimum confidence a detected language needs.
	private let minimumConfidence: Double = 0.65

	/// The minimum confidence a detected language needs for Latin-script text.
	///
	/// Higher than ``minimumConfidence`` because most supported languages share the Latin script.
	private let minimumLatinConfidence: Double = 0.90

	/// The longest a translation may wait for a session before it's abandoned.
	private let timeout: Duration = .seconds(30)

	// MARK: - Initializers
	private init() {
		self.loadSupportedLanguages()
	}

	// MARK: - Functions
	/// Returns the translation state of the given content, starting its automatic translation.
	///
	/// - Parameter content: The content to describe.
	///
	/// - Returns: The state to render.
	func state(for content: TranslatableContent) -> State {
		guard Self.isSupported else { return .unavailable }
		guard let sourceLanguage = self.sourceLanguage(for: content) else { return .unavailable }

		self.repairStrandedTranslation(for: content)
		self.autoTranslateIfNeeded(for: content, from: sourceLanguage)

		if self.translatingIdentities.contains(content.translationIdentity) {
			return .translating(sourceLanguage: sourceLanguage)
		}

		if self.failedIdentities.contains(content.translationIdentity) {
			return .failed(sourceLanguage: sourceLanguage)
		}

		guard self.revealedIdentities.contains(content.translationIdentity) else {
			return .original(sourceLanguage: sourceLanguage)
		}

		guard let body = self.translatedBodies[TranslationKey(identity: content.translationIdentity, target: self.targetLanguage)] else {
			return .original(sourceLanguage: sourceLanguage)
		}

		return .translated(sourceLanguage: sourceLanguage, body: body)
	}

	/// Toggles between the content's original body and its translation.
	///
	/// - Parameter content: The content to toggle.
	func toggleTranslation(for content: TranslatableContent) {
		guard Self.isSupported else { return }

		if self.revealedIdentities.contains(content.translationIdentity) {
			self.revealedIdentities.remove(content.translationIdentity)
			self.postUpdate(for: [content.translationIdentity])
			return
		}

		guard let sourceLanguage = self.sourceLanguage(for: content) else { return }

		self.enqueueTranslation(for: content, from: sourceLanguage)
	}

	/// Translates the given content ahead of it being shown.
	///
	/// - Parameter contents: The content about to be shown.
	func prefetch(_ contents: [TranslatableContent]) {
		guard Self.isSupported else { return }

		for content in contents {
			guard let sourceLanguage = self.sourceLanguage(for: content) else { continue }

			self.autoTranslateIfNeeded(for: content, from: sourceLanguage)
		}
	}

	/// Discards every cached detection and translation.
	///
	/// Call after the reader changes their translation preferences.
	func invalidate() {
		self.cachedTargetLanguage = nil
		self.detectedLanguages.removeAll()
		self.translatedBodies.removeAll()
		self.revealedIdentities.removeAll()
		self.failedIdentities.removeAll()
		self.autoTranslatedIdentities.removeAll()
		self.postUpdate(for: nil)
	}

	/// Returns the reader-facing name of the given language, without naming its variant.
	///
	/// Use for a detected language, whose variant isn't reliably known.
	///
	/// - Parameter language: The language to name.
	///
	/// - Returns: The language name in the app's current language.
	func localizedLanguageName(for language: Locale.Language) -> String {
		let locale = LanguageManager.shared.locale

		guard let languageCode = language.languageCode?.identifier else {
			return language.maximalIdentifier
		}

		return locale.localizedString(forLanguageCode: languageCode) ?? languageCode
	}

	/// Returns the reader-facing name of the given language, naming its variant when the
	/// models ship more than one.
	///
	/// - Parameter language: The language to name.
	///
	/// - Returns: The language name in the app's current language.
	func localizedName(for language: Locale.Language) -> String {
		let locale = LanguageManager.shared.locale

		guard let languageCode = language.languageCode?.identifier else {
			return language.maximalIdentifier
		}

		let variants = self.supportedLanguages.filter { $0.languageCode == language.languageCode }

		guard variants.count > 1 else {
			return locale.localizedString(forLanguageCode: languageCode) ?? languageCode
		}

		if variants.contains(where: { $0.script != language.script }), let script = language.script?.identifier {
			return locale.localizedString(forIdentifier: "\(languageCode)-\(script)") ?? languageCode
		}

		if let region = language.region?.identifier {
			return locale.localizedString(forIdentifier: "\(languageCode)_\(region)") ?? languageCode
		}

		return locale.localizedString(forLanguageCode: languageCode) ?? languageCode
	}
}

// MARK: - Target Language
@available(iOS 26.4, macCatalyst 26.4, *)
extension TranslationService {
	/// The language content is translated into.
	var targetLanguage: Locale.Language {
		if let cachedTargetLanguage = self.cachedTargetLanguage {
			return cachedTargetLanguage
		}

		let targetLanguage = self.resolvedTargetLanguage()
		self.cachedTargetLanguage = targetLanguage
		return targetLanguage
	}

	/// The languages messages can be translated into, ordered by name.
	var availableTargetLanguages: [Locale.Language] {
		return self.supportedLanguages.sorted { first, second in
			self.localizedName(for: first).localizedStandardCompare(self.localizedName(for: second)) == .orderedAscending
		}
	}

	/// Resolves the target language from the reader's override, account, app and device languages, falling back to English.
	///
	/// - Returns: The language content is translated into.
	private func resolvedTargetLanguage() -> Locale.Language {
		if let override = UserSettings.translationLanguage, let language = self.supportedLanguage(matching: override) {
			return language
		}

		if let preferredLanguage = User.current?.attributes.preferredLanguage, let language = self.supportedLanguage(matching: preferredLanguage) {
			return language
		}

		if let appLanguage = LanguageManager.shared.languageCode, let language = self.supportedLanguage(matching: appLanguage) {
			return language
		}

		for identifier in Locale.preferredLanguages {
			if let language = self.supportedLanguage(matching: identifier) {
				return language
			}
		}

		return self.supportedLanguage(matching: "en") ?? Locale.Language(identifier: "en")
	}

	/// Loads the languages the on-device models cover.
	private func loadSupportedLanguages() {
		guard Self.isSupported else { return }

		Task { [weak self] in
			let languages = await LanguageAvailability().supportedLanguages
			guard let self = self else { return }

			self.supportedLanguages = languages
			self.cachedTargetLanguage = nil
			self.postUpdate(for: nil)
		}
	}

	/// Returns the on-device language matching the given identifier.
	///
	/// Matches on maximal identifier first, then on language code disambiguated by script and region.
	///
	/// - Parameter identifier: The language identifier to resolve.
	///
	/// - Returns: The matching supported language.
	private func supportedLanguage(matching identifier: String) -> Locale.Language? {
		guard !self.supportedLanguages.isEmpty else { return nil }

		let language = Locale.Language(identifier: identifier)

		if let exact = self.supportedLanguages.first(where: { $0.maximalIdentifier == language.maximalIdentifier }) {
			return exact
		}

		guard let languageCode = language.languageCode else { return nil }
		let candidates = self.supportedLanguages.filter { $0.languageCode == languageCode }

		guard candidates.count > 1 else { return candidates.first }

		if let script = language.script, let match = candidates.first(where: { $0.script == script }) {
			return match
		}

		if let region = language.region, let match = candidates.first(where: { $0.region == region }) {
			return match
		}

		for preferred in Locale.preferredLanguages.map({ Locale.Language(identifier: $0) }) where preferred.languageCode == languageCode {
			if let script = preferred.script, let match = candidates.first(where: { $0.script == script }) {
				return match
			}

			if let region = preferred.region, let match = candidates.first(where: { $0.region == region }) {
				return match
			}
		}

		return candidates.first
	}
}

// MARK: - Source Language
@available(iOS 26.4, macCatalyst 26.4, *)
extension TranslationService {
	/// Returns the content's source language when a translation is worth offering.
	///
	/// - Parameter content: The content to inspect.
	///
	/// - Returns: The detected source language.
	private func sourceLanguage(for content: TranslatableContent) -> Locale.Language? {
		guard !self.supportedLanguages.isEmpty else { return nil }

		let sourceLanguage: Locale.Language?

		if let cached = self.detectedLanguages[content.translationIdentity] {
			sourceLanguage = cached
		} else {
			sourceLanguage = self.detectLanguage(in: content.translationPlainText ?? content.translationMarkdown ?? "")
			self.detectedLanguages[content.translationIdentity] = sourceLanguage
		}

		guard let sourceLanguage = sourceLanguage else { return nil }
		guard sourceLanguage.languageCode != self.targetLanguage.languageCode else { return nil }

		return sourceLanguage
	}

	/// Returns the dominant language of the given text.
	///
	/// - Parameter text: The text to inspect.
	///
	/// - Returns: The detected language.
	private func detectLanguage(in text: String) -> Locale.Language? {
		let strippedText = self.strippingEntities(from: text)
		guard strippedText.count >= self.minimumCharacters else { return nil }

		let recognizer = NLLanguageRecognizer()
		recognizer.languageConstraints = self.recognizerConstraints
		recognizer.processString(strippedText)

		let hypotheses = recognizer.languageHypotheses(withMaximum: 10)
		guard !hypotheses.isEmpty else { return nil }

		// Confidence is summed per language so that a script split, such as Han between
		// Simplified and Traditional, doesn't sink an otherwise certain match.
		var confidences: [String: Double] = [:]
		var dominantVariants: [String: (identifier: String, confidence: Double)] = [:]

		for (language, confidence) in hypotheses {
			let languageCode = String(language.rawValue.prefix { $0 != "-" })
			confidences[languageCode, default: 0] += confidence

			if confidence > (dominantVariants[languageCode]?.confidence ?? -1) {
				dominantVariants[languageCode] = (language.rawValue, confidence)
			}
		}

		guard let detected = confidences.max(by: { $0.value < $1.value }) else { return nil }
		guard detected.value >= self.minimumConfidence(for: strippedText) else { return nil }
		guard let variant = dominantVariants[detected.key] else { return nil }

		return self.supportedLanguage(matching: variant.identifier)
	}

	/// Returns the confidence the given text has to reach before its language is trusted.
	///
	/// - Parameter text: The text being detected.
	///
	/// - Returns: The threshold appropriate to the text's script.
	private func minimumConfidence(for text: String) -> Double {
		return self.isPredominantlyLatin(text) ? self.minimumLatinConfidence : self.minimumConfidence
	}

	/// Returns whether the text is written mostly in the Latin script.
	///
	/// - Parameter text: The text to inspect.
	///
	/// - Returns: `true` when most of the text's letters are Latin.
	private func isPredominantlyLatin(_ text: String) -> Bool {
		let letters = text.unicodeScalars.filter { CharacterSet.letters.contains($0) }
		guard !letters.isEmpty else { return false }

		let latinLetters = letters.filter { scalar in
			(scalar.value >= 0x41 && scalar.value <= 0x5A)
				|| (scalar.value >= 0x61 && scalar.value <= 0x7A)
				|| (scalar.value >= 0xC0 && scalar.value <= 0x24F)
		}

		return Double(latinLetters.count) / Double(letters.count) > 0.5
	}

	/// The languages the recognizer is allowed to choose between.
	private var recognizerConstraints: [NLLanguage] {
		return self.supportedLanguages.compactMap { language in
			guard let languageCode = language.languageCode?.identifier else { return nil }

			// Chinese is the only language the recognizer qualifies by script.
			guard languageCode == "zh" else { return NLLanguage(languageCode) }

			return language.script?.identifier == "Hant" ? .traditionalChinese : .simplifiedChinese
		}
	}

	/// Returns the text without the links, mentions and hashtags that carry no language signal.
	///
	/// - Parameter text: The text to strip.
	///
	/// - Returns: The stripped text.
	private func strippingEntities(from text: String) -> String {
		let pattern = "(https?://\\S+)|([@#][a-zA-Z0-9_]+)"

		guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
			return text.trimmingCharacters(in: .whitespacesAndNewlines)
		}

		let range = NSRange(location: 0, length: (text as NSString).length)
		let stripped = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: " ")
		return stripped.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	/// Returns whether content in the given language is translated without being asked.
	///
	/// - Parameter language: The language to check.
	///
	/// - Returns: `true` when the language is translated automatically.
	func isAutoTranslated(_ language: Locale.Language) -> Bool {
		let excludedLanguages = UserSettings.autoTranslateExcludedLanguages
		guard !excludedLanguages.isEmpty else { return true }

		return !excludedLanguages.contains { identifier in
			Locale.Language(identifier: identifier).languageCode == language.languageCode
		}
	}
}

// MARK: - Translation
@available(iOS 26.4, macCatalyst 26.4, *)
extension TranslationService {
	/// Releases content reported as translating that nothing is working on.
	///
	/// - Parameter content: The content to check.
	private func repairStrandedTranslation(for content: TranslatableContent) {
		guard self.translatingIdentities.contains(content.translationIdentity) else { return }
		guard !self.isDraining, self.pendingTranslations[content.translationIdentity] == nil else { return }

		self.translatingIdentities.remove(content.translationIdentity)
	}

	/// Translates the content without being asked, unless the reader opted its language out.
	///
	/// - Parameters:
	///   - content: The content to translate.
	///   - sourceLanguage: The language the content is written in.
	private func autoTranslateIfNeeded(for content: TranslatableContent, from sourceLanguage: Locale.Language) {
		guard self.isAutoTranslated(sourceLanguage) else { return }
		guard !self.autoTranslatedIdentities.contains(content.translationIdentity) else { return }

		self.autoTranslatedIdentities.insert(content.translationIdentity)

		self.enqueueTranslation(for: content, from: sourceLanguage, isRequested: false)
	}

	/// Reveals the content's translation.
	///
	/// - Parameters:
	///   - content: The content to translate.
	///   - sourceLanguage: The language the content is written in.
	///   - isRequested: Whether the reader asked for the translation.
	private func enqueueTranslation(for content: TranslatableContent, from sourceLanguage: Locale.Language, isRequested: Bool = true) {
		let key = TranslationKey(identity: content.translationIdentity, target: self.targetLanguage)

		if self.translatedBodies[key] != nil {
			self.revealedIdentities.insert(content.translationIdentity)
			self.postUpdate(for: [content.translationIdentity])
			return
		}

		guard !self.translatingIdentities.contains(content.translationIdentity) else { return }

		self.failedIdentities.remove(content.translationIdentity)
		self.translatingIdentities.insert(content.translationIdentity)
		self.pendingTranslations[content.translationIdentity] = PendingTranslation(content: content, sourceLanguage: sourceLanguage, isRequested: isRequested)

		if isRequested {
			self.postUpdate(for: [content.translationIdentity])
		}

		self.scheduleDrain()
	}

	/// Starts draining the queue unless a drain is already running.
	private func scheduleDrain() {
		guard !self.isDraining else { return }

		self.isDraining = true

		Task { [weak self] in
			await self?.drainPendingTranslations()
			guard let self = self else { return }

			// Clearing the flag and re-checking the queue must not be separated by an
			// await, or content enqueued while the drain wound down is never picked up.
			self.isDraining = false

			if !self.pendingTranslations.isEmpty {
				self.scheduleDrain()
			}
		}
	}

	/// Translates everything queued, one batch per source language.
	private func drainPendingTranslations() async {
		while let next = self.pendingTranslations.values.first {
			let target = self.targetLanguage
			let sourceLanguage = next.sourceLanguage
			let batch = self.pendingTranslations.values.filter { $0.sourceLanguage.maximalIdentifier == sourceLanguage.maximalIdentifier }

			for pending in batch {
				self.pendingTranslations.removeValue(forKey: pending.content.translationIdentity)
			}

			await self.translate(batch, from: sourceLanguage, to: target)
		}
	}

	/// Translates a batch of content in a single session and records the outcome.
	///
	/// - Parameters:
	///   - batch: The content to translate, all written in the same language.
	///   - source: The language to translate from.
	///   - target: The language to translate into.
	private func translate(_ batch: [PendingTranslation], from source: Locale.Language, to target: Locale.Language) async {
		let isInstalled = await LanguageAvailability().status(from: source, to: target) == .installed
		let translatableBatch = isInstalled ? batch : batch.filter { $0.isRequested }
		let requests = self.requests(for: translatableBatch)

		do {
			let responses: [TranslationSession.Response]

			if requests.isEmpty {
				responses = []
			} else if isInstalled {
				responses = try await TranslationSession(installedSource: source, target: target).translations(from: requests)
			} else {
				responses = try await self.withSession(from: source, to: target) { session in
					try await session.translations(from: requests)
				}
			}

			for response in responses {
				guard let clientIdentifier = response.clientIdentifier else { continue }

				guard let identity = TranslationIdentity(rawValue: clientIdentifier) else { continue }

				let translatedBody = response.attributedTargetText ?? AttributedString(response.targetText)
				self.translatedBodies[TranslationKey(identity: identity, target: target)] = self.applyingWritingDirection(of: target, to: NSAttributedString(translatedBody))
				self.revealedIdentities.insert(identity)
			}

			if !isInstalled && !requests.isEmpty {
				self.resumeAutomaticTranslation(from: source)
			}
		} catch {
			if !self.isCancellation(error) {
				for pending in translatableBatch {
					self.failedIdentities.insert(pending.content.translationIdentity)
				}
			}

			print("-----", error.localizedDescription)
		}

		var identities: Set<TranslationIdentity> = []

		for pending in batch {
			self.translatingIdentities.remove(pending.content.translationIdentity)
			identities.insert(pending.content.translationIdentity)
		}

		self.postUpdate(for: identities)
	}

	/// Returns whether the error means the reader canceled the translation.
	///
	/// - Parameter error: The error to inspect.
	///
	/// - Returns: `true` when the reader canceled.
	private func isCancellation(_ error: Error) -> Bool {
		return error is CancellationError || (error as? CocoaError)?.code == .userCancelled
	}

	/// Returns the translation requests for the given content.
	///
	/// - Parameter batch: The content to translate.
	///
	/// - Returns: One request per piece of content with a body.
	private func requests(for batch: [PendingTranslation]) -> [TranslationSession.Request] {
		let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
		var requests: [TranslationSession.Request] = []

		for pending in batch {
			guard let markdown = pending.content.translationMarkdown ?? pending.content.translationPlainText else { continue }

			let body = (try? AttributedString(markdown: markdown, options: options)) ?? AttributedString(markdown)
			requests.append(TranslationSession.Request(sourceText: body, clientIdentifier: pending.content.translationIdentity.rawValue))
		}

		return requests
	}

	/// Lets untranslated content in the given language translate automatically again.
	///
	/// - Parameter language: The language whose models were just installed.
	private func resumeAutomaticTranslation(from language: Locale.Language) {
		let target = self.targetLanguage

		self.autoTranslatedIdentities = self.autoTranslatedIdentities.filter { identity in
			guard self.translatedBodies[TranslationKey(identity: identity, target: target)] == nil else { return true }
			guard let detectedLanguage = self.detectedLanguages[identity] ?? nil else { return true }

			return detectedLanguage.maximalIdentifier != language.maximalIdentifier
		}

		self.postUpdate(for: nil)
	}

	/// Returns the body laid out for the given language's writing direction.
	///
	/// - Parameters:
	///   - language: The language the body is written in.
	///   - body: The translated body.
	///
	/// - Returns: The body with a matching paragraph style applied.
	private func applyingWritingDirection(of language: Locale.Language, to body: NSAttributedString) -> NSAttributedString {
		guard language.characterDirection == .rightToLeft else { return body }

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.baseWritingDirection = .rightToLeft
		paragraphStyle.alignment = .right

		let styledBody = NSMutableAttributedString(attributedString: body)
		styledBody.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: styledBody.length))
		return styledBody
	}

	/// Runs the given work against a translation session for the given language pair.
	///
	/// Installs a transparent host for the lifetime of the request, so the framework can
	/// ask the reader to download a language pair they don't have yet.
	///
	/// - Parameters:
	///   - source: The language to translate from.
	///   - target: The language to translate into.
	///   - body: The work to perform with the session.
	///
	/// - Returns: The result of the work.
	private func withSession<Result>(from source: Locale.Language, to target: Locale.Language, perform body: @escaping @MainActor @Sendable (TranslationSession) async throws -> Result) async throws -> Result {
		guard let parent = self.rootViewController else { throw TranslationError.noPresentationContext }

		var hostingController: TranslationSessionHostingController?
		defer {
			hostingController?.willMove(toParent: nil)
			hostingController?.view.removeFromSuperview()
			hostingController?.removeFromParent()
		}

		return try await withCheckedThrowingContinuation { continuation in
			let resumeGuard = ResumeGuard()

			// The host only vends a session once it appears, so a request made as the
			// reader navigates away would otherwise never resume.
			let timeoutTask = Task {
				try? await Task.sleep(for: self.timeout)
				guard !Task.isCancelled, resumeGuard.claim() else { return }

				continuation.resume(throwing: TranslationError.timedOut)
			}

			let host = TranslationSessionHost(
				configuration: TranslationSession.Configuration(source: source, target: target),
				perform: { session in
					timeoutTask.cancel()

					do {
						let result = try await body(session)
						guard resumeGuard.claim() else { return }

						continuation.resume(returning: result)
					} catch {
						guard resumeGuard.claim() else { return }

						continuation.resume(throwing: error)
					}
				}
			)

			// The task only runs once the host appears, so it needs full containment
			// rather than a bare subview.
			let controller = TranslationSessionHostingController(rootView: host)
			controller.sheetDismissalHandler = {
				guard resumeGuard.claim() else { return }

				continuation.resume(throwing: CancellationError())
			}
			parent.addChild(controller)
			controller.view.frame = parent.view.bounds
			controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			controller.view.backgroundColor = .clear
			controller.view.isUserInteractionEnabled = false
			parent.view.addSubview(controller.view)
			controller.didMove(toParent: parent)

			hostingController = controller
		}
	}

	/// The view controller the session host is installed in.
	///
	/// The root rather than a presented controller, so dismissing a sheet mid-request
	/// doesn't strand the session.
	private var rootViewController: UIViewController? {
		let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
		let activeScene = windowScenes.first { $0.activationState == .foregroundActive } ?? windowScenes.first
		let window = activeScene?.windows.first { $0.isKeyWindow } ?? activeScene?.windows.first

		return window?.rootViewController
	}

	/// Notifies observers that content's translation state changed.
	///
	/// - Parameter identities: The content that changed, or `nil` when everything did.
	private func postUpdate(for identities: Set<TranslationIdentity>?) {
		NotificationCenter.default.post(name: .KTranslationDidUpdate, object: identities)
	}
}

// MARK: - State
@available(iOS 26.4, macCatalyst 26.4, *)
extension TranslationService {
	/// The translation state of a single feed message.
	enum State {
		/// The message needs no translation, or none can be offered.
		case unavailable

		/// The message is translatable and its original body is shown.
		case original(sourceLanguage: Locale.Language)

		/// The message is being translated.
		case translating(sourceLanguage: Locale.Language)

		/// The message is translated and its translation is shown.
		case translated(sourceLanguage: Locale.Language, body: NSAttributedString)

		/// The message could not be translated.
		case failed(sourceLanguage: Locale.Language)

		/// The source language, when one was detected.
		var sourceLanguage: Locale.Language? {
			switch self {
			case .unavailable:
				return nil
			case .original(let sourceLanguage), .translating(let sourceLanguage), .failed(let sourceLanguage):
				return sourceLanguage
			case .translated(let sourceLanguage, _):
				return sourceLanguage
			}
		}

		/// The translated body, when the translation is shown.
		var body: NSAttributedString? {
			switch self {
			case .translated(_, let body):
				return body
			default:
				return nil
			}
		}
	}

	/// A failure raised while translating a feed message.
	enum TranslationError: Error {
		/// No window was available to present the framework's download UI over.
		case noPresentationContext

		/// The session was never vended within the allotted time.
		case timedOut
	}
}

// MARK: - Translation Key
@available(iOS 26.4, macCatalyst 26.4, *)
private extension TranslationService {
	/// A message queued for translation.
	struct PendingTranslation {
		/// The message to translate.
		let content: TranslatableContent

		/// The language the message is written in.
		let sourceLanguage: Locale.Language

		/// Whether the reader asked for the translation.
		let isRequested: Bool
	}

	/// The identity of a single translation, which changes with the target language.
	struct TranslationKey: Hashable {
		/// The translated message.
		let identity: TranslationIdentity

		/// The language the message was translated into.
		let target: Locale.Language
	}

	/// A single-use gate around resuming a continuation.
	final class ResumeGuard {
		/// Whether the continuation has already been resumed.
		private var isClaimed = false

		/// Claims the right to resume the continuation.
		///
		/// - Returns: `true` for the first caller only.
		func claim() -> Bool {
			guard !self.isClaimed else { return false }

			self.isClaimed = true
			return true
		}
	}
}

// MARK: - Translation Session Host
/// A transparent SwiftUI host that vends a translation session to UIKit.
@available(iOS 26.4, macCatalyst 26.4, *)
private struct TranslationSessionHost: View {
	// MARK: - Properties
	/// The language pair to translate between.
	let configuration: TranslationSession.Configuration

	/// The work to perform once the session is ready.
	let perform: @MainActor @Sendable (TranslationSession) async -> Void

	// MARK: - View
	var body: some View {
		Color.clear
			.translationTask(self.configuration) { session in
				await self.perform(session)
			}
	}
}

// MARK: - Translation Session Hosting Controller
/// A hosting controller that presents the framework's sheets inside a plain container.
@available(iOS 26.4, macCatalyst 26.4, *)
private final class TranslationSessionHostingController: UIHostingController<TranslationSessionHost> {
	// MARK: - Properties
	/// The work to run when the reader dismisses a presented sheet.
	var sheetDismissalHandler: (() -> Void)?

	/// The object relaying the presented container's dismissal to the framework's sheet.
	private var dismissalForwarder: SheetDismissalForwarder?

	// MARK: - Functions
	override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
		guard let sheet = viewControllerToPresent.sheetPresentationController else {
			super.present(viewControllerToPresent, animated: flag, completion: completion)
			return
		}

		let containerViewController = UIViewController()
		containerViewController.modalPresentationStyle = viewControllerToPresent.modalPresentationStyle
		containerViewController.isModalInPresentation = viewControllerToPresent.isModalInPresentation

		containerViewController.addChild(viewControllerToPresent)
		viewControllerToPresent.view.frame = containerViewController.view.bounds
		viewControllerToPresent.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		containerViewController.view.addSubview(viewControllerToPresent.view)
		viewControllerToPresent.didMove(toParent: containerViewController)

		if let containerSheet = containerViewController.sheetPresentationController {
			containerSheet.detents = sheet.detents
			containerSheet.selectedDetentIdentifier = sheet.selectedDetentIdentifier
			containerSheet.largestUndimmedDetentIdentifier = sheet.largestUndimmedDetentIdentifier
			containerSheet.prefersGrabberVisible = sheet.prefersGrabberVisible
			containerSheet.prefersEdgeAttachedInCompactHeight = sheet.prefersEdgeAttachedInCompactHeight
			containerSheet.preferredCornerRadius = sheet.preferredCornerRadius

			let dismissalForwarder = SheetDismissalForwarder(contentSheet: sheet) { [weak self] in
				self?.sheetDismissalHandler?()
			}
			containerSheet.delegate = dismissalForwarder
			self.dismissalForwarder = dismissalForwarder
		}

		super.present(containerViewController, animated: flag, completion: completion)
	}
}

// MARK: - Sheet Dismissal Forwarder
/// Relays a container sheet's dismissal callbacks to the sheet it wraps.
@available(iOS 26.4, macCatalyst 26.4, *)
private final class SheetDismissalForwarder: NSObject, UISheetPresentationControllerDelegate {
	// MARK: - Properties
	/// The sheet presentation controller of the wrapped content.
	private weak var contentSheet: UISheetPresentationController?

	/// The delegate assigned to the wrapped content's sheet.
	private weak var contentDelegate: UISheetPresentationControllerDelegate?

	/// The work to run after the reader dismisses the container.
	private let onDismiss: () -> Void

	// MARK: - Initializers
	/// Creates a forwarder for the given sheet.
	///
	/// - Parameters:
	///   - contentSheet: The sheet presentation controller of the wrapped content.
	///   - onDismiss: The work to run after the reader dismisses the container.
	init(contentSheet: UISheetPresentationController, onDismiss: @escaping () -> Void) {
		self.contentSheet = contentSheet
		self.contentDelegate = contentSheet.delegate
		self.onDismiss = onDismiss
		super.init()
	}

	// MARK: - Functions
	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		guard let contentSheet = self.contentSheet else { return true }

		return self.contentDelegate?.presentationControllerShouldDismiss?(contentSheet) ?? true
	}

	func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
		guard let contentSheet = self.contentSheet else { return }

		self.contentDelegate?.presentationControllerWillDismiss?(contentSheet)
	}

	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		self.onDismiss()

		guard let contentSheet = self.contentSheet else { return }

		self.contentDelegate?.presentationControllerDidDismiss?(contentSheet)
	}

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		guard let contentSheet = self.contentSheet else { return }

		self.contentDelegate?.presentationControllerDidAttemptToDismiss?(contentSheet)
	}
}
