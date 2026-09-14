//
//  SplashScreenAnimationGroup.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The set of categories the splash screen animations are offered in.
enum SplashScreenAnimationGroup: Int, CaseIterable {
	case `default` = 0
	case traditional = 1
	case effects = 2

	/// The animations belonging to the group.
	var animations: [SplashScreenAnimation] {
		switch self {
		case .default:
			return [.default, .anvil, .bounce, .heartbeat, .scale, .shake, .spin]
		case .traditional:
			return [.furin, .iai, .shishiOdoshi, .sumie]
		case .effects:
			return [.gleam, .glitch, .impact]
		}
	}

	/// Whether the group is reserved for Pro and subscribed users.
	var isPremium: Bool {
		switch self {
		case .default:
			return false
		case .traditional, .effects:
			return true
		}
	}

	/// The title of the group.
	var titleValue: String {
		switch self {
		case .default:
			return L10n.default
		case .traditional:
			return L10n.traditional
		case .effects:
			return L10n.effects
		}
	}
}
