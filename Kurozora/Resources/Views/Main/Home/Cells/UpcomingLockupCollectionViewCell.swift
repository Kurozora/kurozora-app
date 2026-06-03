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
	@IBOutlet weak var bannerBorderView: BorderView!

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.contentView.layer.cornerRadius = 22
		self.bannerImageView?.applyCornerRadius(22)
		(self.shadowImageView as? RoundedRectangleImageView)?.applyCornerRadius(22)
		self.bannerImageView?.layer.borderWidth = 0
		self.bannerBorderView.cornerRadius = 22
	}

	// MARK: - Functions
	override func configure(using show: Show?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: show, rank: rank, scheduleIsShown: scheduleIsShown)
		guard let show = show else { return }

		if let startedAt = show.attributes.startedAt {
			self.secondaryLabel?.text = "\(L10n.expected.capitalized(with: Locale.current)) \(startedAt.appFormatted(date: .abbreviated, time: .omitted))"
		} else {
			self.secondaryLabel?.text = L10n.comingSoon.capitalized(with: Locale.current)
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
		Task {
			await self.delegate?.baseLockupCollectionViewCell(self, didPressReminder: sender)
		}
	}
}
