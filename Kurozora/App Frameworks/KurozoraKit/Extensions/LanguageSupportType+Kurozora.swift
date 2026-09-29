//
//  LanguageSupportType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension LanguageSupportType {
	// MARK: - Properties
	/// The localized name of a language support type.
	var stringValue: String {
		switch self {
		case .audio:
			return L10n.audio
		case .subtitles:
			return L10n.subtitles
		case .interface:
			return L10n.interface
		case .text:
			return L10n.publishedText
		}
	}
}

extension LanguageSupport {
	// MARK: - Properties
	/// Whether the language is the viewer's own.
	var isViewerLanguage: Bool {
		guard let code = self.code else { return false }

		let viewerCode = String(LanguageManager.shared.locale.identifier.prefix(2))
		return code.caseInsensitiveCompare(viewerCode) == .orderedSame
	}

	/// The localized summary of how the language is supported.
	var supportSummary: String? {
		guard self.isViewerLanguage else { return L10n.notAvailableInYourLanguage }

		return self.types.localizedNames
	}
}

extension Array where Element == LanguageSupportType {
	// MARK: - Properties
	/// The localized names of the support types.
	var localizedNames: String? {
		guard !self.isEmpty else { return nil }

		return self.sorted { $0.rawValue < $1.rawValue }
			.map(\.stringValue)
			.localizedJoined()
	}
}
