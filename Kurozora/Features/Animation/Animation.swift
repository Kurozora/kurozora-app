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

	/// The prefix naming layers an animation installs.
	static let installedLayerPrefix = "app.kurozora.animation."

	private var playbackTasks: [UUID: Task<Void, Never>] = [:]
	private var playbackViews: [UUID: WeakView] = [:]

	/// The animation the splash will play.
	var selectedAnimation: SplashScreenAnimation {
		if self.shouldReduceMotion {
			return .none
		}

		return UserSettings.currentSplashScreenAnimation
	}

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
		completion: (@MainActor @Sendable (Bool) -> Void)?
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
		completion: (@MainActor @Sendable (Bool) -> Void)?
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
	func playAnimationPass(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
		switch self.selectedAnimation {
		case .none:
			self.playNoneAnimation(on: view, completion: completion)
		case .default:
			self.playDefaultAnimation(on: view, completion: completion)
		case .furin:
			self.playFurinAnimation(on: view, completion: completion)
		case .iai:
			self.playIaiAnimation(on: view, completion: completion)
		case .shake:
			self.playShakeAnimation(on: view, completion: completion)
		case .shishiOdoshi:
			self.playShishiOdoshiAnimation(on: view, completion: completion)
		case .sumie:
			self.playSumieAnimation(on: view, completion: completion)
		case .gleam:
			self.playGleamAnimation(on: view, completion: completion)
		case .glitch:
			self.playGlitchAnimation(on: view, completion: completion)
		case .impact:
			self.playImpactAnimation(on: view, completion: completion)
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
		view.layer.mask?.removeAllAnimations()
		view.layer.mask = nil

		let hosted = (view.layer.sublayers ?? []) + (view.superview?.layer.sublayers ?? [])

		for layer in hosted where layer.name?.hasPrefix(Animation.installedLayerPrefix) == true {
			layer.removeAllAnimations()
			layer.removeFromSuperlayer()
		}

		view.transform = .identity
		view.alpha = 1.0
	}

	/// The blend mode that keeps an added color visible against the current theme.
	var contrastingBlendMode: String {
		let background = KThemePicker.backgroundColor.colorValue
		var red: CGFloat = 0.0
		var green: CGFloat = 0.0
		var blue: CGFloat = 0.0
		var alpha: CGFloat = 0.0

		guard background.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return "screenBlendMode" }

		let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue

		return luminance > 0.5 ? "multiplyBlendMode" : "screenBlendMode"
	}

	/// Returns the rect the view's image is drawn into.
	///
	/// - Parameter view: The view holding the image.
	///
	/// - Returns: The rect in the view's coordinate space.
	func contentRect(of view: UIView) -> CGRect {
		let bounds = CGRect(origin: .zero, size: view.bounds.size)

		guard
			let imageView = view as? UIImageView,
			imageView.contentMode == .scaleAspectFit,
			let size = imageView.image?.size,
			size.width > 0.0,
			size.height > 0.0
		else { return bounds }

		let scale = min(bounds.width / size.width, bounds.height / size.height)
		let fitted = CGSize(width: size.width * scale, height: size.height * scale)

		return CGRect(
			x: bounds.midX - fitted.width / 2.0,
			y: bounds.midY - fitted.height / 2.0,
			width: fitted.width,
			height: fitted.height
		)
	}

	/// Returns a layer clipping to the logo's silhouette.
	///
	/// - Parameter view: The view whose silhouette is wanted.
	///
	/// - Returns: The mask layer.
	func silhouetteMask(for view: UIView) -> CALayer? {
		guard let image = (view as? UIImageView)?.image?.cgImage else { return nil }

		let mask = CALayer()
		mask.frame = self.contentRect(of: view)
		mask.contents = image
		mask.contentsGravity = .resize

		return mask
	}

	/// Adds a layer that `stopAnimations(on:)` will tear down.
	///
	/// - Parameters:
	///    - layer: The layer to install.
	///    - view: The view to install it on.
	///    - name: The name identifying the layer.
	func install(_ layer: CALayer, on view: UIView, named name: String) {
		layer.name = Animation.installedLayerPrefix + name
		view.layer.addSublayer(layer)
	}

	/// Adds a layer alongside the view that `stopAnimations(on:)` will tear down.
	///
	/// - Parameters:
	///    - layer: The layer to install.
	///    - view: The view to install it beside.
	///    - name: The name identifying the layer.
	func installBeside(_ layer: CALayer, on view: UIView, named name: String) {
		layer.name = Animation.installedLayerPrefix + name
		view.superview?.layer.addSublayer(layer)
	}

	/// Returns the logo clipped to one side of a diagonal cut.
	///
	/// - Parameters:
	///    - image: The logo artwork.
	///    - size: The size of the canvas to render into.
	///    - contentRect: The rect within the canvas the artwork occupies.
	///    - angle: The angle of the cut in radians.
	///    - isLeading: Whether the side on the cut's leading normal is kept.
	///
	/// - Returns: The clipped artwork.
	func cutHalf(of image: UIImage, size: CGSize, contentRect: CGRect, angle: CGFloat, isLeading: Bool) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: size)

		return renderer.image { context in
			let reach = (size.width + size.height) * 2.0
			let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
			let along = CGPoint(x: cos(angle), y: sin(angle))
			let sign: CGFloat = isLeading ? 1.0 : -1.0
			let across = CGPoint(x: -along.y * sign, y: along.x * sign)

			let path = UIBezierPath()
			path.move(to: CGPoint(x: center.x - along.x * reach, y: center.y - along.y * reach))
			path.addLine(to: CGPoint(x: center.x + along.x * reach, y: center.y + along.y * reach))
			path.addLine(to: CGPoint(x: center.x + along.x * reach + across.x * reach, y: center.y + along.y * reach + across.y * reach))
			path.addLine(to: CGPoint(x: center.x - along.x * reach + across.x * reach, y: center.y - along.y * reach + across.y * reach))
			path.close()

			context.cgContext.saveGState()
			path.addClip()
			image.draw(in: contentRect)
			context.cgContext.restoreGState()
		}
	}
}

// MARK: - Animations
private extension Animation {
	/// Plays no animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playNoneAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		DispatchQueue.main.asyncAfter(deadline: .now() + SplashScreenAnimation.none.duration) {
			completion?(true)
		}
	}

	/// Plays the default animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playDefaultAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
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

	/// Returns a transform that rotates a view about a point on its vertical center line.
	///
	/// - Parameters:
	///    - degrees: The rotation in degrees.
	///    - offset: The distance from the view's center to the pivot.
	///
	/// - Returns: The composed transform.
	func rotation(_ degrees: CGFloat, aboutPivotOffset offset: CGFloat) -> CGAffineTransform {
		return CGAffineTransform(translationX: 0.0, y: offset)
			.rotated(by: degrees * .pi / 180.0)
			.translatedBy(x: 0.0, y: -offset)
	}

	/// Plays the furin animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playFurinAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		let pivot = -view.bounds.height / 2.0

		if UserSettings.hapticsAllowed {
			let lightImpact = UIImpactFeedbackGenerator(style: .light)
			lightImpact.prepare()

			let strikes: [(delay: TimeInterval, intensity: CGFloat)] = [(0.12, 0.7), (0.30, 0.5), (0.48, 0.35), (0.66, 0.2)]

			for strike in strikes {
				DispatchQueue.main.asyncAfter(deadline: .now() + strike.delay) {
					lightImpact.impactOccurred(intensity: strike.intensity)
					lightImpact.prepare()
				}
			}
		}

		UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: [.calculationModeCubic], animations: {
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0923) {
				view.transform = self.rotation(14.0, aboutPivotOffset: pivot)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.0923, relativeDuration: 0.1385) {
				view.transform = self.rotation(-10.0, aboutPivotOffset: pivot)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.2308, relativeDuration: 0.1385) {
				view.transform = self.rotation(7.0, aboutPivotOffset: pivot)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.3692, relativeDuration: 0.1385) {
				view.transform = self.rotation(-4.5, aboutPivotOffset: pivot)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.5077, relativeDuration: 0.1385) {
				view.transform = self.rotation(2.8, aboutPivotOffset: pivot)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.6462, relativeDuration: 0.1385) {
				view.transform = self.rotation(-1.6, aboutPivotOffset: pivot)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.7846, relativeDuration: 0.2154) {
				view.transform = .identity
			}
		}, completion: { finished in
			MainActor.assumeIsolated {
				completion?(finished)
			}
		})
	}

	/// Returns a mask whose alpha ramps across a diagonal with an irregular edge.
	///
	/// - Parameter size: The width and height of the generated image in pixels.
	///
	/// - Returns: The generated image.
	func inkWipeMask(size: Int) -> CGImage? {
		var pixels = [UInt8](repeating: 0, count: size * size * 4)

		let seedCount = 14
		let seeds = (0 ..< seedCount).map { _ in CGFloat.random(in: -0.05 ... 0.05) }

		for y in 0 ..< size {
			let vertical = CGFloat(y) / CGFloat(size - 1)
			let position = vertical * CGFloat(seedCount - 1)
			let index = min(Int(position), seedCount - 2)
			let fraction = position - CGFloat(index)
			let eased = fraction * fraction * (3.0 - 2.0 * fraction)
			let noise = seeds[index] + (seeds[index + 1] - seeds[index]) * eased

			for x in 0 ..< size {
				let horizontal = CGFloat(x) / CGFloat(size - 1)
				let distance = horizontal + (vertical - 0.5) * 0.18 + noise
				let ramp = min(max((distance - 0.38) / 0.24, 0.0), 1.0)
				let alpha = UInt8(ramp * ramp * (3.0 - 2.0 * ramp) * 255.0)
				let offset = (y * size + x) * 4

				pixels[offset] = alpha
				pixels[offset + 1] = alpha
				pixels[offset + 2] = alpha
				pixels[offset + 3] = alpha
			}
		}

		return pixels.withUnsafeMutableBytes { buffer -> CGImage? in
			guard let context = CGContext(
				data: buffer.baseAddress,
				width: size,
				height: size,
				bitsPerComponent: 8,
				bytesPerRow: size * 4,
				space: CGColorSpaceCreateDeviceRGB(),
				bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
			) else { return nil }

			return context.makeImage()
		}
	}

	/// Plays the gleam animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playGleamAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		guard let silhouette = self.silhouetteMask(for: view) else {
			self.playNoneAnimation(on: view, completion: completion)
			return
		}

		let shine = KThemePicker.tintColor.colorValue

		let band = CAGradientLayer()
		band.frame = view.bounds
		band.colors = [
			shine.withAlphaComponent(0.0).cgColor,
			shine.withAlphaComponent(0.95).cgColor,
			shine.withAlphaComponent(0.0).cgColor
		]
		band.startPoint = CGPoint(x: 0.0, y: 0.0)
		band.endPoint = CGPoint(x: 1.0, y: 1.0)
		band.locations = [1.05, 1.2, 1.35]
		band.mask = silhouette

		self.install(band, on: view, named: "gleam")

		if UserSettings.hapticsAllowed {
			let softImpact = UIImpactFeedbackGenerator(style: .soft)
			softImpact.prepare()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
				softImpact.impactOccurred(intensity: 0.45)
			}
		}

		let sweep = CABasicAnimation(keyPath: "locations")
		sweep.fromValue = [-0.35, -0.2, -0.05]
		sweep.toValue = [1.05, 1.2, 1.35]
		sweep.duration = 0.9
		sweep.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		band.add(sweep, forKey: "sweep")

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
			band.removeFromSuperlayer()
			completion?(true)
		}
	}

	/// Plays the glitch animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playGlitchAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		guard
			let cyanMask = self.silhouetteMask(for: view),
			let magentaMask = self.silhouetteMask(for: view)
		else {
			self.playNoneAnimation(on: view, completion: completion)
			return
		}

		let blendMode = self.contrastingBlendMode

		let cyan = CALayer()
		cyan.frame = view.bounds
		cyan.backgroundColor = UIColor.cyan.cgColor
		cyan.mask = cyanMask
		cyan.opacity = 0.0
		cyan.compositingFilter = blendMode

		let magenta = CALayer()
		magenta.frame = view.bounds
		magenta.backgroundColor = UIColor.magenta.cgColor
		magenta.mask = magentaMask
		magenta.opacity = 0.0
		magenta.compositingFilter = blendMode

		self.install(cyan, on: view, named: "glitch.cyan")
		self.install(magenta, on: view, named: "glitch.magenta")

		if UserSettings.hapticsAllowed {
			let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
			rigidImpact.prepare()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				rigidImpact.impactOccurred(intensity: 0.8)
			}
		}

		let offsets: [CGFloat] = [0.0, -6.0, 5.0, -4.0, 3.0, 0.0]
		let opacities: [Float] = [0.0, 0.9, 0.9, 0.75, 0.55, 0.0]
		let keyTimes = (0 ..< offsets.count).map { NSNumber(value: Double($0) / Double(offsets.count - 1)) }

		self.applyDiscreteKeyframes(
			on: cyan,
			transforms: offsets.map { CATransform3DMakeTranslation($0, 0.0, 0.0) },
			opacities: opacities,
			keyTimes: keyTimes,
			duration: 0.6
		)

		self.applyDiscreteKeyframes(
			on: magenta,
			transforms: offsets.map { CATransform3DMakeTranslation(-$0, 0.0, 0.0) },
			opacities: opacities,
			keyTimes: keyTimes,
			duration: 0.6
		)

		UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: [.calculationModeDiscrete], animations: {
			for step in 0 ..< offsets.count {
				UIView.addKeyframe(withRelativeStartTime: Double(step) / Double(offsets.count), relativeDuration: 1.0 / Double(offsets.count)) {
					view.transform = CGAffineTransform(translationX: offsets[step] * 0.3, y: 0.0)
				}
			}
		}, completion: { finished in
			MainActor.assumeIsolated {
				cyan.removeFromSuperlayer()
				magenta.removeFromSuperlayer()
				view.transform = .identity
				completion?(finished)
			}
		})
	}

	/// Applies stepped transform and opacity keyframes to a layer.
	///
	/// - Parameters:
	///    - layer: The layer to animate.
	///    - transforms: The transform at each step.
	///    - opacities: The opacity at each step.
	///    - keyTimes: The normalized time of each step.
	///    - duration: The length of the animation.
	func applyDiscreteKeyframes(on layer: CALayer, transforms: [CATransform3D], opacities: [Float], keyTimes: [NSNumber], duration: TimeInterval) {
		let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
		transformAnimation.values = transforms.map { NSValue(caTransform3D: $0) }
		transformAnimation.keyTimes = keyTimes
		transformAnimation.calculationMode = .discrete
		transformAnimation.duration = duration

		let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
		opacityAnimation.values = opacities
		opacityAnimation.keyTimes = keyTimes
		opacityAnimation.calculationMode = .discrete
		opacityAnimation.duration = duration

		layer.add(transformAnimation, forKey: "glitch.transform")
		layer.add(opacityAnimation, forKey: "glitch.opacity")
	}

	/// Plays the impact animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playImpactAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		let bounds = view.bounds
		let extent = max(bounds.width, bounds.height)

		guard extent > 0.0 else {
			self.playNoneAnimation(on: view, completion: completion)
			return
		}

		let center = CGPoint(x: bounds.midX, y: bounds.midY)
		let inner = extent * 0.62
		let outer = extent * 1.15
		let path = CGMutablePath()

		for index in 0 ..< 18 {
			let angle = (CGFloat(index) / 18.0) * 2.0 * .pi + CGFloat.random(in: -0.06 ... 0.06)
			let spread = CGFloat.random(in: 0.012 ... 0.030)
			let tip = outer * CGFloat.random(in: 0.72 ... 1.0)

			path.move(to: CGPoint(x: center.x + cos(angle - spread) * inner, y: center.y + sin(angle - spread) * inner))
			path.addLine(to: CGPoint(x: center.x + cos(angle + spread) * inner, y: center.y + sin(angle + spread) * inner))
			path.addLine(to: CGPoint(x: center.x + cos(angle) * tip, y: center.y + sin(angle) * tip))
			path.closeSubpath()
		}

		let lines = CAShapeLayer()
		lines.frame = bounds
		lines.path = path
		lines.fillColor = view.tintColor.cgColor
		lines.opacity = 0.0

		self.install(lines, on: view, named: "impact")

		if UserSettings.hapticsAllowed {
			let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
			heavyImpact.prepare()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
				heavyImpact.impactOccurred(intensity: 1.0)
			}
		}

		let burstTimes: [NSNumber] = [0.0, 0.12, 0.75]

		let burstOpacity = CAKeyframeAnimation(keyPath: "opacity")
		burstOpacity.values = [0.0, 1.0, 0.0]
		burstOpacity.keyTimes = burstTimes
		burstOpacity.duration = 0.8
		burstOpacity.timingFunction = CAMediaTimingFunction(name: .easeOut)

		let burstScale = CAKeyframeAnimation(keyPath: "transform")
		burstScale.values = [
			NSValue(caTransform3D: CATransform3DMakeScale(0.3, 0.3, 1.0)),
			NSValue(caTransform3D: CATransform3DMakeScale(0.55, 0.55, 1.0)),
			NSValue(caTransform3D: CATransform3DMakeScale(1.5, 1.5, 1.0))
		]
		burstScale.keyTimes = burstTimes
		burstScale.duration = 0.8
		burstScale.timingFunction = CAMediaTimingFunction(name: .easeOut)

		lines.add(burstOpacity, forKey: "impact.opacity")
		lines.add(burstScale, forKey: "impact.transform")

		UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [.calculationModeCubic], animations: {
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.15) {
				view.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.15, relativeDuration: 0.85) {
				view.transform = .identity
			}
		}, completion: { finished in
			MainActor.assumeIsolated {
				lines.removeFromSuperlayer()
				completion?(finished)
			}
		})
	}

	/// Plays the sumie animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playSumieAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0
		view.layer.mask = nil

		let width = view.bounds.width
		let height = view.bounds.height

		guard width > 0.0, height > 0.0, let maskImage = self.inkWipeMask(size: 256) else {
			self.playNoneAnimation(on: view, completion: completion)
			return
		}

		let maskLayer = CALayer()
		maskLayer.contents = maskImage
		maskLayer.contentsGravity = .resize
		maskLayer.bounds = CGRect(x: 0.0, y: 0.0, width: width * 3.0, height: height)
		maskLayer.position = CGPoint(x: width * 1.5, y: height / 2.0)
		view.layer.mask = maskLayer

		if UserSettings.hapticsAllowed {
			let softImpact = UIImpactFeedbackGenerator(style: .soft)
			let lightImpact = UIImpactFeedbackGenerator(style: .light)
			softImpact.prepare()
			softImpact.impactOccurred(intensity: 0.3)
			lightImpact.prepare()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
				lightImpact.impactOccurred(intensity: 0.5)
			}
		}

		let sweep = CABasicAnimation(keyPath: "position.x")
		sweep.fromValue = width * 1.5
		sweep.toValue = -width * 0.5
		sweep.duration = 0.85
		sweep.timingFunction = CAMediaTimingFunction(name: .easeOut)
		maskLayer.position = CGPoint(x: -width * 0.5, y: height / 2.0)
		maskLayer.add(sweep, forKey: "sweep")

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			view.layer.mask = nil
			completion?(true)
		}
	}

	/// Plays the shishi-odoshi animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playShishiOdoshiAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		let pivot = view.bounds.height / 2.0

		if UserSettings.hapticsAllowed {
			let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
			let lightImpact = UIImpactFeedbackGenerator(style: .light)
			heavyImpact.prepare()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
				heavyImpact.impactOccurred(intensity: 1.0)
				lightImpact.prepare()
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
				lightImpact.impactOccurred(intensity: 0.3)
			}
		}

		UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: [.calculationModeCubic], animations: {
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5167) {
				view.transform = self.rotation(-16.0, aboutPivotOffset: pivot)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.5167, relativeDuration: 0.0833) {
				view.transform = self.rotation(-16.0, aboutPivotOffset: pivot)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.15) {
				view.transform = self.rotation(4.0, aboutPivotOffset: pivot).scaledBy(x: 1.04, y: 0.94)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.125) {
				view.transform = self.rotation(-2.0, aboutPivotOffset: pivot)
			}

			UIView.addKeyframe(withRelativeStartTime: 0.875, relativeDuration: 0.125) {
				view.transform = .identity
			}
		}, completion: { finished in
			MainActor.assumeIsolated {
				completion?(finished)
			}
		})
	}

	/// Plays the iai animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playIaiAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
		view.transform = .identity
		view.alpha = 1.0

		let size = view.bounds.size
		let angle: CGFloat = -28.0 * .pi / 180.0

		guard
			size.width > 0.0,
			size.height > 0.0,
			view.superview != nil,
			let artwork = (view as? UIImageView)?.image
		else {
			self.playNoneAnimation(on: view, completion: completion)
			return
		}

		let tint = view.tintColor ?? .white
		let across = CGPoint(x: -sin(angle), y: cos(angle))
		let content = self.contentRect(of: view)
		var halves: [CALayer] = []

		for isLeading in [true, false] {
			let half = CALayer()
			half.frame = view.frame
			half.backgroundColor = tint.cgColor
			half.opacity = 0.0

			let mask = CALayer()
			mask.frame = CGRect(origin: .zero, size: size)
			mask.contents = self.cutHalf(of: artwork, size: size, contentRect: content, angle: angle, isLeading: isLeading).cgImage
			mask.contentsGravity = .resize
			half.mask = mask

			self.installBeside(half, on: view, named: "iai.half\(isLeading)")
			halves.append(half)
		}

		let blade = CALayer()
		blade.bounds = CGRect(x: 0.0, y: 0.0, width: max(size.width, size.height) * 2.2, height: 2.0)
		blade.position = CGPoint(x: view.frame.midX, y: view.frame.midY)
		blade.backgroundColor = UIColor.white.cgColor
		blade.opacity = 0.0
		blade.setAffineTransform(CGAffineTransform(rotationAngle: angle))
		self.installBeside(blade, on: view, named: "iai.blade")

		if UserSettings.hapticsAllowed {
			let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
			let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
			heavyImpact.prepare()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				heavyImpact.impactOccurred(intensity: 1.0)
				rigidImpact.prepare()
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 1.02) {
				rigidImpact.impactOccurred(intensity: 0.5)
			}
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			view.alpha = 0.0

			for half in halves {
				half.opacity = 1.0
			}

			let flash = CAKeyframeAnimation(keyPath: "opacity")
			flash.values = [0.0, 1.0, 0.0]
			flash.keyTimes = [0.0, 0.25, 1.0]
			flash.duration = 0.16
			blade.add(flash, forKey: "flash")
		}

		let offset: CGFloat = 6.0
		let origin = CGPoint(x: view.frame.midX, y: view.frame.midY)

		for (index, half) in halves.enumerated() {
			let sign: CGFloat = index == 0 ? 1.0 : -1.0
			let parted = CGPoint(x: origin.x + across.x * offset * sign, y: origin.y + across.y * offset * sign)
			let crossed = CGPoint(x: origin.x - across.x * offset * sign * 0.25, y: origin.y - across.y * offset * sign * 0.25)

			let slide = CAKeyframeAnimation(keyPath: "position")
			slide.values = [origin, origin, parted, parted, crossed, origin, origin].map { NSValue(cgPoint: $0) }
			slide.keyTimes = [0.0, 0.383, 0.5, 0.733, 0.85, 0.9, 1.0]
			slide.timingFunctions = [
				CAMediaTimingFunction(name: .linear),
				CAMediaTimingFunction(name: .easeOut),
				CAMediaTimingFunction(name: .linear),
				CAMediaTimingFunction(name: .easeIn),
				CAMediaTimingFunction(name: .easeOut),
				CAMediaTimingFunction(name: .linear)
			]
			slide.duration = 1.2

			half.add(slide, forKey: "separation")
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
			view.alpha = 1.0
			blade.removeFromSuperlayer()

			for half in halves {
				half.removeFromSuperlayer()
			}

			completion?(true)
		}
	}

	/// Plays the spin animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playSpinAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
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
	func playShakeAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
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
	func playScaleAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
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
			MainActor.assumeIsolated {
				completion?(finished)
			}
		})
	}

	/// Plays the anvil animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - completion: The completion handler to call when the animation is finished.
	func playAnvilAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
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
	func playHeartbeatAnimation(on view: UIView, completion: (@MainActor @Sendable (Bool) -> Void)?) {
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
			MainActor.assumeIsolated {
				completion?(finished)
			}
		})
	}

	/// Plays the bounce animation.
	///
	/// - Parameters:
	///    - view: The view to animate.
	///    - velocity: The initial velocity of the bounce (default is 1.0, higher values create a more exaggerated bounce).
	///    - completion: The completion handler to call when the animation is finished.
	func playBounceAnimation(on view: UIView, velocity: CGFloat = 1.0, completion: (@MainActor @Sendable (Bool) -> Void)?) {
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
