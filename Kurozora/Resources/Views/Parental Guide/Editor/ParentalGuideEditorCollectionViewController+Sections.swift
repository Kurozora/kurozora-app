//
//  ParentalGuideEditorCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension ParentalGuideEditorCollectionViewController {
	/// The form sections rendered by the editor.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// The severity rating section.
		case rating

		/// The frequency section.
		case frequency

		/// The depiction section. Present only when the category supports depiction.
		case depiction

		/// The free-text reason section. Hosts both the text editor and the spoiler toggle.
		case reason

		// MARK: - Properties
		/// The header title for the section.
		var stringValue: String {
			switch self {
			case .rating:
				return L10n.parentalGuideSeverity
			case .frequency:
				return L10n.parentalGuideFrequency
			case .depiction:
				return L10n.parentalGuideDepiction
			case .reason:
				return L10n.parentalGuideReason
			}
		}
	}

	/// The set of available item kinds.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// The rating segmented picker.
		case ratingPicker

		/// The frequency segmented picker.
		case frequencyPicker

		/// The depiction segmented picker.
		case depictionPicker

		/// The free-text reason editor.
		case reasonEditor

		/// The spoiler toggle.
		case spoilerToggle
	}
}
