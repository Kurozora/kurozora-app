//
//  MotionAnimationPreviewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class MotionAnimationPreviewCell: KTableViewCell {
	// MARK: - Views
	@IBOutlet weak var primaryImageView: UIImageView!
	@IBOutlet weak var primaryButton: KTintedButton!

	// MARK: - Properties
	private var currentAnimation: SplashScreenAnimation?
	private var playbackConfiguration: AnimationPlaybackConfiguration = .default
	private var isPaused: Bool = false

	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.configureView()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.stopPlayback()

		self.currentAnimation = nil
		self.isPaused = false

		self.updatePauseResumeButtonTitle()
	}

	// MARK: - Functions
	func configure(animation: SplashScreenAnimation, playbackConfiguration: AnimationPlaybackConfiguration) {
		self.currentAnimation = animation
		self.playbackConfiguration = playbackConfiguration

		self.primaryButton.isEnabled = animation != .none
		self.updatePauseResumeButtonTitle()
	}

	func startPlayback(forceResume: Bool = false) {
		guard self.currentAnimation != SplashScreenAnimation.none else {
			self.stopPlayback()
			return
		}

		if forceResume {
			self.isPaused = false
		}

		guard !self.isPaused else { return }

		Animation.shared.playAnimation(
			on: self.primaryImageView,
			configuration: self.playbackConfiguration,
			completion: nil
		)
	}

	func restartPlayback(forceResume: Bool = false) {
		self.stopPlayback()
		self.startPlayback(forceResume: forceResume)
	}

	func stopPlayback() {
		Animation.shared.cancelPlayback(with: self.playbackConfiguration.playbackID)
	}

	private func pauseResumeButtonPressed() {
		self.isPaused.toggle()
		self.updatePauseResumeButtonTitle()

		if self.isPaused {
			self.stopPlayback()
		} else {
			self.startPlayback()
		}
	}

	private func configureView() {
		self.primaryImageView.image = .kurozoraIconMonotone
		self.primaryImageView.theme_tintColor = KThemePicker.textColor.rawValue

		self.primaryButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.pauseResumeButtonPressed()
		}, for: .touchUpInside)

		self.updatePauseResumeButtonTitle()
	}

	private func updatePauseResumeButtonTitle() {
		let title = self.isPaused ? Trans.play : Trans.pause
		let imageName = self.isPaused ? "play.fill" : "pause.fill"

		self.primaryButton.setTitle(title, for: .normal)
		self.primaryButton.setImage(UIImage(systemName: imageName), for: .normal)
	}
}
