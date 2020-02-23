//
//  BadgeCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import Cosmos

class BadgeCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var cosmosView: CosmosView!
	@IBOutlet weak var ratingView: UIView! {
		didSet {
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showRating(_:)))
			ratingView.addGestureRecognizer(gestureRecognizer)
		}
	}
	@IBOutlet weak var ratingTitleLabel: UILabel! {
		didSet {
			ratingTitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var rankTitleLabel: UILabel! {
		didSet {
			rankTitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var ageTitleLabel: UILabel! {
		didSet {
			ageTitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var ratingScoreLabel: UILabel! {
		didSet {
			ratingScoreLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var rankScoreLabel: UILabel! {
		didSet {
			rankScoreLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var ageScoreLabel: UILabel! {
		didSet {
			ageScoreLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	// MARK: - Properties
	var showDetailsElement: ShowDetailsElement? {
		didSet {
			updateDetails()
		}
	}

	// MARK: - Functions
	/// Updates the view with the details fetched from the server.
	fileprivate func updateDetails() {
		guard let showDetailsElement = showDetailsElement else { return }

		// Configure rating
		if let averageRating = showDetailsElement.averageRating, let ratingCount = showDetailsElement.ratingCount, averageRating > 0.00 {
			cosmosView.rating = averageRating
			ratingScoreLabel.text = "\(averageRating)"
			ratingTitleLabel.text = "\(ratingCount) Ratings"
			ratingTitleLabel.adjustsFontSizeToFitWidth = true
		} else {
			cosmosView.rating = 0.0
			ratingScoreLabel.text = "0.0"
			ratingTitleLabel.text = "Not enough ratings"
			ratingTitleLabel.adjustsFontSizeToFitWidth = true
		}

		// Configure rank label
		if let rankScore = showDetailsElement.rank {
			rankScoreLabel.text = rankScore > 0 ? "#\(rankScore)" : "-"
		}

		// Configure age label
		if let ageScore = showDetailsElement.age {
			ageScoreLabel.text = !ageScore.isEmpty ? ageScore : "-"
		}
	}

	@objc func showRating(_ gestureRecognizer: UIGestureRecognizer) {
		parentCollectionView?.safeScrollToItem(at: IndexPath(row: 0, section: ShowDetail.Section.rating.rawValue), at: .centeredVertically, animated: true)
	}
}
