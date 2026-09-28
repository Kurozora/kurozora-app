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

		let trackable = entry.trackable
		let tagline = trackable?.tagline ?? ""
		self.secondaryLabel.text = tagline.isEmpty ? trackable?.genresLocalized : tagline

		let countdownStatusNames: [String]
		switch entry.kind {
		case .shows: countdownStatusNames = ["Not Airing Yet", "Currently Airing"]
		case .literatures, .games: countdownStatusNames = ["Not Published Yet", "Currently Publishing"]
		}

		if countdownStatusNames.contains(trackable?.statusName ?? ""), let airingDate = entry.nextAiringDate, let durationCount = trackable?.durationCount {
			self.estimatedAiringLabel.startCountdown(to: airingDate, duration: durationCount.intValue)
		}
	}
}
