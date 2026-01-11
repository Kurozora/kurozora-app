//
//  KImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

/// `KImageView` is a specially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `KImageView` adjusts some options to achieve its design, this includes:
/// - Applies themed tint color.
class KImageView: UIImageView {
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
