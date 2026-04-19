//
//  LibraryColumnMenuBuilder.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum LibraryColumnMenuBuilder {
	// MARK: - Functions
	/// Returns a `UIMenu` of toggleable columns for the given library kind.
	///
	/// - Parameters:
	///    - kind: The library kind whose columns should appear in the menu.
	///    - current: The user's current column preferences.
	///    - apply: A closure invoked with the updated preferences after each interaction.
	///
	/// - Returns: A `UIMenu` suitable for assignment to a `UIBarButtonItem` or return from a context menu provider.
	static func makeMenu(kind: KKLibrary.Kind, fetch: @escaping () -> KKLibrary.ColumnPreferences, apply: @escaping (KKLibrary.ColumnPreferences) -> Void) -> UIMenu {
		return UIMenu(title: L10n.viewOptions, children: Self.makeMenuItems(kind: kind, fetch: fetch, apply: apply))
	}

	/// Returns the ordered list of menu elements that make up the View Options submenu.
	///
	/// - Parameters:
	///    - kind: The library kind whose columns should appear in the menu.
	///    - fetch: A closure that returns the latest persisted preferences. Called once for the initial display state and again each time a toggle is tapped.
	///    - apply: A closure invoked with the updated preferences after each interaction.
	///
	/// - Returns: The menu elements in display order.
	static func makeMenuItems(kind: KKLibrary.Kind, fetch: @escaping () -> KKLibrary.ColumnPreferences, apply: @escaping (KKLibrary.ColumnPreferences) -> Void) -> [UIMenuElement] {
		let current = fetch()

		let posterAction = UIAction(title: L10n.showPoster, image: UIImage(systemName: "photo"), state: current.showPoster ? .on : .off) { _ in
			var updated = fetch()
			updated.showPoster.toggle()
			apply(updated)
		}
		let posterMenu = UIMenu(title: "", options: .displayInline, children: [posterAction])

		let toggleActions = KKLibrary.Column.allCases
			.filter { !$0.isAlwaysVisible }
			.filter { $0.hasBackingData }
			.filter { $0.isApplicable(to: kind) }
			.filter { !(current.showPoster && $0.isSubsumedByTitleWhenPosterShown) }
			.map { column in
				Self.makeToggleAction(for: column, initialVisible: !current.hidden.contains(column), fetch: fetch, apply: apply)
			}

		let resetAction = UIAction(title: L10n.resetToDefault, image: UIImage(systemName: "arrow.uturn.backward"), attributes: .destructive) { _ in
			apply(.defaultShared)
		}
		let resetMenu = UIMenu(title: "", options: .displayInline, children: [resetAction])

		return [posterMenu] + toggleActions + [resetMenu]
	}

	// MARK: - Helpers
	private static func makeToggleAction(for column: KKLibrary.Column, initialVisible: Bool, fetch: @escaping () -> KKLibrary.ColumnPreferences, apply: @escaping (KKLibrary.ColumnPreferences) -> Void) -> UIAction {
		let state: UIMenuElement.State = initialVisible ? .on : .off
		let title = column.title.isEmpty ? column.rawValue.capitalized : column.title

		return UIAction(title: title, state: state) { _ in
			var updated = fetch()

			if initialVisible {
				updated.hidden.insert(column)
			} else {
				updated.hidden.remove(column)
			}

			apply(updated)
		}
	}
}
