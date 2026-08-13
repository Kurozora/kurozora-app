//
//  LyricsInterludeView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

final class LyricsInterludeView: UIView {
	// MARK: - Views
	private let dots: [UIView] = (0..<3).map { _ in
		let view = UIView()
		let diameter: CGFloat = 13
		view.theme_backgroundColor = KThemePicker.textColor.rawValue
		view.layer.cornerRadius = diameter / 2
		view.alpha = 0.25
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.widthAnchor.constraint(equalToConstant: diameter),
			view.heightAnchor.constraint(equalToConstant: diameter),
		])
		return view
	}

	private let stackView = UIStackView()

	// MARK: - Properties
	/// Whether the dots take the label color instead of the theme's text color.
	var prefersSystemColors = false {
		didSet {
			guard oldValue != self.prefersSystemColors else { return }
			self.dots.forEach { dot in
				dot.theme_backgroundColor = self.prefersSystemColors ? nil : KThemePicker.textColor.rawValue
				dot.backgroundColor = self.prefersSystemColors ? .label : KThemePicker.textColor.colorValue
			}
		}
	}

	private var isFinishing = false
	private var isShowing = false

	/// The duration of the closing breath, in seconds.
	private let finishDuration: CFTimeInterval = 0.7

	/// The lead before the next line at which the closing breath begins, in milliseconds.
	private let finishLeadMs = 800

	/// The gap length that maps to a single breath.
	private let breathBucketMs: Double = 9000

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureSubviews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	private func configureSubviews() {
		self.stackView.axis = .horizontal
		self.stackView.spacing = 13
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.dots.forEach { self.stackView.addArrangedSubview($0) }
		self.addSubview(self.stackView)

		NSLayoutConstraint.activate([
			self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.stackView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
			self.stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
		])
	}

	/// Fades the indicator in.
	func show() {
		guard !self.isShowing || self.isFinishing else { return }

		self.isShowing = true
		self.isHidden = false
		self.isFinishing = false
		self.stackView.layer.removeAllAnimations()
		self.stackView.transform = .identity
		self.stackView.alpha = 0

		UIView.animate(withDuration: 0.35) {
			self.stackView.alpha = 1
		}
	}

	/// Hides the indicator and stops its animation.
	func hide() {
		self.isShowing = false
		self.isHidden = true
		self.isFinishing = false
		self.stackView.layer.removeAllAnimations()
		self.stackView.layer.opacity = 1
		self.stackView.layer.transform = CATransform3DIdentity
	}

	/// Advances the breathing and dot fill to the given point in the gap.
	///
	/// - Parameters:
	///    - remainingMs: The time left in the gap before the next line, in milliseconds.
	///    - totalMs: The full duration of the gap, in milliseconds.
	func setProgress(remainingMs: Int, totalMs: Int) {
		if !self.isFinishing, remainingMs <= self.finishLeadMs {
			self.finishAndDisappear()
		}

		guard !self.isFinishing else { return }

		let breathSpanMs = max(1, totalMs - self.finishLeadMs)
		let elapsedMs = max(0, totalMs - remainingMs)
		let progress = min(1, CGFloat(elapsedMs) / CGFloat(breathSpanMs))

		for (index, dot) in self.dots.enumerated() {
			let local = max(0, min(1, (progress - CGFloat(index) / 3) * 3))
			dot.alpha = 0.25 + 0.75 * local
		}

		let breathCount = max(1, Int((Double(totalMs) / self.breathBucketMs).rounded(.up)))
		let withinBreath = (progress * CGFloat(breathCount)).truncatingRemainder(dividingBy: 1)
		let scale = self.breathScale(at: withinBreath)
		self.stackView.transform = CGAffineTransform(scaleX: scale, y: scale)
	}

	/// The dot scale at the given point within a single breath.
	///
	/// - Parameter progress: The progress through the breath, from `0` to `1`.
	///
	/// - Returns: The scale factor to apply to the dots.
	private func breathScale(at progress: CGFloat) -> CGFloat {
		let amplitude: CGFloat = 0.16
		let level: CGFloat

		if progress < 0.55 {
			level = Self.smoothstep(progress / 0.55)
		} else if progress < 0.63 {
			level = 1
		} else if progress < 0.78 {
			level = 1 - Self.smoothstep((progress - 0.63) / 0.15)
		} else {
			level = 0
		}

		return 1 + amplitude * level
	}

	private static func smoothstep(_ value: CGFloat) -> CGFloat {
		let clamped = max(0, min(1, value))
		return clamped * clamped * (3 - 2 * clamped)
	}

	private func finishAndDisappear() {
		self.isFinishing = true
		self.stackView.transform = .identity

		let scale = CAKeyframeAnimation(keyPath: "transform.scale")
		scale.values = [1.0, 1.4, 1.4, 0.0]
		scale.keyTimes = [0, 0.45, 0.6, 1.0]
		scale.timingFunctions = [
			CAMediaTimingFunction(name: .easeOut),
			CAMediaTimingFunction(name: .linear),
			CAMediaTimingFunction(name: .easeIn),
		]

		let opacity = CAKeyframeAnimation(keyPath: "opacity")
		opacity.values = [1.0, 1.0, 1.0, 0.0]
		opacity.keyTimes = [0, 0.45, 0.6, 1.0]

		let group = CAAnimationGroup()
		group.animations = [scale, opacity]
		group.duration = self.finishDuration
		group.fillMode = .forwards
		group.isRemovedOnCompletion = false

		CATransaction.begin()
		CATransaction.setCompletionBlock { [weak self] in
			self?.hide()
		}
		self.stackView.layer.add(group, forKey: "finish")
		CATransaction.commit()
	}
}
