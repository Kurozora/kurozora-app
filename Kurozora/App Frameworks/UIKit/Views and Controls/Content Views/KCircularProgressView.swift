//
//  KCircularProgressView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/11/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class KCircularProgressView: UIView {
	// MARK: - Properties
	var backgroundCircleColor: KThemePicker = KThemePicker.backgroundColor {
		didSet {
			self.backgroundCircle.theme_strokeColor = self.backgroundCircleColor.cgColorPicker
		}
	}
	var fillColor: KThemePicker = KThemePicker.tintColor {
		didSet {
			self.progressCircle.theme_strokeColor = self.fillColor.cgColorPicker
		}
	}
	var lineWidth: CGFloat = 4 {
		didSet {
			self.backgroundCircle.lineWidth = self.lineWidth
			self.progressCircle.lineWidth = self.lineWidth
		}
	}
	var defaultProgress: CGFloat = 0 {
		didSet {
			self.updateProgress(self.defaultProgress)
		}
	}

	private var backgroundCircle: CAShapeLayer!
	private var progressCircle: CAShapeLayer!

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.drawBackgroundCircle()
		self.drawProgressCircle()
	}

	private func drawBackgroundCircle() {
		self.backgroundCircle = CAShapeLayer()

		let centerPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.width / 2)
		let circleRadius: CGFloat = self.bounds.width / 2
		let circlePath = UIBezierPath(
			arcCenter: centerPoint,
			radius: circleRadius,
			startAngle: CGFloat(-0.5 * .pi),
			endAngle: CGFloat(1.5 * .pi),
			clockwise: true
		)

		self.backgroundCircle.path = circlePath.cgPath
		self.backgroundCircle.theme_strokeColor = self.backgroundCircleColor.cgColorPicker
		self.backgroundCircle.fillColor = UIColor.clear.cgColor
		self.backgroundCircle.lineWidth = self.lineWidth
		self.backgroundCircle.lineCap = .round
		self.backgroundCircle.lineJoin = .round
		self.backgroundCircle.strokeStart = 0
		self.backgroundCircle.strokeEnd = 1.0
		self.layer.addSublayer(self.backgroundCircle)
	}

	private func drawProgressCircle() {
		self.progressCircle = CAShapeLayer()

		let centerPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.width / 2)
		let circleRadius: CGFloat = self.bounds.width / 2
		let circlePath = UIBezierPath(
			arcCenter: centerPoint,
			radius: circleRadius,
			startAngle: CGFloat(-0.5 * .pi),
			endAngle: CGFloat(1.5 * .pi),
			clockwise: true
		)

		self.progressCircle.path = circlePath.cgPath
		self.progressCircle.theme_strokeColor = self.fillColor.cgColorPicker
		self.progressCircle.fillColor = UIColor.clear.cgColor
		self.progressCircle.lineWidth = self.lineWidth
		self.progressCircle.lineCap = .round
		self.progressCircle.lineJoin = .round
		self.progressCircle.strokeStart = 0
		self.progressCircle.strokeEnd = 0.0
		self.layer.addSublayer(self.progressCircle)
	}

	func updateProgress(_ progress: CGFloat) {
		self.progressCircle.strokeEnd = CGFloat(progress / 100)
	}
}
