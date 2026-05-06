//
//  ParentalGuideReportCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ParentalGuideReportCollectionViewController {
	/// The form sections rendered by the report sheet.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// The reason picker section.
		case reason

		/// The free-text details section.
		case details

		// MARK: - Properties
		/// The header title for the section.
		var stringValue: String {
			switch self {
			case .reason:
				return L10n.reportReasonHeader
			case .details:
				return L10n.reportDetailsHeader
			}
		}
	}

	/// The set of available item kinds.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// A selectable reason option.
		case reasonOption(ParentalGuideReportReason)

		/// The free-text details editor.
		case detailsEditor
	}
}
