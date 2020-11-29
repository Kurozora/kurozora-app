//
//  BasicNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class BasicNotificationCell: BaseNotificationCell {
	// MARK: - IBOutlets
	@IBOutlet weak var notificationIconImageView: UIImageView!
	@IBOutlet weak var chevronImageView: UIImageView! {
		didSet {
			self.chevronImageView.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue
		}
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		notificationIconImageView.image = notificationType?.iconValue
	}
}
