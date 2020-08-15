//
//  OtherSessionsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SwipeCellKit

class OtherSessionsCell: SwipeTableViewCell {
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var ipAddressTitleLabel: KTintedLabel!
	@IBOutlet weak var deviceTypeTitleLabel: KTintedLabel!
	@IBOutlet weak var dateTitleLabel: KTintedLabel!
	@IBOutlet weak var ipAddressValueLabel: KLabel!
	@IBOutlet weak var deviceTypeValueLabel: KLabel!
	@IBOutlet weak var dateValueLabel: KLabel!
	@IBOutlet var separatorView: [SecondarySeparatorView]!

	// MARK: - Properties
	var session: Session! {
		didSet {
			updateOtherSessions()
		}
	}

	// MARK: - Functions
	fileprivate func updateOtherSessions() {
		guard let session = session else { return }

		// IP Address
		ipAddressValueLabel.text = session.attributes.ip

		// Device Type
		deviceTypeValueLabel.text = session.relationships.platform.data.first?.attributes.deviceModel

		// Last Accessed
		dateValueLabel?.text = session.attributes.lastValidatedAt
	}
}
