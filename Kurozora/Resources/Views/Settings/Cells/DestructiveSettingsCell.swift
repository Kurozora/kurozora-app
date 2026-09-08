//
//  DestructiveSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class DestructiveSettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet private var titleLabel: UILabel!

	// MARK: - View
	nonisolated override func awakeFromNib() {
		super.awakeFromNib()

		MainActor.assumeIsolated {
			self.selectionStyle = .none
		}
	}

	// MARK: - Functions
	func configure(title: String) {
		self.titleLabel.text = title
	}
}
