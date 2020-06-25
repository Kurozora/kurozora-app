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
	@IBOutlet weak var startDateLabel: KLabel!
	@IBOutlet weak var episodesCountLabel: KLabel!
	@IBOutlet weak var ratingLabel: KLabel!
	@IBOutlet weak var separatorView: SeparatorView!
	@IBOutlet var separatorViewLight: [SecondarySeparatorView]?

	// MARK: - Properties
	var seasonsElement: SeasonElement? = nil {
		didSet {
			configureSeasonCell()
		}
	}
//	var relatedShowElement: RelatedShowElement? = nil {
//		didSet {
//			configureRelatedShowCell()
//		}
//	}

	// MARK: - Functions
	/// Configure the cell with the season's details.
	fileprivate func configureSeasonCell() {
		guard let seasonsElement = seasonsElement else { return }

		if let seasonPosterImage = seasonsElement.poster {
			self.posterImageView.setImage(with: seasonPosterImage, placeholder: R.image.placeholders.showPoster()!)
		}

		// Season number
		if let seasonNumber = seasonsElement.number {
			self.countLabel.text = seasonNumber != 0 ? "Season \(seasonNumber)" : ""
		}

		// Season title
		if let seasonTitle = seasonsElement.title {
			self.titleLabel.text = seasonTitle
		}

		// Season date
		self.startDateLabel.text = "TBA"

		// Season episode count
		if let episodesCount = seasonsElement.episodesCount {
			self.episodesCountLabel.text = "\(episodesCount)"
		}

		// Season rating
		self.ratingLabel.text = "0.00"

		// Apply shadow to shadow view
		self.shadowView.applyShadow()
	}

	/// Configure the cell with the related show's details.
	fileprivate func configureRelatedShowCell() {
		// Apply shadow to shadow view
		self.shadowView.applyShadow()
	}
}
