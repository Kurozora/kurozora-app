//
//  LibraryListCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LibraryListCollectionViewCell: LibraryBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var estimatedAiringLabel: BroadcastLabel!
	@IBOutlet weak var informationLabel: KSecondaryLabel!
	@IBOutlet weak var genresLabel: KSecondaryLabel!

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.estimatedAiringLabel.stopCountdown()
		self.estimatedAiringLabel.text = ""
	}

	// MARK: - Functions
	override func configure(using show: Show, showSelectionIcon: Bool) {
		super.configure(using: show, showSelectionIcon: showSelectionIcon)

		self.informationLabel.text = show.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

		if show.attributes.status.name == "Currently Airing",
		   let nextBroadcastAt = show.attributes.nextBroadcastAt {
			self.estimatedAiringLabel.startCountdown(to: nextBroadcastAt, duration: show.attributes.durationCount)
		}
	}

	override func configure(using literature: Literature, showSelectionIcon: Bool) {
		super.configure(using: literature, showSelectionIcon: showSelectionIcon)

		self.informationLabel.text = literature.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

		if literature.attributes.status.name == "Currently Publishing",
		   let publicationDate = literature.attributes.publicationDate {
			self.estimatedAiringLabel.startCountdown(to: publicationDate, duration: literature.attributes.durationCount)
		}
	}

	override func configure(using game: Game, showSelectionIcon: Bool) {
		super.configure(using: game, showSelectionIcon: showSelectionIcon)

		self.informationLabel.text = game.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

		if game.attributes.status.name == "Currently Publishing",
		   let publicationDate = game.attributes.publicationDate {
			self.estimatedAiringLabel.startCountdown(to: publicationDate, duration: game.attributes.durationCount)
		}
	}
}
