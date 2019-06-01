//
//  CurrentSessionCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class CurrentSessionCell: UITableViewCell {
	@IBOutlet weak var ipAddressTitleLabel: UILabel! {
		didSet {
			ipAddressTitleLabel.theme_textColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var ipAddressValueLabel: UILabel! {
		didSet {
			ipAddressValueLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var deviceTitleLabel: UILabel! {
		didSet {
			deviceTitleLabel.theme_textColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var deviceValueLabel: UILabel! {
		didSet {
			deviceValueLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
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

		if let sessionIP = session.ip, sessionIP != "" {
			ipAddressValueLabel.text = sessionIP
		} else {
			ipAddressValueLabel.text = "-"
		}

		if let sessionDevice = session.device, sessionDevice != "" {
			deviceValueLabel.text = sessionDevice
		} else {
			deviceValueLabel.text = "-"
		}
	}
}
