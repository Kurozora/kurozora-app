//
//  ParentalGuideCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ParentalGuideCollectionViewController {
	/// The section layout kind for the parental guide screen.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// The aggregate summary section at the top.
		case summary

		/// One section per parental guide category.
		case category(ParentalGuideCategory)

		// MARK: - Properties
		/// The display title for the section header.
		var stringValue: String {
			switch self {
			case .summary:
				return L10n.parentalGuideSummary
			case .category(let category):
				return category.displayName
			}
		}
	}

	/// The set of available item kinds.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// The aggregated summary card.
		case summaryCard

		/// A user-submitted entry card.
		case entry(ParentalGuideEntry)

		/// An empty-state CTA inviting the user to submit the first evaluation.
		case empty(ParentalGuideCategory)
	}
}
