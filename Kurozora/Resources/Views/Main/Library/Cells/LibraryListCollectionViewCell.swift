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
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.estimatedAiringLabel.stopCountdown()
		self.estimatedAiringLabel.text = ""
	}

	// MARK: - Functions
	override func configure(using entry: LocalLibraryEntry, showSelectionIcon: Bool) {
		super.configure(using: entry, showSelectionIcon: showSelectionIcon)

		self.informationLabel.text = entry.informationStringShort
		self.estimatedAiringLabel.text = ""

		let tagline = entry.tagline ?? ""
		self.secondaryLabel.text = tagline.isEmpty ? entry.genresLocalized : tagline

		let isAiring: Bool
		switch entry.kind {
		case .shows: isAiring = entry.statusName == "Currently Airing"
		case .literatures, .games: isAiring = entry.statusName == "Currently Publishing"
		}

		if isAiring, let airingDate = entry.airingDate, let durationCount = entry.durationCount {
			self.estimatedAiringLabel.startCountdown(to: airingDate, duration: durationCount.intValue)
		}
	}
}
