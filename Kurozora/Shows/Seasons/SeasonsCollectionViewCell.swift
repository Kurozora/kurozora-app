//
//  SeasonsCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class SeasonsCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var posterImageView: UIImageView!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var countLabel: UILabel! {
		didSet {
			countLabel.theme_textColor = KThemePicker.textColor.rawValue
			countLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.textColor.rawValue
			titleLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var startDateTitleLabel: UILabel! {
		didSet {
			startDateTitleLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var startDateLabel: UILabel! {
		didSet {
			startDateLabel.theme_textColor = KThemePicker.textColor.rawValue
			startDateLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var episodeCountTitleLabel: UILabel! {
		didSet {
			episodeCountTitleLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var episodesCountLabel: UILabel! {
		didSet {
			episodesCountLabel.theme_textColor = KThemePicker.textColor.rawValue
			episodesCountLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var ratingTitleLabel: UILabel! {
		didSet {
			ratingTitleLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var ratingLabel: UILabel! {
		didSet {
			ratingLabel.theme_textColor = KThemePicker.textColor.rawValue
			ratingLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var separatorView: UIView? {
		didSet {
			separatorView?.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet var separatorViewLight: [UIView]? {
		didSet {
			for separatorView in separatorViewLight ?? [] {
				separatorView.theme_backgroundColor = KThemePicker.separatorColorLight.rawValue
			}
		}
	}

	var seasonsElement: SeasonsElement? = nil {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let seasonsElement = seasonsElement else { return }

		if let seasonPosterImage = seasonsElement.poster {
			self.posterImageView.setImage(with: seasonPosterImage, placeholder: #imageLiteral(resourceName: "placeholder_poster_image"))
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
}
