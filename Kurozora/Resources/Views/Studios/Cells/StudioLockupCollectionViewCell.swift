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
	@IBOutlet weak var primaryContainerView: UIView!
	@IBOutlet weak var primaryImageView: BannerImageView!
	@IBOutlet weak var primaryBorderView: BorderView!
	@IBOutlet weak var secondaryImageView: StudioLogoImageView!
	@IBOutlet weak var profileImageContainer: UIView!

	// MARK: - View
	nonisolated override func awakeFromNib() {
		super.awakeFromNib()

		MainActor.assumeIsolated {
			self.primaryContainerView.layer.cornerRadius = 22
			self.profileImageContainer.layer.cornerRadius = 22
			self.primaryImageView?.applyCornerRadius(22)
			self.primaryImageView?.layer.borderWidth = 0
			self.primaryBorderView.cornerRadius = 22
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	///
	/// - Parameters:
	///    - studio: The `Studio` object used to configure the cell.
	///    - rank: The rank of the cell within the collection view.
	///    - detail: The text shown in place of the founding date.
	func configure(using studio: Studio?, rank: Int? = nil, detail: String? = nil) {
		guard let studio = studio else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = studio.attributes.name

		if let detail {
			self.secondaryLabel.text = detail
		} else if let foundedDate = studio.attributes.foundedAt?.formatted(date: .abbreviated, time: .omitted) {
			self.secondaryLabel.text = "\(L10n.founded) \(foundedDate)"
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

// MARK: - Measurement
extension StudioLockupCollectionViewCell {
	/// Returns the item that measures the given studio.
	///
	/// - Parameters:
	///    - studio: The studio the item measures.
	///    - rank: The rank of the studio in a ranked list.
	///    - detail: The text shown in place of the founding date.
	///
	/// - Returns: The item that measures the studio.
	static func measurableItem(for studio: Studio, rank: Int? = nil, detail: String? = nil) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: StudioLockupCollectionViewCell.self) { cell in
			cell.configure(using: studio, rank: rank, detail: detail)
		}
	}
}
