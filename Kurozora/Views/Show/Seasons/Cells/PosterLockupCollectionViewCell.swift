//
//  PosterLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class PosterLockupCollectionViewCell: UICollectionViewCell {
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
			self.configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the season's details.
	func configureCell() {
		// Configure poster
		self.posterImageView.setImage(with: self.season.attributes.poster?.url ?? "", placeholder: R.image.placeholders.showPoster()!)

		// Configure season number
		self.countLabel.text = "Season \(self.season.attributes.number)"

		// Configure title
		self.titleLabel.text = self.season.attributes.title

		// Configure premiere date
		self.firstAiredLabel.text = self.season.attributes.firstAired?.formatted(date: .abbreviated, time: .omitted) ?? "TBA"

		// Configure episode count
		self.episodeCountLabel.text = "\(self.season.attributes.episodeCount)"

		// Configure rating
		self.ratingLabel.text = "0.00"
	}
}
