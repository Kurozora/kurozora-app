//
//  Gestures.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import GameController

struct Gestures {
	// MARK: - Properties
	/// Whether a keyboard is available to trigger the navigation shortcuts.
	static var isKeyboardAttached: Bool {
		#if targetEnvironment(macCatalyst)
		return true
		#else
		return GCKeyboard.coalesced != nil
		#endif
	}

	// MARK: - Initializers
	private init() {}

	enum Section: Int, CaseIterable {
		// MARK: Cases
		case navigation

		// MARK: Properties
		/// The title of a section type.
		var titleValue: String {
			switch self {
			case .navigation:
				return L10n.navigation
			}
		}

		/// The footer of a section type, phrased for the inputs the device actually offers.
		var footerValue: String {
			switch self {
			case .navigation:
				#if targetEnvironment(macCatalyst)
				return L10n.forwardNavigationPointerFooter
				#else
				guard Gestures.isKeyboardAttached else {
					return L10n.swipeForwardFooter
				}

				return L10n.swipeForwardFooter + " " + L10n.forwardNavigationShortcutHint
				#endif
			}
		}

		/// The rows of a section type.
		var rows: [Gestures.Row] {
			switch self {
			case .navigation:
				return [.toggleForwardNavigation]
			}
		}
	}

	enum Row: Int, CaseIterable {
		// MARK: Cases
		case toggleForwardNavigation

		// MARK: Properties
		/// The title of a row type.
		var titleValue: String {
			switch self {
			case .toggleForwardNavigation:
				return L10n.swipeForward
			}
		}
	}
}
