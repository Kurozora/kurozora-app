//
//  StudioLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudioLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var primaryImageView: BannerImageView!
	@IBOutlet weak var secondaryImageView: StudioLogoImageView!
	@IBOutlet weak var profileImageContainer: UIView!

	// MARK: - Functions
	func configure(using studio: Studio?) {
		guard let studio = studio else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure primary label
		self.primaryLabel.text = studio.attributes.name

		// Configure secondary label
		if let foundedDate = studio.attributes.founded?.formatted(date: .abbreviated, time: .omitted) {
			self.secondaryLabel.text = "\(Trans.founded) \(foundedDate)"
		} else {
			self.secondaryLabel.text = nil
		}

		// Configure banner image
		studio.attributes.bannerImage(imageView: self.primaryImageView)

		// Configure profile image
		self.profileImageContainer.isHidden = studio.attributes.logo != nil
		studio.attributes.logoImage(imageView: self.secondaryImageView)
	}
}
