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
	override func configureCell(with show: Show) {
		super.configureCell(with: show)

		if let firstAired = show.attributes.firstAired {
			self.secondaryLabel?.text = "EXPECTED \(firstAired.formatted(date: .abbreviated, time: .omitted))"
		} else {
			self.secondaryLabel?.text = "COMING SOON"
		}
	}

	// MARK: - IBActions
	@IBAction func reminderButtonPressed(_ sender: UIButton) {
		self.baseLockupCollectionViewCellDelegate?.reminderButtonPressed(on: self)
	}
}
