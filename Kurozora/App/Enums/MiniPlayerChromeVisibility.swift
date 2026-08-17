//
//  MiniPlayerChromeVisibility.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The conditions under which the MiniPlayer reveals its metadata and controls.
enum MiniPlayerChromeVisibility: Int, CaseIterable {
	// MARK: - Cases
	/// The chrome is revealed while the pointer rests over the window.
	case onHover = 0

	/// The chrome stays visible.
	case always

	/// The chrome stays hidden.
	case never

	// MARK: - Properties
	/// The default chrome visibility option.
	static let `default`: MiniPlayerChromeVisibility = .onHover

	/// The title of the option.
	var stringValue: String {
		switch self {
		case .onHover:
			return L10n.onHover
		case .always:
			return L10n.alwaysVisible
		case .never:
			return L10n.neverVisible
		}
	}
}
