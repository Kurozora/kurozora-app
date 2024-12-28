//
//  SplashScreenAnimation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation

/// The set of available animation types.
///
/// - `none`: No animation.
/// - `default`: The default animation.
/// - `spin`: The spin animation.
/// - `bounce`: The bounce animation.
/// - `fadeAndScale`: The fade and scale animation.
enum SplashScreenAnimation: Int {
	case none = 0
	case `default` = 1
	case bounce = 60
	case fadeAndScale = 75
	case spin = 58

	/// A collection of all values of this type.
	static let allCases: [SplashScreenAnimation] = [.default, .bounce, .fadeAndScale, .spin]

	// MARK: Functions
	/// The title of the animation.
	var titleValue: String {
		switch self {
		case .none:
			return "Disabled"
		case .default:
			return "Default"
		case .spin:
			return "Spin"
		case .bounce:
			return "Bounce"
		case .fadeAndScale:
			return "Fade & Scale"
		}
	}
}
