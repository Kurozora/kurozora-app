//
//  UpcomingLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class UpcomingLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var logoImageView: UIImageView!
	@IBOutlet weak var reminderButton: KTintedButton!

	// MARK: - Functions
	override func configure(using show: Show?) {
		super.configure(using: show)
		guard let show = show else { return }

		if let firstAired = show.attributes.firstAired {
			self.secondaryLabel?.text = "\(Trans.expected.capitalized) \(firstAired.formatted(date: .abbreviated, time: .omitted))"
		} else {
			self.secondaryLabel?.text = Trans.comingSoon.capitalized
		}

		// Configure banner
		if let bannerBackgroundColor = show.attributes.poster?.backgroundColor, let color = UIColor(hexString: bannerBackgroundColor) {
			let textColor: UIColor = color.isLight ? .black : .white
			self.bannerImageView?.backgroundColor = color
			self.shadowImageView?.tintColor = color
			self.primaryLabel?.textColor = textColor
			self.secondaryLabel?.textColor = textColor.withAlphaComponent(0.60)
		} else {
			self.bannerImageView?.backgroundColor = .clear
			self.shadowImageView?.tintColor = .black
			self.primaryLabel?.textColor = .white
			self.secondaryLabel?.textColor = .white.withAlphaComponent(0.60)
		}
	}

	// MARK: - IBActions
	@IBAction func reminderButtonPressed(_ sender: UIButton) {
		self.delegate?.baseLockupCollectionViewCell(self, didPressReminder: sender)
	}
}
