//
//  KImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

/// `KImageView` is a sepcially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `KImageView` adjusts some options to achieve its design, this includes:
/// - Applies global tint color.
class KImageView: UIImageView {
	// MARK: - Properties
	override var intrinsicContentSize: CGSize {
		if let image = self.image {
			let imageWidth = image.size.width
			let imageHeight = image.size.height
			let myViewWidth = self.frame.size.width

			let ratio = myViewWidth/imageWidth
			let scaledHeight = imageHeight * ratio

			return CGSize(width: myViewWidth, height: scaledHeight)
		}

		return CGSize(width: -1.0, height: -1.0)
	}

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

	init(url: URL) {
		super.init(frame: .zero)

		self.kf.setImage(with: url)
	}

	// MARK: - Functions
	/// The shared settings used to initialize the image view.
	fileprivate func sharedInit() {
		self.theme_tintColor = KThemePicker.tintColor.rawValue
	}
}
