//
//  SplashscreenViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

/// The screen shown while the app performs its process bootstrap.
final class SplashscreenViewController: KViewController {
	// MARK: - Views
	private lazy var logoImageView: UIImageView = {
		let imageView = UIImageView(image: .kurozoraIconMonotone)
		imageView.alpha = 0.0
		imageView.contentMode = .scaleToFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.theme_tintColor = KThemePicker.textColor.rawValue
		return imageView
	}()

	// MARK: - Properties
	/// The scheduled logo animation.
	private var launchExperienceTask: Task<Void, Never>?

	/// The scheduled chime.
	private var chimeTask: Task<Void, Never>?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.addSubview(self.logoImageView)

		NSLayoutConstraint.activate([
			self.logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.logoImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
			self.logoImageView.widthAnchor.constraint(equalToConstant: 128.0),
			self.logoImageView.widthAnchor.constraint(equalTo: self.logoImageView.heightAnchor, multiplier: 21.0 / 22.0)
		])
	}

	// MARK: - Functions
	/// Schedules the chime and the logo animation to land together.
	func startLaunchExperience() {
		let startedAt = CACurrentMediaTime()

		self.launchExperienceTask = Task { @MainActor in
			let chime = UserSettings.startupSoundAllowed ? await Chime.shared.prepare() : (duration: 0.0, onset: 0.0)
			let animation = Animation.shared.selectedAnimation
			let splashDuration = animation.duration

			if chime.duration > 0.0 {
				let chimeStart = animation.accent.map { $0 - chime.onset } ?? (splashDuration - chime.duration)
				self.scheduleChime(at: startedAt + max(0.0, chimeStart))
			}

			guard !Task.isCancelled else { return }

			await self.animateLogo()
			await Self.sleep(until: startedAt + splashDuration)
		}
	}

	/// Waits for the scheduled chime and logo animation to finish.
	func waitForLaunchExperience() async {
		await self.launchExperienceTask?.value
	}

	/// Cancels the scheduled chime and logo animation.
	func cancelLaunchExperience() {
		self.chimeTask?.cancel()
		self.chimeTask = nil
		self.launchExperienceTask?.cancel()
		self.launchExperienceTask = nil
	}

	/// Starts the prepared chime at the given media time.
	///
	/// - Parameter deadline: The media time at which playback starts.
	private func scheduleChime(at deadline: TimeInterval) {
		self.chimeTask = Task { @MainActor in
			await Self.sleep(until: deadline)

			guard !Task.isCancelled else { return }

			Chime.shared.playPrepared()
		}
	}

	/// Plays the splash logo animation.
	private func animateLogo() async {
		await withCheckedContinuation { continuation in
			Animation.shared.playAnimation(on: self.logoImageView) { _ in
				continuation.resume()
			}
		}
	}

	/// Suspends until the given media time.
	///
	/// - Parameter deadline: The media time to wake at.
	private static func sleep(until deadline: TimeInterval) async {
		let delay = deadline - CACurrentMediaTime()

		guard delay > 0.0 else { return }

		try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
	}
}
