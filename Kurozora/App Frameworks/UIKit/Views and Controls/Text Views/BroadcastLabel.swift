//
//  BroadcastLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class BroadcastLabel: KTintedLabel {
	private var timer: Timer?
	private var targetDate: Date?
	private var targetDuration: TimeInterval?

	func startCountdown(to date: Date, duration: TimeInterval) {
		self.targetDate = date
		self.targetDuration = duration
		self.updateCountdown()
		self.timer?.invalidate()

		// Schedule a new timer
		self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			self.updateCountdown()
		}

		// Add the timer to the run loop
		if let timer {
			RunLoop.main.add(timer, forMode: .common)
		}
	}

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

	func stopCountdown() {
		self.timer?.invalidate()
		self.timer = nil
	}

	deinit {
		// Ensure timer is invalidated when label is deallocated
		self.stopCountdown()
	}
}
