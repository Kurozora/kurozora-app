//
//  BannerLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BannerLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Functions
	override func configure(using show: Show?, rank: Int? = nil) {
		super.configure(using: show, rank: rank)
		guard let show = show else { return }

		// Configure banner
		if let bannerBackgroundColor = show.attributes.banner?.backgroundColor, let color = UIColor(hexString: bannerBackgroundColor) {
			let textColor: UIColor = color.isLight ? .black : .white
			self.bannerImageView?.backgroundColor = color
			self.shadowImageView?.tintColor = color
			self.primaryLabel?.textColor = textColor
			self.secondaryLabel?.textColor = textColor.withAlphaComponent(0.60)
		} else {
			self.bannerImageView?.backgroundColor = .clear
			self.shadowImageView?.tintColor = .black
			self.primaryLabel?.textColor = .white
			self.secondaryLabel?.textColor = .white.withAlphaComponent(0.60)
		}
	}
}
