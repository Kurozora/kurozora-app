//
//  OtherSessionsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class OtherSessionsCell: KTableViewCell {
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
			configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		self.ipAddressValueLabel.text = session.attributes.ip
		self.deviceTypeValueLabel.text = session.relationships.platform.data.first?.attributes.deviceModel
		self.dateValueLabel?.text = session.attributes.lastValidatedAt
	}
}
