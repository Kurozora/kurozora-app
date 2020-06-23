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

	`ProfileImageView` adjusts some options to achieve its design, this includes:
	- Applying a border width and border color.
	- Presenting a default profile image if non is specified.
	- Rounding the image's corners.
*/
class ProfileImageView: CircularImageView {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		sharedInit()
	}

	override init(image: UIImage?) {
		super.init(image: image)
		sharedInit()
	}

	override init(image: UIImage?, highlightedImage: UIImage?) {
		super.init(image: image, highlightedImage: highlightedImage)
		sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the image view.
	func sharedInit() {
		self.image = R.image.placeholders.userProfile()

		self.borderWidth = 2
		self.borderColor = UIColor.white.withAlphaComponent(0.20)
	}
}
