//
//  LibraryListCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LibraryListCollectionViewCell: LibraryBaseCollectionViewCell {
	override var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var estimatedAiringLabel: UILabel! {
		didSet {
			estimatedAiringLabel.theme_textColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var informationLabel: UILabel! {
		didSet {
			informationLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
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
		guard let showDetailsElement = showDetailsElement else { return }
		self.informationLabel.text = showDetailsElement.informationStringShort

		if let airDate = showDetailsElement.airDate, !airDate.isEmpty {
			timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateEstimatedAiringLabel), userInfo: nil, repeats: true)
		} else {
			self.estimatedAiringLabel.text = ""
		}
	}

	@objc func updateEstimatedAiringLabel() {
		guard let airDate = showDetailsElement?.airDate?.toDate else {
			self.estimatedAiringLabel.text = ""
			return
		}
//		let airDate = "2019-12-31 23:59:59".toDate
		let intervalSinceNow = airDate.timeIntervalSinceNow.toString
		let estimatedAiringString = "Episode 1 - \(intervalSinceNow)"
		self.estimatedAiringLabel.text = estimatedAiringString
		print(estimatedAiringString)
	}
}
