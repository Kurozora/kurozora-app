//
//  KDownloadProgressView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

final class KDownloadProgressView: UIView {
	// MARK: - Views
	private let trackLayer = CAShapeLayer()
	private let progressLayer = CAShapeLayer()
	private let stopSquare = UIView()

	// MARK: - Properties
	private let progressAnimationKey = "progress"

	private(set) var progress: Double = 0

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
		self.updateStopSquareFrame()
	}

	// MARK: - Functions
	private func sharedInit() {
		self.backgroundColor = .clear
		self.isUserInteractionEnabled = false

		for layer in [self.trackLayer, self.progressLayer] {
			layer.fillColor = UIColor.clear.cgColor
			layer.lineWidth = 2
			layer.lineCap = .round
			self.layer.addSublayer(layer)
		}

		self.progressLayer.theme_strokeColor = KThemePicker.tintColor.cgColorPicker
		self.progressLayer.strokeEnd = 0

		self.stopSquare.theme_backgroundColor = KThemePicker.tintColor.rawValue
		self.stopSquare.isUserInteractionEnabled = false
		self.stopSquare.layer.cornerCurve = .continuous
		self.addSubview(self.stopSquare)

		self.applyColors()
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppearanceChange), name: .KSAppAppearanceDidChange, object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	private func updateRingPaths() {
		let diameter = min(self.bounds.width, self.bounds.height)
		let radius = (diameter - self.trackLayer.lineWidth) / 2
		let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

		let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: -.pi / 2 + 2 * .pi, clockwise: true)
		self.trackLayer.path = path.cgPath
		self.progressLayer.path = path.cgPath
		self.trackLayer.frame = self.bounds
		self.progressLayer.frame = self.bounds
	}

	private func updateStopSquareFrame() {
		let side = min(self.bounds.width, self.bounds.height) * 0.3
		self.stopSquare.frame = CGRect(
			x: self.bounds.midX - side / 2,
			y: self.bounds.midY - side / 2,
			width: side,
			height: side
		)
		self.stopSquare.layer.cornerRadius = 2
	}

	private func applyColors() {
		let trackColor = KThemePicker.subTextColor.colorValue.withAlphaComponent(0.3)
		self.trackLayer.strokeColor = trackColor.cgColor
	}

	@objc private func handleAppearanceChange() {
		self.applyColors()
	}

	/// Updates the progress ring's fill amount.
	///
	/// - Parameters:
	///   - progress: A value in `0...1` representing the new fill amount.
	///   - animated: Whether to interpolate from the current value.
	func setProgress(_ progress: Double, animated: Bool) {
		let clamped = max(0, min(1, progress))
		let previous = self.currentDisplayedProgress()
		self.progress = clamped

		self.progressLayer.removeAnimation(forKey: self.progressAnimationKey)

		guard animated else {
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			self.progressLayer.strokeEnd = CGFloat(clamped)
			CATransaction.commit()
			return
		}

		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.fromValue = previous
		animation.toValue = clamped
		animation.duration = 0.3
		animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
		animation.fillMode = .forwards
		self.progressLayer.strokeEnd = CGFloat(clamped)
		self.progressLayer.add(animation, forKey: self.progressAnimationKey)
	}

	private func currentDisplayedProgress() -> CGFloat {
		if let presentation = self.progressLayer.presentation() {
			return presentation.strokeEnd
		}
		return self.progressLayer.strokeEnd
	}
}
