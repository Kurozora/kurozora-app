//
//  SeasonLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SeasonLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var posterContainerView: UIView!
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var posterBorderView: BorderView!
	@IBOutlet weak var countLabel: KSecondaryLabel!
	@IBOutlet weak var startDateTitleLabel: KSecondaryLabel!
	@IBOutlet weak var episodeCountTitleLabel: KSecondaryLabel!
	@IBOutlet weak var ratingTitleLabel: KSecondaryLabel!
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var firstAiredLabel: KLabel!
	@IBOutlet weak var episodeCountLabel: KLabel!
	@IBOutlet weak var ratingLabel: KLabel!
	@IBOutlet var separatorViewLight: [SecondarySeparatorView]?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.posterContainerView.layer.cornerRadius = 22
		self.posterImageView?.applyCornerRadius(22)
		self.posterImageView?.layer.borderWidth = 0
		self.posterBorderView.cornerRadius = 22
	}

	// MARK: - Functions
	/// Configure the cell with the season's details.
	///
	/// - Parameters:
	///	   - season: The `Season` object used to configure the cell.
	func configure(using season: Season?) {
		guard let season = season else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure poster
		season.attributes.posterImage(imageView: self.posterImageView)

		// Configure season number
		self.countLabel.text = "Season \(season.attributes.number)"

		// Configure title
		self.titleLabel.text = season.attributes.title

		// Configure premiere date
		self.firstAiredLabel.text = season.attributes.startedAt?.appFormatted(date: .abbreviated, time: .omitted) ?? "TBA"

		// Configure episode count
		self.episodeCountLabel.text = "\(season.attributes.episodeCount)"

		// Configure rating
		self.ratingLabel.text = "\(season.attributes.ratingAverage)"
	}
}
