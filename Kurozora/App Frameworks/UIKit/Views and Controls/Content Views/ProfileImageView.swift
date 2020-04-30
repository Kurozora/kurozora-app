//
//  ProfileImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	`ProfileImageView` is a sepcially crafted object that displays a single image or a sequence of animated images in your interface.

	`ProfileImageView` adjusts some options to achieve its design, such as:
	- Applying a border width and border color.
	- Presenting a default profile image if non is specified.
	- Rounding the image's corners.
*/
class ProfileImageView: UIImageView {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureImageViewStyle()
	}

	override init(image: UIImage?) {
		super.init(image: image)
		configureImageViewStyle()
	}

	override init(image: UIImage?, highlightedImage: UIImage?) {
		super.init(image: image, highlightedImage: highlightedImage)
		configureImageViewStyle()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configureImageViewStyle()
	}

	// MARK: View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.cornerRadius = self.height / 2
	}

	// MARK: - Functions
	/// Configures the image view with the predefined set of styles.
	func configureImageViewStyle() {
		self.image = R.image.placeholders.userProfile()

		self.borderWidth = 2
		self.borderColor = UIColor.white.withAlphaComponent(0.20)
	}
}
