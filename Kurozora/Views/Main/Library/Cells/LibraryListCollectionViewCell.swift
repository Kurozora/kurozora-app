//
//  LibraryListCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LibraryListCollectionViewCell: LibraryBaseCollectionViewCell {
	@IBOutlet weak var estimatedAiringLabel: UILabel! {
		didSet {
			estimatedAiringLabel.theme_textColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var informationLabel: KLabel!
	@IBOutlet weak var genresLabel: UILabel! {
		didSet {
			genresLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	// MARK: - Properties
	var timer: Timer?

	override func layoutSubviews() {
		super.layoutSubviews()

		posterShadowView?.applyShadow()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		timer?.invalidate()
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let showDetailsElement = showDetailsElement else { return }
		self.informationLabel.text = showDetailsElement.informationStringShort

		guard showDetailsElement.fullAirDate != nil else {
			self.estimatedAiringLabel.text = ""
			return
		}

		timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateEstimatedAiringLabel), userInfo: nil, repeats: true)
	}

	@objc func updateEstimatedAiringLabel() {
		guard let fullAirDate = showDetailsElement?.fullAirDate else { return }
		let fullAirDateValue = fullAirDate.toDate
		let intervalSinceNow = fullAirDateValue.timeIntervalSinceNow.toString
		let estimatedAiringString = "Episode # - \(intervalSinceNow)"
		self.estimatedAiringLabel.text = estimatedAiringString
		print(estimatedAiringString)
	}
}
