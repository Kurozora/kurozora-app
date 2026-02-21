//
//  Animation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

enum AnimationLoopMode {
	case once
	case finite(Int)
	case infinite
}

struct AnimationPlaybackConfiguration {
	let loopMode: AnimationLoopMode
	let delayBetweenLoops: TimeInterval
	let initialDelay: TimeInterval
	let isInterruptible: Bool
	let playbackID: UUID

	init(
		loopMode: AnimationLoopMode = .once,
		delayBetweenLoops: TimeInterval = 0.0,
		initialDelay: TimeInterval = 0.0,
		isInterruptible: Bool = true,
		playbackID: UUID = UUID()
	) {
		self.loopMode = loopMode
		self.delayBetweenLoops = delayBetweenLoops
		self.initialDelay = initialDelay
		self.isInterruptible = isInterruptible
		self.playbackID = playbackID
	}

	static var `default`: AnimationPlaybackConfiguration {
		return AnimationPlaybackConfiguration()
	}
}

@MainActor
final class Animation {
	// MARK: Properties
	/// The shared instance of `Animation`.
	static let shared = Animation()

	private var playbackTasks: [UUID: Task<Void, Never>] = [:]
	private var playbackViews: [UUID: WeakView] = [:]

	// MARK: Initializers
	private init() {
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
	func playAnimation(
		on view: UIView,
		completion: ((Bool) -> Void)?
	) {
		self.playAnimation(on: view, configuration: .default, completion: completion)
	}

	/// Plays the selected animation using a configurable playback loop.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - configuration: The playback configuration.
	///    - completion: The completion handler to call when the animation is finished or cancelled.
	func playAnimation(
		on view: UIView,
		configuration: AnimationPlaybackConfiguration,
		completion: ((Bool) -> Void)?
	) {
		let playbackID = configuration.playbackID
		if self.playbackTasks[playbackID] != nil {
			guard configuration.isInterruptible else { return }
			self.cancelPlayback(with: playbackID)
		}

		let weakView = WeakView(view)
		let task = Task { @MainActor [weak self] in
			guard let self = self else {
				completion?(false)
				return
			}

			let finished = await self.performPlayback(
				viewProvider: { weakView.view },
				configuration: configuration
			)
			completion?(finished)
		}

		self.playbackViews[playbackID] = weakView
		self.playbackTasks[playbackID] = task
	}

	/// Cancels an active playback task associated with a playback identifier.
	///
	/// - Parameter playbackID: The identifier associated with the playback task.
	func cancelPlayback(with playbackID: UUID) {
		if let view = self.playbackViews[playbackID]?.view {
			self.stopAnimations(on: view)
		}
		self.playbackTasks[playbackID]?.cancel()
		self.playbackTasks[playbackID] = nil
		self.playbackViews[playbackID] = nil
	}

	/// Cancels all active playback tasks.
	func cancelAllPlayback() {
		let playbackIDs = Array(self.playbackTasks.keys)
		for playbackID in playbackIDs {
			self.cancelPlayback(with: playbackID)
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

// MARK: - Playback helpers
private extension Animation {
	final class WeakView {
		weak var view: UIView?

		init(_ view: UIView?) {
			self.view = view
		}
	}

	var shouldReduceMotion: Bool {
		return UserSettings.isReduceMotionEnabled || UIAccessibility.isReduceMotionEnabled
	}

	func performPlayback(
		viewProvider: @escaping @MainActor () -> UIView?,
		configuration: AnimationPlaybackConfiguration
	) async -> Bool {
		if configuration.initialDelay > 0.0, !(await self.sleep(for: configuration.initialDelay)) {
			return false
		}

		let requestedLoopCount: Int? = {
			switch configuration.loopMode {
			case .once:
				return 1
			case .finite(let count):
				return max(1, count)
			case .infinite:
				return nil
			}
		}()

		var currentLoopCount = 0
		while !Task.isCancelled {
			guard let view = viewProvider() else { return false }
			let didFinishCurrentLoop = await self.playSelectedAnimation(on: view)
			guard didFinishCurrentLoop, !Task.isCancelled else { return false }

			currentLoopCount += 1
			if let requestedLoopCount, currentLoopCount >= requestedLoopCount {
				return true
			}

			if configuration.delayBetweenLoops > 0.0, !(await self.sleep(for: configuration.delayBetweenLoops)) {
				return false
			}
		}

		return false
	}

	func sleep(for delay: TimeInterval) async -> Bool {
		let nanoseconds = UInt64(delay * 1_000_000_000)
		do {
			try await Task.sleep(nanoseconds: nanoseconds)
			return !Task.isCancelled
		} catch {
			return false
		}
	}

	func playSelectedAnimation(on view: UIView) async -> Bool {
		return await withCheckedContinuation { continuation in
			self.playAnimationPass(on: view) { finished in
				continuation.resume(returning: finished)
			}
		}
	}

	/// Plays the selected animation once.
	func playAnimationPass(on view: UIView, completion: ((Bool) -> Void)?) {
		// Check accessibility settings
		if self.shouldReduceMotion {
			self.playNoneAnimation(on: view, completion: completion)
			return
		}

		switch UserSettings.currentSplashScreenAnimation {
		case .none:
			self.playNoneAnimation(on: view, completion: completion)
		case .default:
			self.playDefaultAnimation(on: view, completion: completion)
		case .shake:
			self.playShakeAnimation(on: view, completion: completion)
		case .scale:
			self.playScaleAnimation(on: view, completion: completion)
		case .anvil:
			self.playAnvilAnimation(on: view, completion: completion)
		case .spin:
			self.playSpinAnimation(on: view, completion: completion)
		case .heartbeat:
			self.playHeartbeatAnimation(on: view, completion: completion)
		case .bounce:
			self.playBounceAnimation(on: view, completion: completion)
		}
	}

	func stopAnimations(on view: UIView) {
		view.layer.removeAllAnimations()
		view.transform = .identity
		view.alpha = 1.0
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
		view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		view.alpha = 0.0

		if UserSettings.hapticsAllowed {
			let lightImpact = UIImpactFeedbackGenerator(style: .light)
			let mediumImpact = UIImpactFeedbackGenerator(style: .medium)

			lightImpact.prepare()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				lightImpact.impactOccurred(intensity: 0.6)
				mediumImpact.prepare()
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
				mediumImpact.impactOccurred(intensity: 0.8)
			}
		}

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
		view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		view.alpha = 0

		if UserSettings.hapticsAllowed {
			let lightImpact = UIImpactFeedbackGenerator(style: .light)
			let mediumImpact = UIImpactFeedbackGenerator(style: .medium)

			lightImpact.prepare()

			let spinPulses = [0.0, 0.15, 0.35, 0.6]
			for delay in spinPulses {
				DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
					lightImpact.impactOccurred(intensity: 0.5)
					lightImpact.prepare()
				}
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
				mediumImpact.impactOccurred(intensity: 1.0)
			}
		}

		let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
		rotation.fromValue = 0
		rotation.toValue = Double.pi * 12 // 6 full fast revolutions
		rotation.duration = 0.8
		rotation.timingFunction = CAMediaTimingFunction(name: .easeOut)
		view.layer.add(rotation, forKey: "spin")

		UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
			view.alpha = 1.0
			view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
		}) { _ in
			UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
				view.transform = .identity
			}, completion: { finished in
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					completion?(finished)
				}
			})
		}
	}

	/// Plays the shake animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playShakeAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		if UserSettings.hapticsAllowed {
			let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
			mediumImpact.prepare()

			let delays = [0.0, 0.1, 0.2]
			let intensities: [CGFloat] = [1.0, 0.7, 0.4]

			for (index, delay) in delays.enumerated() {
				DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
					mediumImpact.impactOccurred(intensity: intensities[index])
				}
			}
		}

		UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeCubicPaced], animations: {
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
				view.transform = CGAffineTransform(translationX: 20, y: 0)
			}
			UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
				view.transform = CGAffineTransform(translationX: -16, y: 0)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2) {
				view.transform = CGAffineTransform(translationX: 12, y: 0)
			}
			UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.2) {
				view.transform = CGAffineTransform(translationX: -6, y: 0)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
				view.transform = .identity
			}

		}, completion: { finished in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				completion?(finished)
			}
		})
	}

	/// Plays the scale animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playScaleAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		view.alpha = 0.0

		if UserSettings.hapticsAllowed {
			let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
			mediumImpact.prepare()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
				mediumImpact.impactOccurred(intensity: 0.9)
			}
		}

		UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeCubic], animations: {
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.7) {
				view.alpha = 1.0
				view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
				view.transform = .identity
			}
		}, completion: { finished in
			completion?(finished)
		})
	}

	/// Plays the anvil animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playAnvilAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		view.transform = CGAffineTransform(translationX: 0, y: -800)
		view.alpha = 0

		if UserSettings.hapticsAllowed {
			let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
			heavyImpact.prepare()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
				heavyImpact.impactOccurred(intensity: 1.0)
				heavyImpact.prepare()
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.39) {
				heavyImpact.impactOccurred(intensity: 0.7)
			}
		}

		UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseIn], animations: {
			view.alpha = 1.0
			view.transform = .identity
		}) { _ in
			UIView.animate(withDuration: 0.05, animations: {
				view.superview?.transform = CGAffineTransform(translationX: 0, y: 8)
			}) { _ in
				UIView.animate(withDuration: 0.05, animations: {
					view.superview?.transform = .identity
				}, completion: { finished in
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
						completion?(finished)
					}
				})
			}
		}
	}

	/// Plays the heartbeat animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playHeartbeatAnimation(on view: UIView, completion: ((Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		if UserSettings.hapticsAllowed {
			let lightImpact = UIImpactFeedbackGenerator(style: .light)
			let mediumImpact = UIImpactFeedbackGenerator(style: .medium)

			lightImpact.prepare()
			mediumImpact.prepare()

			lightImpact.impactOccurred()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				mediumImpact.impactOccurred()
			}
		}

		UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [], animations: {
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.15) {
				view.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.15, relativeDuration: 0.15) {
				view.transform = .identity
			}

			UIView.addKeyframe(withRelativeStartTime: 0.30, relativeDuration: 0.15) {
				view.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.45, relativeDuration: 0.2) {
				view.transform = .identity
			}
		}, completion: { finished in
			completion?(finished)
		})
	}

	/// Plays the bounce animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - velocity: The initial velocity of the bounce (default is 1.0, higher values create a more exaggerated bounce).
	///    - completion: The completion handler to call when the animation is finished.
	func playBounceAnimation(on view: UIView, velocity: CGFloat = 1.0, completion: ((Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
		mediumImpact.prepare()

		UIView.animate(withDuration: 0.15 * velocity, delay: 0, options: .curveEaseOut, animations: {
			let jumpHeight = -40.0 * velocity
			view.transform = CGAffineTransform(translationX: 0, y: jumpHeight).scaledBy(x: 0.95, y: 1.05)
		}) { _ in
			let fallDuration = 0.1 * velocity

			if UserSettings.hapticsAllowed {
				DispatchQueue.main.asyncAfter(deadline: .now() + fallDuration) {
					mediumImpact.impactOccurred(intensity: CGFloat(velocity))
					mediumImpact.prepare()
				}
			}

			UIView.animate(withDuration: fallDuration, delay: 0, options: .curveEaseIn, animations: {
				view.transform = .identity
			}) { _ in
				UIView.animate(withDuration: 0.05, animations: {
					view.transform = CGAffineTransform(scaleX: 1.15, y: 0.85)
				}) { _ in
					let nextVelocity = velocity * 0.5

					if nextVelocity > 0.1 {
						self.playBounceAnimation(on: view, velocity: nextVelocity, completion: completion)
					} else {
						UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, animations: {
							view.transform = .identity
						}, completion: { finished in
							completion?(finished)
						})
					}
				}
			}
		}
	}
}
