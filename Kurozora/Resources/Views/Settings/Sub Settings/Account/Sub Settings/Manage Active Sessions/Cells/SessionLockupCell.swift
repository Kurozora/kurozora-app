//
//  SessionLockupCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SessionLockupCell: KTableViewCell {
	@IBOutlet weak var primaryImageView: KImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Functions
	func configureCell(using session: Session?) {
		guard let session = session else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure background color
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		// Configure platform
		let platform = session.relationships.platform.data.first
		self.configureCell(using: platform)

		// Configure other attributes
		self.secondaryLabel.text = "\(session.attributes.ipAddress) on \(session.attributes.lastValidatedAt.formatted(date: .abbreviated, time: .standard))"
	}

	func configureCell(using accessToken: AccessToken?) {
		guard let accessToken = accessToken else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		// Configure background color
		self.contentView.theme_backgroundColor = KThemePicker.tintedBackgroundColor.rawValue

		// Configure platform
		let platform = accessToken.relationships.platform.data.first
		self.configureCell(using: platform)

		// Configure other attributes
		self.secondaryLabel.text = "\(accessToken.attributes.ipAddress) on \(Trans.thisDevice)"
	}

	private func configureCell(using platform: Platform?) {
		self.primaryImageView.image = platform?.attributes.deviceImage
		self.primaryLabel.text = "\(platform?.attributes.deviceVendor ?? "Unknown") on \(platform?.attributes.systemName ?? "Unknown")"
	}
}
