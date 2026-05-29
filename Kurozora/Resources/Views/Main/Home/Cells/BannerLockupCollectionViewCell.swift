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
	@IBOutlet weak var bannerContainerView: UIView!
	@IBOutlet weak var bannerBorderView: BorderView!
	@IBOutlet weak var separatorView: SeparatorView!

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
