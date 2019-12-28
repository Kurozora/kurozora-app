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
	/// Updates the background color of the image.
	func updateImageColor() {
		backgroundColorView.backgroundColor = self.bannerImageView?.image?.getColors(quality: .lowest)?.background
	}
}
