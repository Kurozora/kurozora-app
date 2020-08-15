//
//  SmallLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SmallLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	override var primaryLabel: UILabel? {
		didSet {
			primaryLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	override var secondaryLabel: UILabel? {
		didSet {
			secondaryLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var scoreButton: UIButton!

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let show = show else { return }
		let score = show.attributes.averageRating

		if score != 0.0 {
			self.scoreButton?.setTitle(" \(score)", for: .normal)
			// Change color based on score
			if score >= 2.5 {
				self.scoreButton?.backgroundColor = .kYellow
			} else {
				self.scoreButton?.backgroundColor = .kLightRed
			}
		} else {
			self.scoreButton?.setTitle("New", for: .normal)
			self.scoreButton?.backgroundColor = .kGreen
		}
	}
}
