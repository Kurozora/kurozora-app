//
//  KMediaControlButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A round translucent media control with a white glyph.
final class KMediaControlButton: AdaptiveCornerButton {
	// MARK: - Initializers
	/// Creates a button with the given glyph and diameter.
	///
	/// - Parameters:
	///    - pointSize: The glyph's point size.
	///    - diameter: The button's diameter.
	init(pointSize: CGFloat = 17.0, diameter: CGFloat = 44.0) {
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.applyStyle(pointSize: pointSize, diameter: diameter)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.applyStyle(pointSize: 17.0, diameter: 44.0)
	}

	// MARK: - Functions
	/// Styles the button as a translucent media control of the given size.
	///
	/// - Parameters:
	///    - pointSize: The glyph's point size.
	///    - diameter: The button's diameter.
	private func applyStyle(pointSize: CGFloat, diameter: CGFloat) {
		self.overrideUserInterfaceStyle = .dark

		let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
		self.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.configuration = .clearGlass()
			self.configuration?.preferredSymbolConfigurationForImage = symbolConfiguration
			self.configuration?.baseForegroundColor = .white
		} else {
			self.tintColor = .white
			self.addBlurEffect(style: .dark, cornerRadius: diameter / 2.0)
		}

		self.cornerStyle = .capsule

		NSLayoutConstraint.activate([
			self.widthAnchor.constraint(equalToConstant: diameter),
			self.heightAnchor.constraint(equalToConstant: diameter)
		])
	}
}
