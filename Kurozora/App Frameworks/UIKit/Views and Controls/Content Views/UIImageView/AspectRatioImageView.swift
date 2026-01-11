//
//  AspectRatioImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// `AspectRatioImageView` is a specially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `AspectRatioImageView` adjusts some options to achieve its design, this includes:
/// - Maintaining the aspect ratio of the displayed image.
class AspectRatioImageView: KImageView {
	// MARK: - Properties
	/// The aspect ratio constraint.
	private var aspectRatioConstraint: NSLayoutConstraint?

	override var image: UIImage? {
		didSet {
			self.updateAspectRatioConstraint()
		}
	}

	// MARK: - Functiosn
	/// Updates the aspect ratio constraint based on the current image.
	private func updateAspectRatioConstraint() {
		self.aspectRatioConstraint?.isActive = false
		self.aspectRatioConstraint = nil

		guard let image = self.image, image.size.width > 0 else {
			return
		}

		let ratio = image.size.height / image.size.width

		let constraint = self.heightAnchor.constraint(
			equalTo: self.widthAnchor,
			multiplier: ratio
		)

		constraint.priority = UILayoutPriority(999)
		constraint.isActive = true

		self.aspectRatioConstraint = constraint
	}
}
