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

	// MARK: - Properties
	var session: Session! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		self.ipAddressValueLabel.text = session.attributes.ip
		self.deviceValueLabel.text = session.relationships.platform.data.first?.attributes.deviceModel
	}
}
