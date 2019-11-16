//
//  KFillBarIndicator.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Tabman

/// Simple indicator that displays as a horizontal line.
class KFillBarIndicator: TMBarIndicator {
	// MARK: Properties
	private var topConstraint: NSLayoutConstraint?
	private var bottomConstraint: NSLayoutConstraint?

	// MARK: Types
	public enum CornerStyle {
		case square
		case rounded
		case eliptical
	}

	// MARK: Properties
	open override var displayMode: TMBarIndicator.DisplayMode {
		return .fill
	}

	// MARK: Customization
	/// Corner style for the indicator.
	///
	/// Options:
	/// - square: Corners are squared off.
	/// - rounded: Corners are rounded.
	/// - eliptical: Corners are completely circular.
	///
	/// Default: `.square`.
	open var cornerStyle: CornerStyle = .eliptical {
		didSet {
			setNeedsLayout()
		}
	}

	// MARK: Lifecycle
	open override func layout(in view: UIView) {
		super.layout(in: view)

		let topConstraint = topAnchor.constraint(equalTo: view.topAnchor, constant: 5)
		topConstraint.isActive = true
		self.topConstraint = topConstraint

		let bottomConstraint = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)
		bottomConstraint.isActive = true
		self.bottomConstraint = bottomConstraint

		self.theme_tintColor = KThemePicker.tintColor.rawValue
		self.backgroundColor = tintColor.withAlphaComponent(0.25)
		self.overscrollBehavior = .bounce
		self.transitionStyle = .progressive
	}

	open override func layoutSubviews() {
		super.layoutSubviews()

		superview?.layoutIfNeeded()
		layer.cornerRadius = cornerStyle.cornerRadius(for: bounds)
	}
}

private extension KFillBarIndicator.CornerStyle {
	func cornerRadius(for frame: CGRect) -> CGFloat {
		switch self {
		case .square:
			return 0.0
		case .rounded:
			return frame.size.height / 6.0
		case .eliptical:
			return frame.size.height / 2.0
		}
	}
}
