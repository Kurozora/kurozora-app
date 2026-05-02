//
//  IconImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// `IconImageView` is a specially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `IconImageView` adjusts some options to achieve its design, this includes:
/// - Applying a border color.
final class IconImageView: KImageView {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the label.
	private func sharedInit() {
		self.layerCornerRadius = 6
		self.layer.borderWidth = 1
		self.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor
	}
}
