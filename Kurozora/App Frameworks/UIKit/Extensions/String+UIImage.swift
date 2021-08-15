//
//  String+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

extension String {
	// MARK: - Functions
	/**
		Returns a UIImage from the string. If no image can be created then the specified placeholder is returned.

		- Parameter frame: The size used to create the image. Default value is 50x50.
		- Parameter placeholderImage: The UIImage to return if no image can be create from the string.

		- Returns: A UIImage from the string.
	*/
	func toImage(withFrameSize frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50), placeholder placeholderImage: UIImage) -> UIImage {
		// Calculate optimal font size
		let shortestLength = frame.size.minDimension
		let fontFraction = shortestLength / 50
		let fontSize = 20 * fontFraction

		// Create UILabel that holds the string
		let nameLabel = UILabel(frame: frame)
		nameLabel.textAlignment = .center
		nameLabel.backgroundColor = .lightGray
		nameLabel.textColor = .white
		nameLabel.font = .boldSystemFont(ofSize: fontSize)
		nameLabel.text = self

		// Create a screenshot of the UILabel and return the resulted image
		UIGraphicsBeginImageContext(frame.size)
		if let currentContext = UIGraphicsGetCurrentContext() {
			nameLabel.layer.render(in: currentContext)
			let nameImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal) ?? placeholderImage
			return nameImage
		}
		return placeholderImage
	}
}
