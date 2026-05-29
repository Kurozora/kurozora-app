//
//  AccountSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

class AccountSettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var profileBorderView: BorderView!

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.iconImageView?.layer.borderWidth = 0
		self.profileBorderView.cornerRadius = (self.iconImageView?.bounds.height ?? 0) / 2.0
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.profileBorderView.cornerRadius = (self.iconImageView?.bounds.height ?? 0) / 2.0
	}
}
