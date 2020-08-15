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

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		posterShadowView?.applyShadow()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		timer?.invalidate()
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		self.informationLabel.text = show.attributes.informationStringShort

		guard show.attributes.nextAirDateString != nil else {
			self.estimatedAiringLabel.text = ""
			return
		}

		timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateEstimatedAiringLabel), userInfo: nil, repeats: true)
	}

	@objc func updateEstimatedAiringLabel() {
		guard let fullAirDate = self.show.attributes.nextAirDate else { return }
		let estimatedAiringString = "Episode # - \(fullAirDate.etaStringForDate(short: true))"
		self.estimatedAiringLabel.text = estimatedAiringString
	}
}
