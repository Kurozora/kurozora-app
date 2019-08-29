//
//  OtherSessionsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

protocol OtherSessionsCellDelegate: class {
	func removeSession(for otherSessionsCell: OtherSessionsCell)
}

class OtherSessionsCell: UITableViewCell {
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var ipAddressValueLabel: UILabel! {
		didSet {
			ipAddressValueLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var deviceTypeValueLabel: UILabel! {
		didSet {
			deviceTypeValueLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var dateValueLabel: UILabel! {
		didSet {
			dateValueLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var removeSessionButton: UIButton! {
		didSet {
			removeSessionButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			removeSessionButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var separatorView1: UIView! {
		didSet {
			separatorView1.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet weak var separatorView2: UIView! {
		didSet {
			separatorView2.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	var delegate: OtherSessionsCellDelegate?
	var sessions: UserSessionsElement? {
		didSet {
			updateOtherSessions()
		}
	}

	// MARK: - Functions
	fileprivate func updateOtherSessions() {
		guard let sessions = sessions else { return }

		// IP Address
		if let ipAddress = sessions.ip {
			ipAddressValueLabel.text = ipAddress
		} else {
			ipAddressValueLabel.text = "-"
		}

		// Device Type
		if let deviceType = sessions.device {
			deviceTypeValueLabel.text = deviceType
		} else {
			deviceTypeValueLabel.text = "-"
		}

		// Last Accessed
		if let lastValidated = sessions.lastValidated, lastValidated != "" {
			dateValueLabel?.text = lastValidated
		} else {
			dateValueLabel.text = "-"
		}
	}

	// MARK: - IBActions
	@IBAction func removeSessionButtonPressed(_ sender: UIButton) {
		delegate?.removeSession(for: self)
	}
}
