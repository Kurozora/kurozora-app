//
//  SplashScreenAnimation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation

/// The set of available splash screen animation types.
enum SplashScreenAnimation: Int {
	case none = 0
	case `default` = 1
	case shake = 44
	case scale = 50
	case anvil = 57
	case spin = 58
	case bounce = 60
	case heartbeat = 80

	/// A collection of all values of this type.
	static let allCases: [SplashScreenAnimation] = [.default, .anvil, .bounce, .heartbeat, .scale, .shake, .spin]

	// MARK: Functions
	/// The title of the animation.
	var titleValue: String {
		switch self {
		case .none:
			return L10n.disabled
		case .default:
			return L10n.default
		case .shake:
			return L10n.shake
		case .scale:
			return L10n.scale
		case .anvil:
			return L10n.anvil
		case .spin:
			return L10n.spin
		case .heartbeat:
			return L10n.heartbeat
		case .bounce:
			return L10n.bounce
		}
	}
}
