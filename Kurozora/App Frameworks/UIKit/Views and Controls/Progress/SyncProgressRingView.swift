//
//  SyncProgressRingView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

final class SyncProgressRingView: UIView {
	// MARK: - Properties
	/// The thin full-circle outline drawn around the pie.
	private let trackLayer = CAShapeLayer()

	/// The solid wedge whose `strokeEnd` sweeps from 12 o'clock as progress advances.
	private let progressLayer = CAShapeLayer()

	/// The stroke width of the outline circle.
	private let outlineLineWidth: CGFloat = 1.2

	/// The gap between the outline circle and the wedge.
	private let wedgeGap: CGFloat = 1.5

	/// The last fraction applied; progress never regresses within one appearance.
	private var lastFraction: CGFloat = 0

	/// Identifier of the progress-fill animation.
	private let progressAnimationKey = "progressFill"

	override var intrinsicContentSize: CGSize {
		return CGSize(width: 15, height: 15)
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

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.updateRingPaths()
	}

	// MARK: - Functions
	private func sharedInit() {
		self.backgroundColor = .clear
		self.isUserInteractionEnabled = false

		self.trackLayer.fillColor = UIColor.clear.cgColor
		self.trackLayer.theme_strokeColor = KThemePicker.subTextColor.cgColorPicker
		self.trackLayer.lineWidth = self.outlineLineWidth
		self.trackLayer.opacity = 0.3
		self.layer.addSublayer(self.trackLayer)

		// lineWidth == diameter paints a solid disc; animating strokeEnd sweeps a pie wedge.
		self.progressLayer.fillColor = nil
		self.progressLayer.theme_strokeColor = KThemePicker.subTextColor.cgColorPicker
		self.progressLayer.strokeEnd = 0
		self.layer.addSublayer(self.progressLayer)
	}

	/// Recomputes the outline and wedge paths, centered in the current bounds and starting at 12 o'clock.
	private func updateRingPaths() {
		let side = min(self.bounds.width, self.bounds.height)
		let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
		let startAngle = -CGFloat.pi / 2
		let endAngle = startAngle + 2 * .pi

		let outlineRadius = (side - self.outlineLineWidth) / 2
		let outlinePath = UIBezierPath(arcCenter: center, radius: outlineRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		self.trackLayer.path = outlinePath.cgPath
		self.trackLayer.frame = self.bounds

		let wedgeDiameter = max(0, outlineRadius - self.outlineLineWidth / 2 - self.wedgeGap)
		let wedgePath = UIBezierPath(arcCenter: center, radius: wedgeDiameter / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		self.progressLayer.path = wedgePath.cgPath
		self.progressLayer.frame = self.bounds
		self.progressLayer.lineWidth = wedgeDiameter
	}

	/// Sets the wedge's fill to the given fraction, optionally animating the change.
	func setProgress(_ fraction: Double, animated: Bool) {
		let clampedFraction = CGFloat(min(max(fraction, 0), 1))
		guard clampedFraction >= self.lastFraction else { return }
		self.lastFraction = clampedFraction

		guard animated else {
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			self.progressLayer.strokeEnd = clampedFraction
			CATransaction.commit()
			return
		}

		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.fromValue = self.progressLayer.presentation()?.strokeEnd ?? self.progressLayer.strokeEnd
		animation.toValue = clampedFraction
		animation.duration = 0.25
		animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		self.progressLayer.add(animation, forKey: self.progressAnimationKey)
		self.progressLayer.strokeEnd = clampedFraction
	}

	/// Snaps the wedge back to empty without animating; a new appearance starts from zero.
	func reset() {
		self.lastFraction = 0
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		self.progressLayer.removeAnimation(forKey: self.progressAnimationKey)
		self.progressLayer.strokeEnd = 0
		CATransaction.commit()
	}
}
