//
//  BadgeCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BadgeCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var cosmosView: KCosmosView!
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
			ratingScoreLabel.theme_textColor = KThemePicker.tintColor.rawValue
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
	var collectionView: UICollectionView!
	var show: Show! {
		didSet {
			updateDetails()
		}
	}

	// MARK: - Functions
	/// Updates the view with the details fetched from the server.
	fileprivate func updateDetails() {
		// Configure rating
		let averageRating = show.attributes.userRating.averageRating
		let ratingCount = show.attributes.userRating.ratingCount

		cosmosView.rating = averageRating
		ratingScoreLabel.text = "\(averageRating)"
		ratingTitleLabel.text = averageRating >= 0.00 ? "Not enough ratings" : "\(ratingCount) Ratings"
		ratingTitleLabel.adjustsFontSizeToFitWidth = true

		// Configure rank label
//		if let rankScore = show.attributes.rank {
//			rankScoreLabel.text = rankScore > 0 ? "#\(rankScore)" : "-"
//		}

		// Configure age label
//		if let ageScore = show.attributes.age {
//			ageScoreLabel.text = !ageScore.isEmpty ? ageScore : "-"
//		}
	}

	@objc func showRating(_ gestureRecognizer: UIGestureRecognizer) {
		collectionView.safeScrollToItem(at: IndexPath(row: 0, section: ShowDetail.Section.rating.rawValue), at: .centeredVertically, animated: true)
	}
}
