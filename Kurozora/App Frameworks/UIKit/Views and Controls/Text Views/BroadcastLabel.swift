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
class BroadcastLabel: KSecondaryLabel {
	// MARK: - Properties
	/// The timer that updates the countdown label.
	private var timer: Timer?

	/// The target date of the countdown.
	private var targetDate: Date?

	/// The target duration of the countdown.
	private var targetDuration: Int?

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
	func startCountdown(to date: Date, duration: Int) {
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

		self.text = "(" + self.getTimeUntilOrAgo(broadcastTimestamp: targetDate.timeIntervalSince1970, broadcastDuration: Int(targetDuration)) + ")"
	}

	/// Stops the countdown timer.
	func stopCountdown() {
		self.timer?.invalidate()
		self.timer = nil
	}

	/// Formats the time difference in a human-readable format.
	///
	/// - Parameters:
	///    - seconds: The time difference in seconds.
	///
	/// - Returns: The time difference in a human-readable format
	private func formatTimeDifference(seconds: Int) -> String {
		let secondsInMinute = 60
		let secondsInHour = 60 * 60
		let secondsInDay = 24 * 60 * 60
		let secondsInMonth = 30 * secondsInDay
		let secondsInYear = 12 * secondsInMonth

		var result = ""

		if seconds >= secondsInYear {
			let months = seconds / secondsInMonth
			let days = (seconds % secondsInMonth) / secondsInDay
			result = "\(months)M \(days)d"
		} else if seconds >= secondsInMonth {
			let days = seconds / secondsInDay
			let hours = (seconds % secondsInDay) / secondsInHour
			result = "\(days)d \(hours)h"
		} else if seconds >= secondsInDay {
			let days = seconds / secondsInDay
			let hours = (seconds % secondsInDay) / secondsInHour
			let minutes = (seconds % secondsInHour) / secondsInMinute
			result = "\(days)d \(hours)h \(minutes)m"
		} else if seconds >= secondsInHour {
			let hours = seconds / secondsInHour
			let minutes = (seconds % secondsInHour) / secondsInMinute
			let secs = seconds % secondsInMinute
			result = "\(hours)h \(minutes)m \(secs)s"
		} else if seconds >= secondsInMinute {
			let minutes = seconds / secondsInMinute
			let secs = seconds % secondsInMinute
			result = "\(minutes)m \(secs)s"
		} else {
			result = "\(seconds)s"
		}

		return result
	}

	/// Returns the time until or ago in a human-readable format.
	///
	/// - Parameters:
	///    - broadcastTimestamp: The timestamp of the broadcast.
	///    - broadcastDuration: The duration of the broadcast.
	///
	/// - Returns: The time until or ago in a human-readable format.
	private func getTimeUntilOrAgo(broadcastTimestamp: TimeInterval, broadcastDuration: Int) -> String {
		let currentTimestamp = Date().timeIntervalSince1970
		let diffInSeconds = Int(broadcastTimestamp - currentTimestamp)

		if diffInSeconds > 0 {
			// Future broadcast
			return formatTimeDifference(seconds: diffInSeconds) + " from now"
		} else if diffInSeconds <= 0 && abs(diffInSeconds) <= broadcastDuration {
			// Broadcast happening (within the duration)
			return formatTimeDifference(seconds: abs(diffInSeconds)) + " ago"
		} else {
			// After the broadcast duration, switch back to counting until next broadcast
			let nextBroadcastInSeconds = broadcastDuration + diffInSeconds
			return formatTimeDifference(seconds: nextBroadcastInSeconds) + " from now"
		}
	}
}
