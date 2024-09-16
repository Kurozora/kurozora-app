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
	@IBOutlet weak var rankLabel: KLabel!
	@IBOutlet weak var primaryImageView: BannerImageView!
	@IBOutlet weak var secondaryImageView: StudioLogoImageView!
	@IBOutlet weak var profileImageContainer: UIView!

	// MARK: - Functions
	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - studio: The `Studio` object used to configure the cell.
	///    - rank: The rank of the cell within the collection view.
	func configure(using studio: Studio?, rank: Int? = nil) {
		guard let studio = studio else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure primary label
		self.primaryLabel.text = studio.attributes.name

		// Configure secondary label
		if let foundedDate = studio.attributes.foundedAt?.formatted(date: .abbreviated, time: .omitted) {
			self.secondaryLabel.text = "\(Trans.founded) \(foundedDate)"
		} else {
			self.secondaryLabel.text = nil
		}

		// Configure rank
		if let rank = rank {
			self.rankLabel.text = "#\(rank)"
			self.rankLabel.isHidden = false
		} else {
			self.rankLabel.text = nil
			self.rankLabel.isHidden = true
		}

		// Configure banner image
		studio.attributes.bannerImage(imageView: self.primaryImageView)

		// Configure profile image
		if studio.attributes.logo != nil {
			studio.attributes.logoImage(imageView: self.secondaryImageView)
			self.profileImageContainer.isHidden = false
		} else if studio.attributes.profile != nil {
			studio.attributes.profileImage(imageView: self.secondaryImageView)
			self.profileImageContainer.isHidden = false
		} else {
			self.profileImageContainer.isHidden = true
		}
	}
}
