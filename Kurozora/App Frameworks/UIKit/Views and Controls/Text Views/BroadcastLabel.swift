//
//  BroadcastLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

/// A themed view that displays one or more lines of read-only text, often used in conjunction with controls to describe their intended purpose.
///
/// The color of the labels is pre-configured with the currently selected theme's secondary text color.
/// You can add labels to your interface programmatically or by using Interface Builder.
/// The view also contains a countdown timer that updates every second.
///
/// - Tag: BroadcastLabel
class BroadcastLabel: KTintedLabel {
	// MARK: - Properties
	/// The timer that updates the countdown label.
	private var timer: Timer?

	/// The target date of the countdown.
	private var targetDate: Date?

	/// The target duration of the countdown.
	private var targetDuration: TimeInterval?

	// MARK: - Initializers
	deinit {
		self.stopCountdown()
	}

	// MARK: - Functions
	/// Starts a countdown to a given date and duration.
	///
	/// - Parameters:
	///  - date: The date to countdown to.
	///  - duration: The duration of the countdown.
	func startCountdown(to date: Date, duration: TimeInterval) {
		self.targetDate = date
		self.targetDuration = duration
		self.updateCountdown()
		self.timer?.invalidate()

		self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			self.updateCountdown()
		}

		// Add the timer to the run loop
		if let timer {
			RunLoop.main.add(timer, forMode: .common)
		}
	}

	/// Updates the countdown label.
	private func updateCountdown() {
		guard let targetDate = self.targetDate else { return }
		guard let targetDuration = self.targetDuration else { return }

		let remainingTime = targetDate.timeIntervalSinceNow
		if remainingTime <= 0 && remainingTime >= -targetDuration {
			self.text = "Now airing"
		} else {
			let formatted = targetDate.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
			self.text = formatted
		}
	}

	/// Stops the countdown timer.
	func stopCountdown() {
		self.timer?.invalidate()
		self.timer = nil
	}
}
