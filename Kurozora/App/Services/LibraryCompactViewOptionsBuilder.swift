//
//  LibraryCompactViewOptionsBuilder.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum LibraryCompactViewOptionsBuilder {
	// MARK: - Functions
	/// Returns a `UIMenu` of mutually exclusive title-visibility options for the compact library layout.
	///
	/// - Parameters:
	///    - fetch: A closure that returns the latest persisted visibility. Called once for the initial display state and again each time an action is tapped.
	///    - apply: A closure invoked with the newly selected visibility.
	///
	/// - Returns: A `UIMenu` configured with `.singleSelection`, suitable for embedding inside a context menu.
	static func makeMenu(fetch: @escaping () -> LibraryCompactTitleVisibility, apply: @escaping (LibraryCompactTitleVisibility) -> Void) -> UIMenu {
		let current = fetch()
		let actions = LibraryCompactTitleVisibility.allCases.map { visibility in
			Self.makeAction(for: visibility, isSelected: visibility == current, apply: apply)
		}

		return UIMenu(title: L10n.viewOptions, options: .singleSelection, children: actions)
	}

	// MARK: - Helpers
	private static func makeAction(for visibility: LibraryCompactTitleVisibility, isSelected: Bool, apply: @escaping (LibraryCompactTitleVisibility) -> Void) -> UIAction {
		let action = UIAction(title: visibility.title, image: visibility.image, state: isSelected ? .on : .off) { _ in
			apply(visibility)
		}

		if let subtitle = visibility.subtitle {
			action.subtitle = subtitle
		}

		return action
	}
}
