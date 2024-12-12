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
	override func configure(using show: Show) {
		super.configure(using: show)

		self.informationLabel.text = show.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

		if show.attributes.status.name == "Currently Airing",
		   let broadcastDate = show.attributes.broadcastDate {

			self.estimatedAiringLabel.startCountdown(to: Date.now + 120, duration: 60)
		}
	}

	override func configure(using literature: Literature) {
		super.configure(using: literature)

		self.informationLabel.text = literature.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

		if literature.attributes.status.name == "Currently Publishing",
		   let publicationDate = literature.attributes.publicationDate {

			self.estimatedAiringLabel.startCountdown(to: publicationDate, duration: literature.attributes.durationCount)
		}
	}

	override func configure(using game: Game) {
		super.configure(using: game)

		self.informationLabel.text = game.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

		if game.attributes.status.name == "Currently Publishing",
		   let publicationDate = game.attributes.publicationDate {

			self.estimatedAiringLabel.startCountdown(to: publicationDate, duration: game.attributes.durationCount)
		}
	}
}
