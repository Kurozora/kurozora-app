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
	@IBOutlet weak var selectedImageView: UIImageView!

	override var isSelected: Bool {
		didSet {
			if isSelected {
				selectedImageView.image = #imageLiteral(resourceName: "check")
				selectedImageView.theme_tintColor = "Global.tintColor"
			} else {
				selectedImageView.image = nil
			}
		}
	}

	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				contentView.alpha = 0.50
			} else {
				contentView.alpha = 1.0
			}
		}
	}
}
