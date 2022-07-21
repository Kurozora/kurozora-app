//
//  CurrentSessionCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CurrentSessionCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var ipAddressTitleLabel: KTintedLabel!
	@IBOutlet weak var deviceTitleLabel: KTintedLabel!
	@IBOutlet weak var ipAddressValueLabel: KLabel!
	@IBOutlet weak var deviceValueLabel: KLabel!
	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Functions
	override func sharedInit() {
		super.sharedInit()
		self.contentView.theme_backgroundColor = KThemePicker.tintedBackgroundColor.rawValue
	}

	// MARK: - Functions
	func configureCell(with accessToken: AccessToken?) {
		guard let accessToken = accessToken else { return }
		self.ipAddressValueLabel.text = accessToken.attributes.ipAddress
		self.deviceValueLabel.text = accessToken.relationships.platform.data.first?.attributes.deviceModel
	}
}
