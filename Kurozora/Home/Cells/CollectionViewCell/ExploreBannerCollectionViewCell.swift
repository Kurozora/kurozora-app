//
//  ExploreBannerCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ExploreBannerCollectionViewCell: ExploreBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet weak var backgroundColorView: UIView!
	override var updateBannerBackgroundColor: Bool {
		didSet {
			if updateBannerBackgroundColor {
				updateImageColor()
			}
		}
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		let maskLayer = CAGradientLayer()
		maskLayer.frame = bannerImageView?.bounds ?? self.bounds
		maskLayer.shadowRadius = 5
		maskLayer.shadowPath = CGPath(roundedRect: bannerImageView?.bounds.insetBy(dx: 10, dy: 0) ?? self.bounds.insetBy(dx: 10, dy: 0), cornerWidth: 0, cornerHeight: 0, transform: nil)
		maskLayer.shadowOpacity = 1
		maskLayer.shadowOffset = CGSize.zero
		maskLayer.shadowColor = UIColor.white.cgColor
		bannerImageView?.layer.mask = maskLayer
	}

	/// Updates the background color of the image.
	func updateImageColor() {
		backgroundColorView.backgroundColor = self.bannerImageView?.image?.getColors(quality: .lowest)?.background
	}
}
