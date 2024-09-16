//
//  RatingBadgeCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/07/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class RatingBadgeCollectionViewCell: BadgeCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var cosmosView: KCosmosView!
	@IBOutlet weak var ratingScoreLabel: KTintedLabel!

	// MARK: - Functions
	override func configureCell(with show: Show?, showDetailBadge: ShowDetail.Badge) {
		super.configureCell(with: show, showDetailBadge: showDetailBadge)
		guard let stats = show?.attributes.stats else { return }

		self.configureCell(using: stats)
	}

	override func configureCell(with literature: Literature?, literatureDetailBadge: LiteratureDetail.Badge) {
		super.configureCell(with: literature, literatureDetailBadge: literatureDetailBadge)
		guard let stats = literature?.attributes.stats else { return }

		self.configureCell(using: stats)
	}

	override func configureCell(with game: Game?, gameDetailBadge: GameDetail.Badge) {
		super.configureCell(with: game, gameDetailBadge: gameDetailBadge)
		guard let stats = game?.attributes.stats else { return }

		self.configureCell(using: stats)
	}

	override func configureCell(with studio: Studio?, studioDetailBadge: StudioDetail.Badge) {
		super.configureCell(with: studio, studioDetailBadge: studioDetailBadge)
		guard let stats = studio?.attributes.stats else { return }

		self.configureCell(using: stats)
	}

	private func configureCell(using stats: MediaStat) {
		self.cosmosView.rating = stats.ratingAverage
		self.ratingScoreLabel.text = "\(stats.ratingAverage)"
	}
}
