//
//  UIFont+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

extension UIFont {
	/// Returns the bold version of the font.
	var bold: UIFont {
		guard let descriptor = self.fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
		return UIFont(descriptor: descriptor, size: 0)
	}

	/// Returns the semibold version of the font.
	var semibold: UIFont {
		let descriptor = self.fontDescriptor.addingAttributes([
			.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold],
		])
		return UIFont(descriptor: descriptor, size: 0)
	}

	// MARK: - Functions
	/// Returns the font to use for the monogram profile image.
	///
	/// - Parameters:
	///    - style: The font style to use.
	///    - size: The size of the font.
	///    - weight: The weight of the font. Default is `.bold`.
	///
	/// - Returns: The font to use for the monogram profile image.
	static func monogramFont(style: MonogramFontStyle, size: CGFloat, weight: UIFont.Weight = .bold) -> UIFont {
		switch style {
		case .defaultStyle:
			return .systemFont(ofSize: size, weight: weight)
		case .rounded:
			guard let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.rounded) else {
				return .systemFont(ofSize: size, weight: weight)
			}
			let weightedDescriptor = descriptor.addingAttributes([
				.traits: [UIFontDescriptor.TraitKey.weight: weight]
			])
			return UIFont(descriptor: weightedDescriptor, size: size)
		case .serif:
			guard let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.serif) else {
				return .systemFont(ofSize: size, weight: weight)
			}
			let weightedDescriptor = descriptor.addingAttributes([
				.traits: [UIFontDescriptor.TraitKey.weight: weight]
			])
			return UIFont(descriptor: weightedDescriptor, size: size)
		case .compressed:
			if #available(iOS 16.0, *) {
				return .systemFont(ofSize: size, weight: weight, width: .compressed)
			} else {
				if let font = UIFont(name: "SFCompactText-Bold", size: size) {
					return font
				}
				return .systemFont(ofSize: size, weight: weight)
			}
		}
	}
}
