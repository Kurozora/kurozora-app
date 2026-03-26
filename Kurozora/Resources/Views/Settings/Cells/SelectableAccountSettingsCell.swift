//
//  SelectableAccountSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class SelectableAccountSettingsCell: AccountSettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var selectedImageView: KImageView!

	// MARK: - Functions
	/// Sets the selected status of the cell.
	///
	/// - Parameter selected: The boolean value indicating whether the cell is selected.
	func setSelected(_ selected: Bool) {
		self.selectedImageView?.isHidden = !selected
	}

	/// Configures the cell with a stored account's data.
	///
	/// - Parameters:
	///   - account: The stored account to display.
	///   - isSelected: Whether this account is the currently active account.
	func configure(using account: StoredAccount, isSelected: Bool) {
		self.primaryLabel?.text = account.username ?? account.slug
		self.secondaryLabel?.text = "@\(account.slug)"

		let placeholder = (account.username ?? account.slug).profilePlaceholderImage
		self.iconImageView?.setImage(with: account.profileImageURL ?? "", placeholder: placeholder)

		self.setSelected(isSelected)
	}
}
