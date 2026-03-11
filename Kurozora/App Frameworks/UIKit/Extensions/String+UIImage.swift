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
		UIColor(red: 66, green: 135, blue: 245)!, // Blue
		UIColor(red: 52, green: 199, blue: 89)!, // Green
		UIColor(red: 255, green: 149, blue: 0)!, // Orange
		UIColor(red: 88, green: 86, blue: 214)!, // Purple
		UIColor(red: 255, green: 59, blue: 48)!, // Red
		UIColor(red: 0, green: 199, blue: 190)!, // Teal
		UIColor(red: 175, green: 82, blue: 222)!, // Pink
		UIColor(red: 48, green: 176, blue: 199)!, // Cyan
		UIColor(red: 254, green: 204, blue: 2)!, // Yellow
		UIColor(red: 162, green: 132, blue: 94)! // Brown
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
}
