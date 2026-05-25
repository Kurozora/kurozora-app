//
//  IssueTimeoutCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension IssueTimeoutCollectionViewController {
	/// The form sections rendered by the issue-timeout sheet.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// The section grouping the duration and reason pickers.
		case timeout

		/// The free-text note section.
		case note

		// MARK: - Properties
		/// The header title for the section.
		var stringValue: String {
			switch self {
			case .timeout:
				return L10n.issueTimeoutSectionHeader
			case .note:
				return L10n.issueTimeoutNoteHeader
			}
		}
	}

	/// The set of available item kinds.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// The duration picker row.
		case durationRow

		/// The reason picker row.
		case reasonRow

		/// The free-text note editor.
		case noteEditor
	}
}
