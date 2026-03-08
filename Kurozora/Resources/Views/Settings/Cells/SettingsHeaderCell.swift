//
//  SettingsHeaderCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class SettingsHeaderCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.selectionStyle = .none
	}

	// MARK: - Functions
	/// Configures the header cell with an illustration, title, and description.
	///
	/// - Parameters:
	///   - image: The illustration image to display.
	///   - title: The title text.
	///   - description: The description text displayed below the title.
	func configure(image: UIImage?, title: String, description: String) {
		self.iconImageView.image = image
		self.primaryLabel.text = title
		self.secondaryLabel.text = description
	}
}
