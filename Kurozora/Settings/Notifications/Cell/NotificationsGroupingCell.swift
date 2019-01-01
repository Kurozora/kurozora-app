//
//  NotificationsGroupingCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsGroupingCell: UICollectionViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var selectedLabel: UILabel!

	override var isSelected: Bool {
		didSet {
			if isSelected {
				selectedLabel.text = "✔︎"
			} else {
				selectedLabel.text = ""
			}
		}
	}
}
