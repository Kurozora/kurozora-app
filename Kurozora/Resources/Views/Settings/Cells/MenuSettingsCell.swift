//
//  MenuSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

class MenuSettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var menuActionButton: KButton!

	// MARK: - Functions
	func configure(title: String?, buttonTitle: String? = nil) {
		super.configure(title: title)
		self.secondaryLabel?.isHidden = true
		self.chevronImageView?.isHidden = true
		if let buttonTitle {
			self.menuActionButton.setTitle(buttonTitle, for: .normal)
		}
		self.menuActionButton.contentHorizontalAlignment = .trailing
		self.menuActionButton.showsMenuAsPrimaryAction = true
	}
}
