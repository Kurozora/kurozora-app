//
//  KMarqueeLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A label that auto-scrolls horizontally when its text exceeds the available width.
///
/// The scroll cycle is:
/// 1. Pause at the initial position (configurable via ``restartDelay``)
/// 2. Scroll continuously with a seamless loop (duplicate text trails the original)
/// 3. Decelerate smoothly near the end of one complete round
/// 4. Stop precisely at the initial alignment, pause, then repeat
final class KMarqueeLabel: UIView {
	// MARK: - Properties
	/// The text displayed by the label.
	var text: String? {
		didSet {
			self.primaryLabel.text = self.text
			self.secondaryLabel.text = self.text
			self.invalidateIntrinsicContentSize()
			self.setNeedsLayout()
		}
	}

	/// The font of the label text.
	var font: UIFont! {
		get { self.primaryLabel.font }
		set {
			self.primaryLabel.font = newValue
			self.secondaryLabel.font = newValue
			self.invalidateIntrinsicContentSize()
			self.setNeedsLayout()
		}
	}

	/// The color of the label text.
	var textColor: UIColor! {
		get { self.primaryLabel.textColor }
		set {
			self.primaryLabel.textColor = newValue
			self.secondaryLabel.textColor = newValue
		}
	}

	/// Inset from the leading edge in points.
	var leadingInset: CGFloat = 8 {
		didSet { self.setNeedsLayout() }
	}

	/// Gap between the end of the text and the start of the duplicate.
	var loopSpacing: CGFloat = 24 {
		didSet { self.setNeedsLayout() }
	}

	/// Fade width on the leading edge.
	var leadingFadeWidth: CGFloat = 8 {
		didSet { self.updateFadeMask() }
	}

	/// Fade width on the trailing edge.
	var trailingFadeWidth: CGFloat = 24 {
		didSet { self.updateFadeMask() }
	}

	/// Scroll speed in points per second.
	var scrollSpeed: CGFloat = 30

	/// Duration to wait before starting or restarting the scroll.
	var restartDelay: TimeInterval = 3

	private let containerView = UIView()
	private let primaryLabel = UILabel()
	private let secondaryLabel = UILabel()
	private let fadeMaskLayer = CAGradientLayer()

	private var textWidth: CGFloat = 0
	private var restartWorkItem: DispatchWorkItem?
	private let animationKey = "marqueeScroll"

	private var isRTL: Bool {
		self.effectiveUserInterfaceLayoutDirection == .rightToLeft
	}

	private var isOverflowing: Bool {
		self.textWidth > self.bounds.width - 2 * self.leadingInset
	}

	/// One full round = the width of the text plus the gap between repetitions.
	private var totalScrollDistance: CGFloat {
		self.textWidth + self.loopSpacing
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		self.containerView.layer.removeAllAnimations()
		self.restartWorkItem?.cancel()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		guard self.bounds.width > 0 else { return }

		let size = self.primaryLabel.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: self.bounds.height))
		self.textWidth = ceil(size.width)

		self.primaryLabel.frame = CGRect(x: 0, y: 0, width: self.textWidth, height: self.bounds.height)

		if self.isOverflowing {
			self.secondaryLabel.isHidden = false
			let offset = self.isRTL ? -(self.textWidth + self.loopSpacing) : (self.textWidth + self.loopSpacing)
			self.secondaryLabel.frame = CGRect(x: offset, y: 0, width: self.textWidth, height: self.bounds.height)
		} else {
			self.secondaryLabel.isHidden = true
		}

		if self.isRTL {
			self.containerView.frame = CGRect(
				x: self.bounds.width - self.leadingInset - self.textWidth,
				y: 0,
				width: self.textWidth,
				height: self.bounds.height
			)
		} else {
			self.containerView.frame = CGRect(
				x: self.leadingInset,
				y: 0,
				width: self.textWidth,
				height: self.bounds.height
			)
		}

		self.updateFadeMask()
		self.restartAnimationIfNeeded()
	}

	override var intrinsicContentSize: CGSize {
		return self.primaryLabel.intrinsicContentSize
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()

		if self.window != nil {
			self.restartAnimationIfNeeded()
		} else {
			self.stopAnimation()
		}
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		if self.traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
			self.setNeedsLayout()
		}
	}

	// MARK: - Functions
	/// Resets the label for reuse in a collection or table view cell.
	func resetForReuse() {
		self.stopAnimation()
		self.text = nil
	}

	private func sharedInit() {
		self.clipsToBounds = true
		self.isUserInteractionEnabled = false

		self.containerView.clipsToBounds = false
		self.addSubview(self.containerView)

		for label in [self.primaryLabel, self.secondaryLabel] {
			label.numberOfLines = 1
			self.containerView.addSubview(label)
		}

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.reduceMotionDidChange),
			name: UIAccessibility.reduceMotionStatusDidChangeNotification,
			object: nil
		)
	}

	@objc private func reduceMotionDidChange() {
		self.restartAnimationIfNeeded()
	}

	private func updateFadeMask() {
		guard self.bounds.width > 0 else { return }

		if self.isOverflowing {
			CATransaction.begin()
			CATransaction.setDisableActions(true)

			self.fadeMaskLayer.frame = self.bounds

			let leadFade = self.isRTL ? self.trailingFadeWidth : self.leadingFadeWidth
			let trailFade = self.isRTL ? self.leadingFadeWidth : self.trailingFadeWidth
			let leadStop = leadFade / self.bounds.width
			let trailStop = 1.0 - trailFade / self.bounds.width

			self.fadeMaskLayer.colors = [
				UIColor.clear.cgColor,
				UIColor.black.cgColor,
				UIColor.black.cgColor,
				UIColor.clear.cgColor
			]
			self.fadeMaskLayer.locations = [
				0,
				NSNumber(value: Float(leadStop)),
				NSNumber(value: Float(trailStop)),
				1
			]
			self.fadeMaskLayer.startPoint = CGPoint(x: 0, y: 0.5)
			self.fadeMaskLayer.endPoint = CGPoint(x: 1, y: 0.5)
			self.layer.mask = self.fadeMaskLayer

			CATransaction.commit()
		} else {
			self.layer.mask = nil
		}
	}

	private func restartAnimationIfNeeded() {
		self.stopAnimation()

		guard self.window != nil, self.isOverflowing else { return }

		self.scheduleAnimation()
	}

	private func scheduleAnimation() {
		let workItem = DispatchWorkItem { [weak self] in
			self?.startAnimation()
		}
		self.restartWorkItem = workItem
		DispatchQueue.main.asyncAfter(deadline: .now() + self.restartDelay, execute: workItem)
	}

	private func startAnimation() {
		let distance = self.totalScrollDistance
		let direction: CGFloat = self.isRTL ? 1 : -1

		// 80% of the duration at constant speed, 20% decelerating.
		// Phase 1 (linear):  covers 8/9 of the distance in 80% of the time.
		// Phase 2 (easeOut): covers 1/9 of the distance in 20% of the time.
		// Total duration = distance / (0.9 × speed).
		let totalDuration = TimeInterval(distance / (0.9 * self.scrollSpeed))
		let constantDistance = distance * (8.0 / 9.0)

		// Custom bezier so the speed is continuous at the phase boundary:
		//   dy/dx|₀ = c1y / c1x = 2  (matches constant-phase speed)
		//   dy/dx|₁ = (1−c2y) / (1−c2x) = 0  (full stop)
		let decelerationTiming = CAMediaTimingFunction(controlPoints: 0.35, 0.7, 0.65, 1.0)

		let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
		animation.values = [
			0,
			direction * constantDistance,
			direction * distance
		]
		animation.keyTimes = [0, 0.8, 1.0]
		animation.timingFunctions = [
			CAMediaTimingFunction(name: .linear),
			decelerationTiming
		]
		animation.duration = totalDuration
		animation.fillMode = .forwards
		animation.isRemovedOnCompletion = false
		animation.delegate = self

		self.containerView.layer.add(animation, forKey: self.animationKey)
	}

	private func stopAnimation() {
		self.restartWorkItem?.cancel()
		self.restartWorkItem = nil
		self.containerView.layer.removeAnimation(forKey: self.animationKey)
	}
}

// MARK: - CAAnimationDelegate
extension KMarqueeLabel: CAAnimationDelegate {
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		guard flag else { return }

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		self.containerView.layer.removeAnimation(forKey: self.animationKey)
		CATransaction.commit()

		self.scheduleAnimation()
	}
}
