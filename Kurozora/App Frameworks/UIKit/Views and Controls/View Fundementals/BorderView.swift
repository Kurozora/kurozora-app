//
//  BorderView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A view that paints a themed rounded-rectangle border on top of its content using a stroked `CAShapeLayer`.
class BorderView: UIView {
	// MARK: - Properties
	/// The theme picker key used to color the border.
	var themeColorKey: KThemePicker {
		return .borderColor
	}

	/// The width of the stroked border, in points.
	var lineWidth: CGFloat {
		return self.hairlineWidth
	}

	/// The corner radius applied to the rounded-rectangle border path.
	@IBInspectable var cornerRadius: CGFloat = 10 {
		didSet {
			self.setNeedsLayout()
		}
	}

	/// The shape layer that strokes the rounded-rectangle path with uniform thickness.
	private let borderShapeLayer = CAShapeLayer()

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
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.updateBorderPath()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.borderShapeLayer.fillColor = UIColor.clear.cgColor
		self.borderShapeLayer.lineWidth = self.lineWidth
		self.borderShapeLayer.contentsScale = UIScreen.main.scale
		self.layer.addSublayer(self.borderShapeLayer)

		self.applyThemeStrokeColor()
		NotificationCenter.default.addObserver(self, selector: #selector(self.applyThemeStrokeColor), name: .ThemeUpdateNotification, object: nil)
	}

	/// Sets the stroke color to the current theme's border color.
	@objc private func applyThemeStrokeColor() {
		self.borderShapeLayer.strokeColor = self.themeColorKey.colorValue.cgColor
	}

	/// Recomputes the stroked rounded-rectangle path so the stroke is centered on `bounds`.
	private func updateBorderPath() {
		let inset = self.lineWidth / 2.0
		let rect = self.bounds.insetBy(dx: inset, dy: inset)
		let radius = max(0, self.cornerRadius - inset)
		let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)

		self.borderShapeLayer.path = path.cgPath
		self.borderShapeLayer.frame = self.bounds
	}
}
