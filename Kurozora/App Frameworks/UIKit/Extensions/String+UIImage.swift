//
//  String+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

extension String {
	// MARK: - Properties
	/// An array of colors used as background colors for the placeholder images generated from strings. The same string will always return the same color based on its hash value.
	static let placeholderPalette: [UIColor] = [
		.systemBlue,
		.systemGreen,
		.systemOrange,
		.systemPurple,
		.systemRed,
		.systemTeal,
		.systemPink,
		.systemCyan,
		.systemYellow,
		.systemBrown
	]

	/// Returns a color based on the string's hash value. The same string will always return the same color.
	var stableHash: Int {
		self.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }
	}

	/// Returns a color from the `placeholderPalette` array based on the string's `stableHash` value. The same string will always return the same color.
	var placeholderColor: UIColor {
		let index = abs(self.stableHash) % Self.placeholderPalette.count
		return Self.placeholderPalette[index]
	}

	/// Returns an initials-based profile placeholder image derived from the string.
	var profilePlaceholderImage: UIImage {
		let initials = self.initials.capitalized
		return initials.toImage(
			withFrameSize: CGRect(x: 0, y: 0, width: 300, height: 300),
			backgroundColor: initials.placeholderColor,
			placeholder: .Placeholders.userProfile
		)
	}

	// MARK: - Functions
	/// Returns a UIImage from the string. If no image can be created then the specified placeholder is returned.
	///
	/// - Parameters:
	///    - frame: The size used to create the image. Default value is `50x50`.
	///    - backgroundColor: The color of the image's background. Default is `.lightGray`.
	///    - textColor: The color of the image's text. Default is `.white`.
	///    - fontSize: The string's font size. Default value is `20`.
	///    - placeholderImage: The UIImage to return if no image can be create from the string.
	///
	/// - Returns: A UIImage from the string.
	func toImage(withFrameSize frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50), backgroundColor: UIColor = .lightGray, textColor: UIColor = .white, fontSize: CGFloat = 20, placeholder placeholderImage: UIImage) -> UIImage {
		// Calculate optimal font size
		let shortestLength = min(frame.size.height, frame.size.width)
		let fontFraction = shortestLength / 50
		let fontSize = fontSize * fontFraction

		// Create UILabel that holds the string
		let nameLabel = UILabel(frame: frame)
		nameLabel.textAlignment = .center
		nameLabel.backgroundColor = backgroundColor
		nameLabel.textColor = textColor
		nameLabel.font = .boldSystemFont(ofSize: fontSize)
		nameLabel.text = self

		// Create a screenshot of the UILabel and return the resulted image
		UIGraphicsBeginImageContext(frame.size)
		if let currentContext = UIGraphicsGetCurrentContext() {
			nameLabel.layer.render(in: currentContext)
			return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal) ?? placeholderImage
		}
		return placeholderImage
	}

	/// Returns a UIImage from the string using the specified text style. If no image can be created then nil is returned.
	///
	/// - Parameters:
	///    - style: The text style to use for the font. Default is `.body`.
	///
	/// - Returns: A UIImage from the string or nil if no image can be created.
	func image(forTextStyle style: UIFont.TextStyle) -> UIImage? {
		let font = UIFont.systemFont(ofSize: 200)
		let attributes: [NSAttributedString.Key: Any] = [.font: font]
		let textSize = self.size(withAttributes: attributes)
		let canvasSize = max(textSize.width, textSize.height)
		let squareSize = CGSize(width: canvasSize, height: canvasSize)
		let renderer = UIGraphicsImageRenderer(size: squareSize)

		return renderer.image { _ in
			let drawOrigin = CGPoint(
				x: (canvasSize - textSize.width) / 2,
				y: (canvasSize - textSize.height) / 2
			)
			self.draw(at: drawOrigin, withAttributes: attributes)
		}
	}
}
