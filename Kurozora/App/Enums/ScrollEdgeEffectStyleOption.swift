//
//  ScrollEdgeEffectStyleOption.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The set of scroll edge effects the app renders behind its bars.
enum ScrollEdgeEffectStyleOption: Int, CaseIterable {
	/// The blur that appears once content sits behind the bars.
	case blur = 0

	/// The solid background that appears once content sits behind the bars.
	case solid

	/// The solid background that stays visible with nothing behind the bars.
	case alwaysSolid

	// MARK: - Properties
	/// The effect used when the user hasn't picked one.
	static let `default`: ScrollEdgeEffectStyleOption = .blur

	/// The effect chosen in Settings.
	static var current: ScrollEdgeEffectStyleOption {
		return ScrollEdgeEffectStyleOption(rawValue: UserSettings.scrollEdgeEffectStyle) ?? self.default
	}

	/// The title value of the scroll edge effect style option.
	var titleValue: String {
		switch self {
		case .blur:
			return L10n.scrollEdgeEffectStyleBlur
		case .solid:
			return L10n.scrollEdgeEffectStyleSolid
		case .alwaysSolid:
			return L10n.scrollEdgeEffectStyleAlwaysSolid
		}
	}

	/// The scroll edge effect style behind the option.
	@available(iOS 27.0, macCatalyst 27.0, *)
	var style: UIScrollEdgeEffect.Style {
		switch self {
		case .blur:
			return .soft
		case .solid:
			return .automatic
		case .alwaysSolid:
			return .hard
		}
	}
}
