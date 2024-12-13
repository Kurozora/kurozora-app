//
//  LargeLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LargeLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - Functions
	override func configure(using show: Show?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: show, rank: rank, scheduleIsShown: scheduleIsShown)
		guard let show = show else { return }

		// Configure banner
		if let bannerBackgroundColor = show.attributes.banner?.backgroundColor, let color = UIColor(hexString: bannerBackgroundColor) {
			self.bannerImageView?.backgroundColor = color
			self.shadowImageView?.tintColor = color
		}
	}
}
