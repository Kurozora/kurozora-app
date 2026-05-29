//
//  BannerImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

/// `BannerImageView` is a specially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `BannerImageView` adjusts some options to achieve its design, this includes:
/// - Presenting a default banner image if none is specified.
/// - Rounding the image's corners.
final class BannerImageView: RoundedRectangleImageView {
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
		self.image = self.image ?? .Placeholders.showBanner
	}
}
