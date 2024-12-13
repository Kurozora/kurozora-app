//
//  GameLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class GameLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var broadcastLabel: BroadcastLabel!
	@IBOutlet weak var scoreLabel: KTintedLabel!
	@IBOutlet weak var scoreView: KCosmosView!

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.broadcastLabel.stopCountdown()
		self.broadcastLabel.text = ""
	}

	// MARK: - Functions
	override func configure(using game: Game?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: game, rank: rank, scheduleIsShown: scheduleIsShown)

		// Configure tagline
		self.ternaryLabel?.text = nil

		let ratingAverage = game?.attributes.stats?.ratingAverage ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0

		self.posterImageView?.applyCornerRadius(18.0)

		self.broadcastLabel.text = ""
		if scheduleIsShown {
			if game?.attributes.status.name == "Currently Publishing",
			   let publicationDate = game?.attributes.publicationDate {

				self.broadcastLabel.startCountdown(to: publicationDate, duration: game?.attributes.durationCount ?? 0)
			}
		}
	}

	/// Configures the cell using a `RelatedGame` object.
	///
	/// - Parameter relatedGame: The `RelatedGame` object used to configure the cell.
	func configure(using relatedGame: RelatedGame) {
		self.configure(using: relatedGame.game)

		self.ternaryLabel?.text = relatedGame.attributes.relation.name

		self.posterImageView?.applyCornerRadius(18.0)

		self.broadcastLabel.text = nil
	}
}
