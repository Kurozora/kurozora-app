//
//  RoundedRectangleImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

/// `RoundedRectangleImageView` is a sepcially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `RoundedRectangleImageView` adjusts some options to achieve its design, this includes:
/// - Rounding the image's corners.
class RoundedRectangleImageView: UIImageView {
	/// The corner radius value.
	fileprivate var _cornerRadius: CGFloat = 10.0

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layerCornerRadius = self._cornerRadius
	}

	// MARK: - Functions
	/// Applies the given corner radius to the image view.
	///
	/// - Parameters:
	///    - cornerRadius: The corner radius value to apply on the image view.
	func applyCornerRadius(_ cornerRadius: CGFloat) {
		self._cornerRadius = cornerRadius

		self.setNeedsLayout()
	}
}
