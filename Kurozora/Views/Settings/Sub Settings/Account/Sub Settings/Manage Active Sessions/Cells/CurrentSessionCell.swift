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
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tintedBackgroundColor.rawValue
			bubbleView.clipsToBounds = true
			bubbleView.cornerRadius = 10
		}
	}
	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Properties
	var session: UserSessionsElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		guard let session = session else { return }

		if let sessionIP = session.ip, !sessionIP.isEmpty {
			ipAddressValueLabel.text = sessionIP
		} else {
			ipAddressValueLabel.text = "-"
		}

		if let deviceName = session.platform?.deviceName, !deviceName.isEmpty {
			deviceValueLabel.text = deviceName
		} else {
			deviceValueLabel.text = "-"
		}
	}
}
