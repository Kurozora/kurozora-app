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

	/// The time a single pass of the animation takes.
	var duration: TimeInterval {
		switch self {
		case .none:
			return 1.0
		case .default:
			return 1.4
		case .shake:
			return 0.6
		case .scale:
			return 0.5
		case .anvil:
			return 0.55
		case .spin:
			return 1.0
		case .bounce:
			return 0.87
		case .heartbeat:
			return 1.0
		}
	}
}
