//
//  CircularImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// `CircularImageView` is a specially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `CircularImageView` adjusts some options to achieve its design, this includes:
/// - Rounding the image's corners.
class CircularImageView: KImageView {
	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layerCornerRadius = self.frame.size.height / 2
	}
}
