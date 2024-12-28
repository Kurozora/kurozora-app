//
//  Animation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class Animation: NSObject {
	// MARK: Properties
	/// The shared instance of `Animation`.
	static let shared = Animation()

	// MARK: Initializers
	private override init() {
		super.init()

		self.sharedInit()
	}

	// MARK: Functions
	/// The shared settings used to initialize the `Animation` object.
	private func sharedInit() {}

	/// Plays the selected animation
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		// Check accessibility settings
		if UserSettings.isReduceMotionEnabled || UIAccessibility.isReduceMotionEnabled {
			self.playNoneAnimation(on: view, completion: completion)
			return
		}

		switch UserSettings.currentSplashScreenAnimation {
		case .none:
			self.playNoneAnimation(on: view, completion: completion)
		case .default:
			self.playDefaultAnimation(on: view, completion: completion)
		case .spin:
			self.playSpinAnimation(on: view, completion: completion)
		case .bounce:
			self.playBounceAnimation(on: view, completion: completion)
		case .fadeAndScale:
			self.playFadeAndScaleAnimation(on: view, completion: completion)
		}
	}

	/// Changes the current animation.
	///
	/// - Parameter animation: The new animation to use.
	func changeAnimation(to animation: SplashScreenAnimation) {
		UserSettings.set(animation.rawValue, forKey: .currentSplashScreenAnimation)
		NotificationCenter.default.post(name: .KSSplashScreenAnimationDidChange, object: nil)
	}
}

// MARK: - Animations
private extension Animation {
	/// Plays no animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playNoneAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		completion?(true)
	}

	/// Plays the default animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playDefaultAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		// Start with the logo scaled down and transparent
		view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		view.alpha = 0.0

		UIView.animate(withDuration: 0.5, animations: {
			view.alpha = 1.0
			view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
		}) { _ in
			// Rotate slightly while scaling down
			UIView.animate(withDuration: 0.3, animations: {
				view.transform = CGAffineTransform(rotationAngle: .pi / 8).scaledBy(x: 1.0, y: 1.0)
			}) { _ in
				// Bounce back to original size and position
				UIView.animate(
					withDuration: 0.6,
					delay: 0.0,
					usingSpringWithDamping: 0.4,
					initialSpringVelocity: 0.7,
					options: [.curveEaseInOut],
					animations: {
						view.transform = .identity
					},
					completion: completion
				)
			}
		}
	}

	/// Plays the spin animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playSpinAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		view.transform = CGAffineTransform(rotationAngle: 0)
		UIView.animate(withDuration: 0.6, delay: 0.0, options: [.curveEaseInOut], animations: {
			view.transform = CGAffineTransform(rotationAngle: .pi * 2)
		}, completion: completion)
	}

	/// Plays the bounce animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playBounceAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		view.transform = .identity
		UIView.animate(withDuration: 0.2, animations: {
			view.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
		}) { _ in
			UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: [.curveEaseInOut], animations: {
				view.transform = .identity
			}, completion: completion)
		}
	}

	/// Plays the fade and scale animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playFadeAndScaleAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		view.alpha = 0.0
		UIView.animate(withDuration: 0.5, animations: {
			view.alpha = 1.0
			view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
		}, completion: completion)
	}
}
