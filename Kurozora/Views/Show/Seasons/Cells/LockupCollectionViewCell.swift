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
	@IBOutlet weak var countLabel: UILabel! {
		didSet {
			countLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
		titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var startDateTitleLabel: UILabel! {
		didSet {
			startDateTitleLabel.theme_textColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var startDateLabel: UILabel! {
		didSet {
			startDateLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var episodeCountTitleLabel: UILabel! {
		didSet {
			episodeCountTitleLabel.theme_textColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var episodesCountLabel: UILabel! {
		didSet {
			episodesCountLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var ratingTitleLabel: UILabel! {
		didSet {
			ratingTitleLabel.theme_textColor = KThemePicker.tintColor.rawValue
		}
}
	@IBOutlet weak var ratingLabel: UILabel! {
		didSet {
			ratingLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet var separatorViewLight: [UIView]? {
		didSet {
			for separatorView in separatorViewLight ?? [] {
				separatorView.theme_backgroundColor = KThemePicker.separatorColorLight.rawValue
			}
		}
	}

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
		if let seasonNumber = seasonsElement.number, seasonNumber != 0 {
			self.countLabel.text = "Season \(seasonNumber)"
		} else {
			self.countLabel.text = "Season ?"
		}

		// Season title
		if let seasonTitle = seasonsElement.title, !seasonTitle.isEmpty {
			self.titleLabel.text = seasonTitle
		} else {
			self.titleLabel.text = "Unknown"
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
