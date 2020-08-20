//
//  ActorImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	`ActorImageView` is a sepcially crafted object that displays a single image or a sequence of animated images in your interface.

	`ActorImageView` adjusts some options to achieve its design, this includes:
	- Applying a border width and border color.
	- Presenting a default actor image if none is specified.
	- Rounding the image's corners.
*/
class ActorImageView: CircularImageView {
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
		self.image = R.image.placeholders.showPerson()

		self.borderWidth = 2
		self.borderColor = UIColor.white.withAlphaComponent(0.20)
	}
}
