//
//  TranslatableContent.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

/// Identifies a single piece of translatable content, namespaced by kind.
struct TranslationIdentity: Hashable {
	// MARK: - Properties
	/// The kind of content being identified.
	let kind: Kind

	/// The content's identifier within its own kind.
	let id: KurozoraItemID

	/// The identity as a single string.
	var rawValue: String {
		return "\(self.kind.rawValue):\(self.id.rawValue)"
	}

	// MARK: - Initializers
	init(kind: Kind, id: KurozoraItemID) {
		self.kind = kind
		self.id = id
	}

	/// Creates an identity from its string form.
	///
	/// - Parameter rawValue: The identity as produced by ``rawValue``.
	init?(rawValue: String) {
		let components = rawValue.split(separator: ":", maxSplits: 1)

		guard components.count == 2, let kind = Kind(rawValue: String(components[0])) else { return nil }

		self.kind = kind
		self.id = KurozoraItemID(String(components[1]))
	}
}

// MARK: - Kind
extension TranslationIdentity {
	/// The kinds of user-generated content the app translates.
	enum Kind: String {
		/// A feed message.
		case feedMessage

		/// A user's biography.
		case biography

		/// A review of a piece of media.
		case review

		/// A parental guide entry's reason.
		case parentalGuideEntry
	}
}

// MARK: - Translatable Content
/// A piece of user-generated content that can be translated into the reader's language.
protocol TranslatableContent {
	/// Identifies this content to the translation service.
	var translationIdentity: TranslationIdentity { get }

	/// The Markdown body the reader is shown, and the text that gets translated.
	var translationMarkdown: String? { get }

	/// The plain text used to detect which language the content is written in.
	var translationPlainText: String? { get }
}

// MARK: - Feed Message
extension FeedMessage: TranslatableContent {
	var translationIdentity: TranslationIdentity {
		return TranslationIdentity(kind: .feedMessage, id: self.id)
	}

	var translationMarkdown: String? {
		return self.attributes.contentMarkdown
	}

	var translationPlainText: String? {
		return self.attributes.content
	}
}

// MARK: - Biography
extension User: TranslatableContent {
	var translationIdentity: TranslationIdentity {
		return TranslationIdentity(kind: .biography, id: self.id)
	}

	var translationMarkdown: String? {
		return self.attributes.biographyMarkdown
	}

	var translationPlainText: String? {
		return self.attributes.biography
	}
}

// MARK: - Review
extension Review: TranslatableContent {
	var translationIdentity: TranslationIdentity {
		return TranslationIdentity(kind: .review, id: self.id)
	}

	var translationMarkdown: String? {
		return self.attributes.description
	}

	var translationPlainText: String? {
		return self.attributes.description
	}
}

// MARK: - Parental Guide Entry
extension ParentalGuideEntry: TranslatableContent {
	var translationIdentity: TranslationIdentity {
		return TranslationIdentity(kind: .parentalGuideEntry, id: self.id)
	}

	var translationMarkdown: String? {
		return self.attributes.reason
	}

	var translationPlainText: String? {
		return self.attributes.reason
	}
}
