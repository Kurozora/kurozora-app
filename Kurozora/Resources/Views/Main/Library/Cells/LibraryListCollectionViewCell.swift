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
	@IBOutlet weak var estimatedAiringLabel: KTintedLabel!
	@IBOutlet weak var informationLabel: KSecondaryLabel!
	@IBOutlet weak var genresLabel: KSecondaryLabel!

	// MARK: - Properties
	var timer: Timer?
	var broadcastDate: Date?

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.timer?.invalidate()
		self.broadcastDate = nil
	}

	// MARK: - Functions
	override func configure(using show: Show) {
		super.configure(using: show)
		self.broadcastDate = show.attributes.broadcastDate
		self.informationLabel.text = show.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

		if show.attributes.status.name == "Currently Airing" && show.attributes.broadcastDate != nil {
			self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateEstimatedAiringLabel), userInfo: nil, repeats: true)
		}
	}

	override func configure(using literature: Literature) {
		super.configure(using: literature)
		self.broadcastDate = literature.attributes.publicationDate
		self.informationLabel.text = literature.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

		if literature.attributes.status.name == "Currently Publishing" && literature.attributes.publicationDate != nil {
			self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateEstimatedAiringLabel), userInfo: nil, repeats: true)
		}
	}

	override func configure(using game: Game) {
		super.configure(using: game)
//		self.broadcastDate = game.attributes.publicationDate
//		self.informationLabel.text = game.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

//		if game.attributes.status.name == "Currently Publishing" && game.attributes.publicationDate != nil {
//			self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateEstimatedAiringLabel), userInfo: nil, repeats: true)
//		}
	}

	@objc func updateEstimatedAiringLabel() {
		guard let timeUntilBroadcast = self.broadcastDate?.formatted(.relative(presentation: .numeric, unitsStyle: .wide)) else { return }
		let estimatedAiringString = "\(timeUntilBroadcast.capitalizedFirstLetter)"
		self.estimatedAiringLabel.text = estimatedAiringString
	}
}
