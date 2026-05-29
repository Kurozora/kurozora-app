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
	// MARK: - IBOutlets
	@IBOutlet weak var bannerContainerView: UIView!
	@IBOutlet weak var bannerBorderView: BorderView!

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.bannerContainerView.layer.cornerRadius = 22
		self.bannerImageView?.applyCornerRadius(22)
		self.bannerImageView?.layer.borderWidth = 0
		self.bannerBorderView.cornerRadius = 22

		self.shadowImageView?.layer.cornerRadius = 22
		self.shadowImageView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		self.shadowImageView?.layer.masksToBounds = true
	}

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
