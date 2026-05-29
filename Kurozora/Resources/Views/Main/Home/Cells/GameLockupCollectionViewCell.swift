//
//  GameLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class GameLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var timeLabel: KSecondaryLabel!
	@IBOutlet weak var broadcastLabel: BroadcastLabel!
	@IBOutlet weak var scoreLabel: KTintedLabel!
	@IBOutlet weak var scoreView: KCosmosView!
	@IBOutlet weak var posterContainerView: UIView!
	@IBOutlet weak var posterBorderView: BorderView!

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.posterContainerView.layer.cornerRadius = 22
		self.posterImageView?.applyCornerRadius(22)
		self.posterImageView?.layer.borderWidth = 0
		self.posterBorderView.cornerRadius = 22
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.timeLabel.text = ""
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

		// Configure time label
		self.timeLabel.font = UIFont.preferredFont(forTextStyle: .footnote).bold

		// Configure broadcast
		self.timeLabel.text = ""
		self.broadcastLabel.text = ""
		if scheduleIsShown, let publicationDate = game?.attributes.publicationDate {
			self.timeLabel.text = DateFormatter.broadcastTime.string(from: publicationDate)

			self.broadcastLabel.startCountdown(to: publicationDate, duration: game?.attributes.durationCount ?? 0)
		}
	}

	/// Configures the cell using a `RelatedGame` object.
	///
	/// - Parameter relatedGame: The `RelatedGame` object used to configure the cell.
	func configure(using relatedGame: RelatedGame) {
		self.configure(using: relatedGame.game)

		self.ternaryLabel?.text = relatedGame.attributes.relation.name

		self.broadcastLabel.text = nil
	}
}
