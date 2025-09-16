//
//  ProfileImageButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// `ProfileImageButton` is a specially crafted object that displays a single image in your interface.
///
/// `ProfileImageButton` adjusts some options to achieve its design, this includes:
/// - Applying a border width and border color.
/// - Rounding the image's corners.
class ProfileImageButton: UIButton {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layerCornerRadius = self.frame.size.height / 2
	}

	// MARK: - Functions
	/// The shared settings used to initialize the button.
	func sharedInit() {
		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.layer.borderWidth = 2
			self.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor
		}
	}
}
