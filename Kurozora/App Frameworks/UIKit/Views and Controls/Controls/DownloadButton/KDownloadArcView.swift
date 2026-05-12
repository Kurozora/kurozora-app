//
//  KDownloadArcView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

final class KDownloadArcView: UIView {
	// MARK: - Properties
	/// The shape layer responsible for drawing the open arc.
	private let arcLayer = CAShapeLayer()

	/// Identifier of the infinite rotation animation.
	private let rotationAnimationKey = "rotation"

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
		self.updateArcPath()
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()

		if self.window != nil {
			self.startSpinning()
		} else {
			self.stopSpinning()
		}
	}

	// MARK: - Functions
	private func sharedInit() {
		self.backgroundColor = .clear
		self.isUserInteractionEnabled = false

		self.arcLayer.theme_strokeColor = KThemePicker.tintColor.cgColorPicker
		self.arcLayer.fillColor = UIColor.clear.cgColor
		self.arcLayer.lineCap = .round
		self.arcLayer.lineWidth = 2
		self.layer.addSublayer(self.arcLayer)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	/// Recomputes the arc path centered in the current bounds.
	private func updateArcPath() {
		let radius = (min(self.bounds.width, self.bounds.height) - self.arcLayer.lineWidth) / 2
		let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
		let startAngle: CGFloat = -.pi / 2
		let endAngle: CGFloat = startAngle + (12 * .pi / 7)

		let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		self.arcLayer.path = path.cgPath
		self.arcLayer.frame = self.bounds
	}

	/// Adds the infinite rotation animation to the arc layer.
	func startSpinning() {
		guard self.arcLayer.animation(forKey: self.rotationAnimationKey) == nil else { return }

		let animation = CABasicAnimation(keyPath: "transform.rotation.z")
		animation.fromValue = 0
		animation.toValue = 2 * Double.pi
		animation.duration = 2
		animation.repeatCount = .greatestFiniteMagnitude
		animation.isRemovedOnCompletion = false
		self.arcLayer.add(animation, forKey: self.rotationAnimationKey)
	}

	/// Removes the rotation animation from the arc layer.
	func stopSpinning() {
		self.arcLayer.removeAnimation(forKey: self.rotationAnimationKey)
	}
}
