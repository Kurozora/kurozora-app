//
//  LibraryListCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LibraryListCollectionViewCell: LibraryBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var estimatedAiringLabel: KTintedLabel!
	@IBOutlet weak var informationLabel: KSecondaryLabel!
	@IBOutlet weak var genresLabel: KSecondaryLabel!

	// MARK: - Properties
	var timer: Timer?

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.timer?.invalidate()
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		self.informationLabel.text = show.attributes.informationStringShort
		self.estimatedAiringLabel.text = ""

		if self.show.attributes.status.name == "Currently Airing" && self.show.attributes.broadcastDate != nil {
			self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateEstimatedAiringLabel), userInfo: nil, repeats: true)
		}
	}

	@objc func updateEstimatedAiringLabel() {
		guard let timeUntilBroadcast = self.show.attributes.broadcastDate?.formatted(.relative(presentation: .numeric, unitsStyle: .wide)) else { return }
		let estimatedAiringString = "\(timeUntilBroadcast.capitalizedFirstLetter)"
		self.estimatedAiringLabel.text = estimatedAiringString
	}
}
