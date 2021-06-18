//
//  LockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LockupCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var posterImageView: UIImageView!
	@IBOutlet weak var countLabel: KSecondaryLabel!
	@IBOutlet weak var startDateTitleLabel: KSecondaryLabel!
	@IBOutlet weak var episodeCountTitleLabel: KSecondaryLabel!
	@IBOutlet weak var ratingTitleLabel: KSecondaryLabel!
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var firstAiredLabel: KLabel!
	@IBOutlet weak var episodeCountLabel: KLabel!
	@IBOutlet weak var ratingLabel: KLabel!
	@IBOutlet var separatorViewLight: [SecondarySeparatorView]?

	// MARK: - Properties
	var season: Season! {
		didSet {
			configureSeasonCell()
		}
	}
	var relatedShow: RelatedShow! {
		didSet {
			configureRelatedShowCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the season's details.
	fileprivate func configureSeasonCell() {
		// Configure poster
		self.posterImageView.image = self.season.attributes.posterImage

		// Configure season number
		let seasonNumber = self.season.attributes.number
		self.countLabel.text = seasonNumber != 0 ? "Season \(seasonNumber)" : ""

		// Configure title
		let seasonTitle = self.season.attributes.title
		self.titleLabel.text = seasonTitle

		// Configure premiere date
		let firstAired = self.season.attributes.firstAired
		self.firstAiredLabel.text = firstAired?.mediumDate ?? "TBA"

		// Configure episode count
		self.episodeCountLabel.text = "\(self.season.attributes.episodeCount)"

		// Configure rating
		self.ratingLabel.text = "0.00"
	}

	/// Configure the cell with the related show's details.
	fileprivate func configureRelatedShowCell() {
		self.posterImageView.image = self.relatedShow.show.attributes.posterImage

		// Configure relation type
		self.countLabel.text = self.relatedShow.attributes.relation.name

		// Configure title
		self.titleLabel.text = self.relatedShow.show.attributes.title

		// Configure premiere date
		let firstAired = self.relatedShow.show.attributes.firstAired
		self.firstAiredLabel.text = firstAired?.mediumDate ?? "TBA"

		// Configure episode count
		self.episodeCountLabel.text = "\(self.relatedShow.show.attributes.episodeCount)"

		// Configure rating
		self.ratingLabel.text = "\(self.relatedShow.show.attributes.userRating.averageRating)"
	}
}
