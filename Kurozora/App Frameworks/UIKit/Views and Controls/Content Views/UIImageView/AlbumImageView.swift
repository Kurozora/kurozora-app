//
//  AlbumImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

/// `AlbumImageView` is a sepcially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `AlbumImageView` adjusts some options to achieve its design, this includes:
/// - Applying a border width and border color.
/// - Presenting a default album image if none is specified.
/// - Rounding the image's corners.
class AlbumImageView: RoundedRectangleImageView {
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
		self.image = R.image.placeholders.musicAlbum()

		self.layer.borderWidth = 2
		self.layerBorderColor = UIColor.white.withAlphaComponent(0.20)
	}
}
