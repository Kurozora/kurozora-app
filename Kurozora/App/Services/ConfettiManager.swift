//
//  ConfettiManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/01/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import Foundation
import SPConfetti

final class ConfettiManager: NSObject {
	// MARK: - Properties
	/// The shared instance of `ConfettiManager`.
	static let shared = ConfettiManager()

	// MARL: - Initializers
	override private init() {
		super.init()
	}

	/// Play confetti animation for special day.
	///
	/// - Note: The confetti animation will only play once a day.
	func play() {
		guard
			let specialDay = SpecialDay.allCases.first(where: { $0.isToday() }),
			!Calendar.current.isDateInToday(UserSettings.confettiLastSeenAt)
		else {
			return
		}

		UserSettings.set(Date(), forKey: .confettiLastSeenAt)
		SPConfettiConfiguration.particlesConfig.colors = specialDay.confettiColors
		SPConfetti.startAnimating(.fullWidthToDown, particles: specialDay.confettiParticles)

		print("----- 🎉 Playing confetti for \(specialDay)")
	}

	/// Stop confetti animation.
	func stop() {
		SPConfetti.stopAnimating()
		print("----- 🛑 Confetti stopped.")
	}
}
