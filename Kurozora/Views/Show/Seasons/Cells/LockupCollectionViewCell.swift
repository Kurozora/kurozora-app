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
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var countLabel: KLabel! {
		didSet {
			self.countLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var startDateTitleLabel: KTintedLabel!
	@IBOutlet weak var episodeCountTitleLabel: KTintedLabel!
	@IBOutlet weak var ratingTitleLabel: KTintedLabel!
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var firstAiredLabel: KLabel!
	@IBOutlet weak var episodeCountLabel: KLabel!
	@IBOutlet weak var ratingLabel: KLabel!
	@IBOutlet weak var separatorView: SeparatorView!
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

		// Apply shadow to shadow view
		self.shadowView.applyShadow()
	}

	/// Configure the cell with the related show's details.
	fileprivate func configureRelatedShowCell() {
		self.posterImageView.image = self.relatedShow.show.attributes.posterImage

		// Configure relation type
		self.countLabel.text = self.relatedShow.attributes.type

		// Configure title
		self.titleLabel.text = self.relatedShow.show.attributes.title

		// Configure premiere date
		let firstAired = self.relatedShow.show.attributes.firstAired
		self.firstAiredLabel.text = firstAired?.mediumDate ?? "TBA"

		// Configure episode count
		self.episodeCountLabel.text = "\(self.relatedShow.show.attributes.episodeCount)"

		// Configure rating
		self.ratingLabel.text = "\(self.relatedShow.show.attributes.averageRating)"

		// Apply shadow to shadow view
		self.shadowView.applyShadow()
	}
}
