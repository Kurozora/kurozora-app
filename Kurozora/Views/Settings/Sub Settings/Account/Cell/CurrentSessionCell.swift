//
//  CurrentSessionCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CurrentSessionCell: UITableViewCell {
	@IBOutlet weak var ipAddressTitleLabel: UILabel! {
		didSet {
			ipAddressTitleLabel.theme_textColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var ipAddressValueLabel: KLabel!
	@IBOutlet weak var deviceTitleLabel: UILabel! {
		didSet {
			deviceTitleLabel.theme_textColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var deviceValueLabel: KLabel!
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tintedBackgroundColor.rawValue
			bubbleView.clipsToBounds = true
			bubbleView.cornerRadius = 10
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	var session: UserSessionsElement? {
		didSet {
			updateCurrentSession()
		}
	}

	// MARK: - Functions
	fileprivate func updateCurrentSession() {
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
