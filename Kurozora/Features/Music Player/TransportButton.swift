//
//  TransportButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

@available(iOS 17.0, *)
final class TransportButton: IconPressControl {
	// MARK: - Properties
	/// The skip-conveyor glyph, when this button is a skip control.
	private var skipChevron: SkipChevronView?

	/// Whether the control is in its active (enabled) state, persisting a tinted highlight and symbol.
	var isActive: Bool = false {
		didSet {
			guard oldValue != self.isActive else { return }
			self.updateColors()
			self.updateHighlight(animated: true)
		}
	}

	override var maintainsHighlight: Bool {
		self.isActive
	}

	override var symbolThemeColor: KThemePicker {
		self.isActive ? .tintColor : self.restingThemeColor
	}

	override var highlightBackgroundColor: UIColor {
		self.isActive
			? KThemePicker.tintColor.colorValue.withAlphaComponent(0.5)
			: .black.withAlphaComponent(0.5)
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addAction(UIAction { [weak self] _ in
			self?.animateSkip()
		}, for: .touchUpInside)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Runs one step of the skip-conveyor animation.
	func animateSkip() {
		self.skipChevron?.animateSkip()
	}

	/// Configures this button as a skip control, replacing the symbol with an animatable chevron.
	///
	/// - Parameter direction: The skip direction.
	func configureSkip(direction: SkipChevronView.Direction) {
		let chevron = SkipChevronView(direction: direction)
		chevron.translatesAutoresizingMaskIntoConstraints = false
		self.symbolView.addSubview(chevron)
		NSLayoutConstraint.activate([
			chevron.leadingAnchor.constraint(equalTo: self.symbolView.leadingAnchor),
			chevron.trailingAnchor.constraint(equalTo: self.symbolView.trailingAnchor),
			chevron.topAnchor.constraint(equalTo: self.symbolView.topAnchor),
			chevron.bottomAnchor.constraint(equalTo: self.symbolView.bottomAnchor),
		])
		self.skipChevron = chevron
	}

	/// Re-renders the skip glyph at the given size and spacing, when this button is a skip control.
	///
	/// - Parameters:
	///    - pointSize: The triangle symbol point size.
	///    - spacing: The center-to-center distance between the resting triangles.
	func setSkipMetrics(pointSize: CGFloat, spacing: CGFloat) {
		self.skipChevron?.setMetrics(pointSize: pointSize, spacing: spacing)
	}
}
