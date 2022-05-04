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
	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.cornerRadius = 10
	}
}
