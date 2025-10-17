//
//  StudioLogoImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// `StudioLogoImageView` is a specially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `StudioLogoImageView` adjusts some options to achieve its design, this includes:
/// - Applying a border width and border color.
/// - Presenting a default studio logo image if none is specified.
/// - Rounding the image's corners.
class StudioLogoImageView: CircularImageView {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	override init(image: UIImage?) {
		super.init(image: image)
		self.sharedInit()
	}

	override init(image: UIImage?, highlightedImage: UIImage?) {
		super.init(image: image, highlightedImage: highlightedImage)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the image view.
	func sharedInit() {
		self.image = self.image ?? .Placeholders.studioProfile

		self.layer.borderWidth = 2
		self.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor
	}
}
