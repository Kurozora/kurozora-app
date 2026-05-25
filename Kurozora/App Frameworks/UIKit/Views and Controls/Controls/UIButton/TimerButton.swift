//
//  TimerButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A themed control whose title tracks a live countdown to a target date.
final class TimerButton: KButton {
	// MARK: - Properties
	/// The date being counted down to.
	private var targetDate: Date?

	/// Produces the title for the time remaining until ``targetDate``.
	private var titleProvider: ((_ remaining: TimeInterval?) -> String)?

	/// The timer driving the countdown copy.
	private var countdownTimer: Timer?

	// MARK: - Initializers
	override func sharedInit() {
		super.sharedInit()

		if #available(iOS 26.0, *) {
			self.springEnabled = false
			self.backgroundColor = nil
			self.setTitleColor(nil, for: .normal)
			self.theme_setTitleColor(nil, forState: .normal)

			self.configuration = .prominentGlass()
			self.configuration?.background.cornerRadius = 10
			self.clipsToBounds = false
			self.layer.masksToBounds = false
		} else {
			self.configuration = .plain()
			self.theme_tintColor = KThemePicker.tintedButtonTextColor.rawValue
			self.theme_backgroundColor = KThemePicker.tintColor.rawValue
			self.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
			self.layerCornerRadius = 10
		}

		self.configuration?.titleAlignment = .leading
		self.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
		self.configuration?.imagePadding = 10
		self.configuration?.imagePlacement = .leading
		self.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			let basePointSize = outgoing.font?.pointSize ?? UIFont.preferredFont(forTextStyle: .subheadline).pointSize
			outgoing.font = .systemFont(ofSize: basePointSize, weight: .semibold)
			return outgoing
		}
	}

	deinit {
		self.stopCountdown()
	}

	// MARK: - Functions
	/// Starts tracking the time remaining until the given date, refreshing the title as it elapses.
	///
	/// - Parameters:
	///    - targetDate: The date to count down to.
	///    - titleProvider: Returns the title for the remaining time.
	func startCountdown(to targetDate: Date?, titleProvider: @escaping (_ remaining: TimeInterval?) -> String) {
		self.targetDate = targetDate
		self.titleProvider = titleProvider

		self.refreshTitle()
		self.scheduleCountdownTimer()
	}

	/// Stops the running countdown.
	func stopCountdown() {
		self.countdownTimer?.invalidate()
		self.countdownTimer = nil
	}

	/// Schedules the timer that refreshes the title.
	private func scheduleCountdownTimer() {
		self.countdownTimer?.invalidate()
		self.countdownTimer = nil

		guard let targetDate = self.targetDate else {
			return
		}

		let remaining = targetDate.timeIntervalSinceNow
		let interval: TimeInterval = remaining < 60 ? 1 : (remaining < 3600 ? 30 : 300)

		self.countdownTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
			self?.refreshTitle()
			self?.scheduleCountdownTimer()
		}
	}

	/// Refreshes the title for the current remaining time.
	private func refreshTitle() {
		guard let titleProvider = self.titleProvider else {
			return
		}

		self.setTitle(titleProvider(self.targetDate?.timeIntervalSinceNow), for: .normal)
	}
}
