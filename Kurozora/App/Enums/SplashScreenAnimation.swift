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
	case iai = 19
	case gleam = 38
	case shake = 44
	case scale = 50
	case anvil = 57
	case spin = 58
	case glitch = 59
	case bounce = 60
	case impact = 62
	case sumie = 67
	case furin = 68
	case heartbeat = 80
	case shishiOdoshi = 142

	/// The time at which the animation lands its defining hit.
	var accent: TimeInterval? {
		switch self {
		case .none:
			return nil
		case .default:
			return 0.8
		case .iai:
			return 0.3
		case .shake:
			return 0.0
		case .scale:
			return 0.35
		case .anvil:
			return 0.34
		case .spin:
			return 0.9
		case .bounce:
			return 0.25
		case .furin:
			return 0.12
		case .sumie:
			return 0.8
		case .gleam:
			return 0.55
		case .glitch:
			return 0.1
		case .impact:
			return 0.12
		case .heartbeat:
			return 0.0
		case .shishiOdoshi:
			return 0.9
		}
	}

	/// The time a single pass of the animation takes.
	var duration: TimeInterval {
		switch self {
		case .none:
			return 1.0
		case .default:
			return 1.4
		case .iai:
			return 1.2
		case .furin:
			return 1.3
		case .sumie:
			return 1.0
		case .gleam:
			return 1.1
		case .glitch:
			return 0.6
		case .impact:
			return 0.8
		case .shishiOdoshi:
			return 1.2
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
