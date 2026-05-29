//
//  SeparatorView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// An object that manages the content for a rectangular area on the screen.
///
/// Views are the fundamental building blocks of your app's user interface, and the `SeparatorView` class defines the behaviors that are common to separators.
/// A view object renders content within its bounds rectangle and handles any interactions with that content. However, the `SeparatorView` class is a concrete class that you can only instantiate and use to display a separator view.
class SeparatorView: UIView {
	// MARK: - Properties
	/// The theme picker key used to fill the separator.
	var themeColorKey: KThemePicker {
		return .separatorColor
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
	override func didMoveToWindow() {
		super.didMoveToWindow()

		guard self.window != nil else { return }

		self.collapseThicknessToHairline()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.alignToPixelGrid()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.theme_backgroundColor = self.themeColorKey.rawValue
	}

	/// Resizes the separator's thickness constraint to a single physical pixel for the current display scale.
	///
	/// The existing constraint's constant is mutated in place so no competing constraint is introduced.
	private func collapseThicknessToHairline() {
		let hairline = self.hairlineWidth

		for constraint in self.constraints where self.isThicknessConstraint(constraint) {
			constraint.constant = hairline
		}
	}

	/// Shifts the separator so its leading edge lands on the physical pixel grid, keeping the hairline crisp.
	private func alignToPixelGrid() {
		guard let window = self.window else { return }

		let hairline = self.hairlineWidth
		let originInWindow = self.convert(CGPoint.zero, to: window)
		let deltaX = (originInWindow.x / hairline).rounded() * hairline - originInWindow.x
		let deltaY = (originInWindow.y / hairline).rounded() * hairline - originInWindow.y

		guard abs(deltaX) > 0.001 || abs(deltaY) > 0.001 else { return }

		self.frame.origin.x += deltaX
		self.frame.origin.y += deltaY
	}

	/// Returns whether the constraint pins the separator's thickness to a fixed size.
	///
	/// - Parameter constraint: The constraint to evaluate.
	/// - Returns: `true` when the constraint fixes the view's width or height to a hairline-scale constant.
	private func isThicknessConstraint(_ constraint: NSLayoutConstraint) -> Bool {
		let maximumThickness: CGFloat = 3.0

		return constraint.secondItem == nil
			&& constraint.relation == .equal
			&& (constraint.firstAttribute == .width || constraint.firstAttribute == .height)
			&& constraint.constant <= maximumThickness
	}
}
