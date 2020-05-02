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
			setNeedsLayout()
		}
	}

	// MARK: - Lifecycle
	override func layout(in view: UIView) {
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

	override func layoutSubviews() {
		super.layoutSubviews()

		superview?.layoutIfNeeded()
		layer.cornerRadius = cornerStyle.cornerRadius(for: bounds)
	}
}

extension KFillBarIndicator {
	// MARK: - Types
	/**
		The set of available corner style types.

		```
		case square
		case rounded
		case eliptical
		```
	*/
	public enum CornerStyle {
		/// Corners are squared off.
		case square

		/// Corners are rounded.
		case rounded

		/// Corners are completely circular.
		case eliptical

		// MARK: - Functions
		/**
			Returns a `CGFloat` value indicating how much the corners should be rounded.

			- Parameter frame: The frame that should be rounded.

			- Returns: a `CGFloat` value indicating how much the corners should be rounded.
		*/
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
}
