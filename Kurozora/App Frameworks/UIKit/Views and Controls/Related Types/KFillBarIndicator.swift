//
//  KFillBarIndicator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Tabman

/// Simple indicator that displays as a filled pill.
class KFillBarIndicator: TMBarIndicator {
	// MARK: - Properties
	/// The top constraint of the bar indicator.
	private var topConstraint: NSLayoutConstraint?
	/// The bottom constraint of the bar indicator.
	private var bottomConstraint: NSLayoutConstraint?

	// MARK: - Properties
	override var displayMode: TMBarIndicator.DisplayMode {
		return .fill
	}

	// MARK: Customization
	/// Corner style for the indicator. Default: `.eliptical`.
	var cornerStyle: CornerStyle = .eliptical {
		didSet {
			self.setNeedsLayout()
		}
	}

	// MARK: - Lifecycle
	override func layout(in view: UIView) {
		super.layout(in: view)

		let topConstraint = self.topAnchor.constraint(equalTo: view.topAnchor, constant: 5)
		topConstraint.isActive = true
		self.topConstraint = topConstraint

		let bottomConstraint = self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)
		bottomConstraint.isActive = true
		self.bottomConstraint = bottomConstraint

		self.theme_tintColor = KThemePicker.textColor.rawValue
		self.backgroundColor = self.tintColor.withAlphaComponent(0.25)
		self.overscrollBehavior = .bounce
		self.transitionStyle = .progressive
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.superview?.layoutIfNeeded()
		self.layer.cornerRadius = self.cornerStyle.cornerRadius(for: self.bounds)
	}
}
